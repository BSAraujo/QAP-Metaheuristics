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
function descentHeuristic(sol::Solution)::Solution
    improved::Bool = true
    while improved == true
        neighborhood = generateSwapNeighbors(sol) # Generate N(S)
        improved = false
        for neighbor in neighborhood    # Explore( N(S) )
            if (neighbor.cost < sol.cost)
                sol = neighbor
                improved = true
            end
        end       
    end
    return sol  # return best solution found
end


# Multi-start local search
function multistartLS(params::Params, num_trials::Int)::Solution
    bestSol = Solution(params) # Random solution
    bestSol = descentHeuristic(bestSol) # Local search
    for trial = 1:num_trials
        sol = Solution(params) # Random solution
        sol = descentHeuristic(sol) # Local Search
        if (sol.cost < bestSol.cost)
            bestSol = sol
        end
    end
    return bestSol
end
