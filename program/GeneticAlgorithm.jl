include("Solution.jl")
include("Params.jl")

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

function runGA(params::Params, max_generations::Int, populationSize::Int)::Solution
    # Check if population size is an even number
    if populationSize % 2 != 0
        populationSize += 1
    end
    # Initialize population with random candidate solutions
    population = initializePopulation(populationSize)
    generation = 0
    bestSol::Solution
    # Repeat until Termination condition is satisfied
    while generation < max_generations
        # Select parents
        parents = [(population[i], population[i+Int(length(population)/2)]) 
                   for i=1:Int(length(population)/2)]

        # Recombine pairs of solutions
        offspring = recombinationOp(parents)

        # Mutate the resulting offspring
        offspring = mutationOp(offspring)

        # Evaluate new candidates
        # TODO

        # Select individuals for the next generation
        population = vcat(population,offspring)
        population = selectionOp(population, populationSize)

        bestSol = sort(population)[1]

        generation += 1
    end
    return bestSol
end


function initializePopulation(populationSize::Int)::Array{Solution}
    population = Array{Solution}(undef, populationSize)
    for k = 1:populationSize
        population[k] = Solution(params)
    end
    return population
end

##############################################################################
# Recombination operations

function order1op(p1::Solution,p2::Solution,s=nothing)
    n = p1.params.datasetSize
    c_perm = zeros(Int, n)
    if s == nothing
        s = rand(1:n)
    end
    c_perm[s:min(n,s+Int(n/2)-1)] = p1.permutation[s:min(n,s+Int(n/2)-1)]
    if s+Int(n/2)-1 > n
        c_perm[1:(s+Int(n/2)-1) % n] = p1.permutation[1:(s+Int(n/2)-1) % n]
    end

    # Child 1
    filled = 0
    i = s+Int(n/2)
    if i > n
        i = (s+Int(n/2)) % n
    end
    j = i
    while filled < Int(n/2)
        if i > n
            i = 1
        end
        if j > n
            j = 1
        end
        tmp = p2.permutation[i]
        if ~(tmp in c_perm)
            c_perm[j] = tmp
            filled += 1
            j += 1
        end
        i += 1
    end
    if ~hasUniqueValues(c_perm)
        throw("Child permutation must have unique values")
    end
    if sort(c_perm) != 1:n
        throw("Child must be a permutation") 
    end
    params = p1.params
    return Solution(params,c_perm),s
end

function hasUniqueValues(y::Array{Int64})::Bool
    u = unique(y)
    d = Dict([(i,count(x->x==i,y)) for i in u])
    return all(x->x==true, [v for (k,v) in d] .== 1)
end

function order1cx(p1::Solution,p2::Solution)
    # Order 1 crossover
    c1,s = order1op(p1,p2) # Child 1
    c2,_ = order1op(p2,p1,s) # Child 2
    return (c1,c2)
end


function PMXcx(p1::Solution,p2::Solution)
    # PMX crossover: http://www.rubicite.com/Tutorials/GeneticAlgorithms/CrossoverOperators/PMXCrossoverOperator.aspx
    # TODO
    return (c1,c2)
end

function Cyclecx(p1::Solution,p2::Solution)
    # Cycle crossover: http://www.rubicite.com/Tutorials/GeneticAlgorithms/CrossoverOperators/CycleCrossoverOperator.aspx
    # TODO
    return (c1,c2)
end

function CohesiveMergecx(p1::Solution,p2::Solution)
    # Cohesive Merging crossover: Zvi Drezner, "A new Genetic Algorithm for the QAP"
    # TODO
    return (c1,c2)
end

function ScrambledMergecx(p1::Solution,p2::Solution)
    # Scrambled Merging crossover: Zvi Drezner, "A new Genetic Algorithm for the QAP"
    # TODO
    return (c1,c2)
end


function recombinationOp(parents,recombine=order1cx)::Array{Solution}
    offspring = Array{Solution}(undef, 0)
    for (p1,p2) in parents
        (c1,c2) = recombine(p1,p2)
        offspring = vcat(offspring, c1, c2)
    end
    return offspring
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

# TODO: Diversity management

# TODO: Biased fitness selection

# TODO: distance between solutions. 
# Example: number of variables with different values. Or maybe distance between strings

# TODO: "Population entropy": maximum/average/median distance between any two solutions in the population