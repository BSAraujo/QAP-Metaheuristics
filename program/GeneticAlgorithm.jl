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

function runGA(params::Params, max_generations::Int, populationSize::Int)
    # Check if population size is an even number
    if populationSize % 2 != 0
        populationSize += 1
    end
    # Initialize population with random candidate solutions
    population = initializePopulation(populationSize)
    generation = 0
    # Repeat until Termination condition is satisfied
    while generation < max_generations
        # Select parents
        parents = [(population[i], population[i+Int(length(population)/2)]) 
                   for i=1:Int(length(population)/2)]

        # Recombine pairs of solutions

        # Mutate the resulting offspring

        # Evaluate new candidates

        # Select individuals for the next generation

        generation += 1
    end
end


function initializePopulation(populationSize::Int)::Array{Solution}
    population = Array{Solution}(undef, populationSize)
    for k = 1:populationSize
        population[k] = Solution(params)
    end
    return population
end