include("Solution.jl")
include("Params.jl")

""" Descent Heuristic
1. Select a starting solution.
2. Check the change in the value of the objective function 
     for all pairwise exchanges of facilities.
3. If an improving exchange is found, 
     the best improving exchange is executed and we go to Step 2.
4. If no improving exchange is found, the algorithm terminates.

Local Search algorithm
S = Initial Solution 
While not Terminated
    Explore( N(S) ) ;
    If there is no better neighbor in N(s) Then Stop ;
    S = Select( N(S) ) ;
End While
Return Final solution found (local optima) 
"""
function descentHeuristic(sol::Solution; max_iter::Float64=Inf)::Solution
    improved::Bool = true
    num_iter = 0
    while ((improved == true) && (num_iter < max_iter))
        neighborhood = generateSwapNeighbors(sol) # Generate N(S)
        improved = false
        for neighbor in neighborhood    # Explore( N(S) )
            if (neighbor.cost < sol.cost)
                sol = neighbor
                improved = true
            end
        end
        num_iter += 1
    end
    return sol  # return best solution found
end


# Multi-start local search
function multistartLS(params::Params, num_trials::Int)::Solution
    startTime = time()
    bestSol = Solution(params) # Random solution
    bestSol = descentHeuristic(bestSol) # Local search
    trial = 1
    while ((trial <= num_trials) && (time() - startTime < params.maxTime))
        sol = Solution(params) # Random solution
        sol = descentHeuristic(sol) # Local Search
        if (sol.cost < bestSol.cost)
            bestSol = sol
        end
        trial += 1
    end
    return bestSol
end
