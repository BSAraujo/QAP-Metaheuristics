using IterTools
include("Solution.jl")
include("Params.jl")
include("Recombinations.jl")

""" Genetic Algorithm
Initialize population with random candidate solutions
Evaluate each candidate
Repeat until Termination condition is satisfied
    Select parents (best fitness)
    Recombine pairs of solutions (Crossover)
    Mutate the resulting offspring (Mutation) *Mutation was not implemented 
    Evaluate new candidates
    Select individuals for the next generation
"""

function runGA(params::Params, max_generations::Int, populationSize::Int, recombineOp::Function=order1cx)
    # Check if population size is an even number
    if populationSize % 2 != 0
        populationSize += 1
    end
    results = Dict{String,Any}()
    results["entropy"] = []
    results["numIndividuals"] = []
    results["cost"] = []

    # Initialize population with random candidate solutions
    population = initializePopulation(populationSize)
    bestSol = sort(population)[1]

    append!(results["numIndividuals"],length(population))
    append!(results["entropy"],entropy(population))
    append!(results["cost"],bestSol.cost)

    generation = 0
    # Repeat until Termination condition is satisfied
    while generation < max_generations
        # Select parents
        parents = [(population[i], population[i+Int(length(population)/2)]) 
                   for i=1:Int(length(population)/2)]

        # Recombine pairs of solutions
        offspring = recombinationOp(parents, recombineOp)

        # Mutate the resulting offspring
        offspring = mutationOp(offspring)

        # Evaluate new candidates
        # TODO

        # Select individuals for the next generation
        population = vcat(population,offspring)
        population = selectionOp(population, populationSize)

        sol = sort(population)[1]
        # TODO: keep best observed solution
        if sol < bestSol
            bestSol = sol
        end

        append!(results["numIndividuals"],length(population))
        append!(results["entropy"],entropy(population))
        append!(results["cost"],bestSol.cost)
        generation += 1
    end
    return bestSol, results
end


function initializePopulation(populationSize::Int)::Array{Solution}
    population = Array{Solution}(undef, populationSize)
    for k = 1:populationSize
        population[k] = Solution(params)
    end
    return population
end


##############################################################################
# Mutation operation

function mutationOp(population::Array{Solution})::Array{Solution}
    for k = 1:length(population)
        population[k] = descentHeuristic(population[k])
    end
    return population
end

##############################################################################
# Selection operation

function selectionOp(population::Array{Solution}, n::Int64)::Array{Solution}
    sort!(population)
    population = population[1:n]
    return population
end


##############################################################################
# Distances

# TODO: distance between solutions. 
# Example: number of variables with different values. Or maybe distance between strings

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
function entropy(population::Array{Solution}, distance=hamming, reduce=maximum)
    combinations = subsets(population, 2)
    distances = zeros(Float64, length(combinations)).-1
    for (i,pairs) in enumerate(combinations)
        s1,s2 = pairs
        distances[i] = distance(s1,s2)
    end
    if ~all(distances .>= 0)
        throw("All distances should be non negative!")
    end
    entropy = reduce(distances)
    return entropy
end


# TODO: Diversity management

# TODO: Biased fitness selection

# TODO: save results from genetic algorithm:
# generation, best cost, number of individuals, diversity measure

# TODO: function tests, especially for the recombination operations
