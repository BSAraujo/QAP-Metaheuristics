using Random
include("Params.jl")

struct Solution
    params::Params               # Access to the problem and dataset parameters
    permutation::Array{Int64}    # Permutation
    cost::Int64                  # Value of objective function for the solution
end

# Constructor of struct Solution (random permutation)
function Solution(params::Params)::Solution
    # p = convert(Array{Int64}, transpose(randperm(params.datasetSize)))
    p = randperm(params.datasetSize)
    sol = Solution(params, p)
    return sol
end

# Constructor of struct Solution given a permutation
function Solution(params::Params, p::Array{Int64})::Solution
    cost = evaluate(params, p)
    sol = Solution(params, p, cost)
    return sol
end

# Evaluate solution (calculate value of objective function)
function evaluate(params::Params, p::Array{Int64})::Float64
    n = params.datasetSize
    A = params.A
    B = params.B
    cost = sum(A[i,j]*B[p[i],p[j]] for i = 1:n, j = 1:n)
    if cost < 0
        throw("Cost should be non negative!")
    end
    return cost
end

# Print solution permutation and value of objective function (cost)
function printSolution(sol::Solution)
    println("Permutation=",sol.permutation)
    println("Cost=",sol.cost)
end

# Generate neighborhood of solutions (array of Solutions) obtained from
# all pairwise exchanges of "facilities" 
function generateSwapNeighbors(sol::Solution)::Array{Solution}
    n = sol.params.datasetSize
    neighborhood = Array{Solution}(undef, Int((n-1)*n/2))
    k = 1
    for i = 1:n-1
        for j = i+1:n
            newP = copy(sol.permutation)
            # Exchange facilities
            tmp = newP[i]
            newP[i] = newP[j]
            newP[j] = tmp
            # Add new solution to neighborhood
            neighborhood[k] = Solution(sol.params,newP)
            k += 1
        end
    end
    return neighborhood
end

import Base: isless

isless(a::Solution, b::Solution) = isless(a.cost, b.cost)
