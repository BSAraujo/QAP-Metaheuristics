using IterTools
using Statistics
include("Solution.jl")
include("Params.jl")
include("Recombinations.jl")

""" Genetic Algorithm
Initialize population with random candidate solutions
Evaluate each candidate
Repeat until Termination condition is satisfied
    Select parents (best fitness)
    Recombine pairs of solutions (Crossover)
    Mutate the resulting offspring (Mutation) 
    Evaluate new candidates
    Select individuals for the next generation
"""

# Genetic Algorithm
function runGA(params::Params, maxGenerations::Int, populationSize::Int;
               recombineOp::Function=order1cx, distanceFunc::Function=hamming, entropyReduceFunc::Function=mean,
               mutate::Any=false, selectionOp::Function=fitnessSelection, selectionOpts::Dict{String,Any}=Dict{String,Any}("fitnessThreshold"=>0.2))
    selectionOpts["n"] = populationSize
    selectionOpts["distanceFunc"] = hamming
    startTime = time()
    # Check if population size is an even number
    if populationSize % 2 != 0
        populationSize += 1
    end
    results = Dict{String,Any}()
    results["maxGenerations"] = maxGenerations
    results["populationSize"] = populationSize
    results["entropy"] = []
    results["numIndividuals"] = []
    results["cost"] = []
    results["generationTime"] = []

    # Initialize population with random candidate solutions
    population = initializePopulation(params, populationSize)
    bestSol = sort(population)[1]

    append!(results["numIndividuals"],length(population))
    append!(results["entropy"],entropy(population, distanceFunc, entropyReduceFunc))
    append!(results["cost"],bestSol.cost)
    append!(results["generationTime"],time() - startTime)

    generation = 0
    # Repeat until Termination condition is satisfied
    while ((generation < maxGenerations) && (time() - startTime < params.maxTime) && (bestSol.cost != params.solutionCost))
        # Select parents
        population = shuffle!(population)  # shuffle population
        parents = [(population[i], population[i+Int(floor(length(population)/2))]) 
                   for i=1:Int(floor(length(population)/2))]

        # Recombine pairs of solutions
        offspring = recombinationOp(parents, recombineOp)

        # Mutate the resulting offspring
        if mutate != false
            offspring = mutationOp(offspring, mutate)
        end

        # Evaluate new candidates
        # TODO

        # Select individuals for the next generation
        population = vcat(population,offspring)
        survivors = selectionOp(population, selectionOpts)
        population = population[survivors]
        population = removeClones(population) # Remove clones from the population

        sol = sort(population)[1]
        # record best observed solution
        if sol < bestSol
            bestSol = sol
        end

        append!(results["numIndividuals"],length(population))
        append!(results["entropy"],entropy(population, distanceFunc, entropyReduceFunc))
        append!(results["cost"],bestSol.cost)
        append!(results["generationTime"],time() - startTime)
        results["generations"] = generation
        generation += 1
    end
    # Results
    results["time"] = time() - startTime
    results["finalCost"] = bestSol.cost
    results["permutation"] = bestSol.permutation
    if isnan(params.solutionCost)
        results["gap"] = NaN
    else
        results["gap"] = (results["cost"] .- params.solutionCost) ./ params.solutionCost
    end
    return bestSol, results
end


function initializePopulation(params::Params, populationSize::Int)::Array{Solution}
    population = Array{Solution}(undef, populationSize)
    for k = 1:populationSize
        population[k] = Solution(params)
    end
    return population
end


##############################################################################
# Mutation operation

function mutationOp(population::Array{Solution}, mutate::Function=descentHeuristic)::Array{Solution}
    for k = 1:length(population)
        population[k] = mutate(population[k], max_iter=1.0)
    end
    return population
end


##############################################################################
# Selection operation

# Selection based on fitness. Selects n most fit individuals from the population.
function fitnessSelection(population::Array{Solution}, selectionOpts::Dict)::Array{Bool}
    costArray = [s1.cost for s1 in population]
    fitnessRank = getRanking(costArray)
    survivors = fitnessRank .<= selectionOpts["n"]
    return survivors
    #sort!(population)
    #population = population[1:n]
    #return population
end

# Selection based on biased fitness
function biasedFitnessSelection(population::Array{Solution}, selectionOpts::Dict)::Array{Bool}
    index, diversityScore, fitnessScore = fitnessDiversityScore(population, selectionOpts["distanceFunc"])
    biasedFitnessVal = biasedFitness(fitnessScore, diversityScore, selectionOpts["fitnessThreshold"])
    biasedFitnessRank = getRanking(biasedFitnessVal)
    #survivors = biasedFitnessVal .<= 1
    survivors = biasedFitnessRank .<= selectionOpts["n"]
    return survivors
    #population = population[survivors]
    #return population
end

function removeClones(population::Array{Solution})
    return unique(x -> x.permutation, population)
end

##############################################################################
# Distances
# Implemented distance functions:
# - Hamming distance
# - Kendall-Tau distance

# Hamming distance: number of positions with different values
function hamming(s1::Solution,s2::Solution)::Float64
    distance = sum(s1.permutation .!= s2.permutation)
    return distance
end

# Distance between two permutations: https://math.stackexchange.com/questions/2492954/distance-between-two-permutations

# Kendall-Tau distance: 
# - https://en.wikipedia.org/wiki/Kendall_tau_distance
# - https://stats.stackexchange.com/questions/168602/whats-the-kendall-taus-distance-between-these-2-rankings/238852#238852
function kendallTau(s1::Solution,s2::Solution)::Float64
    A = s1.permutation
    B = s2.permutation
    pairs = subsets(1:length(A), 2)
    distance = 0
    for (x,y) in pairs
        a = A[x] - A[y]
        b = B[x] - B[y]
        # if discordant (different signs)
        if (a * b < 0)
            distance += 1
        end
    end
    return distance
end

# "Population entropy": maximum/average/median distance between any two solutions in the population
function entropy(population::Array{Solution}, distance::Function, reduce::Function)
    allpairs = subsets(population, 2)
    distances = zeros(Float64, length(allpairs)).-1
    for (i,pairs) in enumerate(allpairs)
        s1,s2 = pairs
        distances[i] = distance(s1,s2)
    end
    if ~all(distances .>= 0)
        throw("All distances should be non negative!")
    end
    entropy = reduce(distances)
    return entropy
end


##############################################################################
# Diversity management

function getRanking(input; rev=false)
    output = zeros(Int64,length(input))
    for (i,x) in enumerate(sort(1:length(input), by=y->input[y], rev=rev))
        output[x] = i
    end
    return output
end

# Individual contribution to diversity: mean distance from all other solutions
function diversityContrib(s1::Solution, population::Array{Solution}, distance::Function)
    dcontrib = mean([distance(s1,s2) for s2 in population if s1.permutation != s2.permutation])
    return dcontrib
end

# Ranks solutions by fFitness and diversity 
function fitnessDiversityRank(population::Array{Solution}, distanceFunc::Function)
    """ Fitness Rank and Diversity Rank
    Fitness and Diversity Rank are values between 1 and the size of the population n
    with 1 meaning that the solution is the most fit/diverse 
    and n meaning that the solution is the least fit/diverse
    """
    index = 1:length(population)
    costArray = [s1.cost for s1 in population]
    diversityArray = [diversityContrib(s1, population, distanceFunc) for s1 in population]
    fitnessRank = getRanking(costArray)
    diversityRank = getRanking(diversityArray,rev=true)
    # Check fitness ranking
    @assert population[fitnessRank .== 1][1].cost == minimum(costArray)
    @assert population[fitnessRank .== length(population)][1].cost == maximum(costArray)
    # Check diversity ranking
    @assert diversityArray[diversityRank .== 1][1] == maximum(diversityArray)
    @assert diversityArray[diversityRank .== length(population)][1] == minimum(diversityArray)
    return index, diversityRank, fitnessRank
end

function minMaxScale(x)
    x_norm = (x .- minimum(x)) ./ (maximum(x) - minimum(x))
    return x_norm
end

# Fitness and diversity score: fitness and diversity ranks normalized to values between 0 and 1
function fitnessDiversityScore(population::Array{Solution}, distanceFunc::Function)
    """ Fitness Score and Diversity Score
    Fitness and Diversity Score are values between 0 and 1 
    with 0 meaning that the solution is the most fit/diverse 
    and 1 meaning that the solution is the least fit/diverse
    """
    index, diversityRank, fitnessRank = fitnessDiversityRank(population, distanceFunc)
    diversityScore = minMaxScale(diversityRank)
    fitnessScore = minMaxScale(fitnessRank)
    return index, diversityScore, fitnessScore
end

# Biased fitness
function biasedFitness(fitnessScore::Array{Float64}, diversityScore::Array{Float64}, fitnessThreshold::Float64=0.2)
    biasedFitness = fitnessScore .+ (1 - fitnessThreshold).*diversityScore
    return biasedFitness
end

# TODO: save results from genetic algorithm:
# generation, best cost, number of individuals, diversity measure

# TODO: function tests, especially for the recombination operations

# TODO: formulate and solve the Mathematical Programming model of the QAP. Compare time and objective values.
