include("Commandline.jl")
include("Params.jl")
include("Solution.jl")
include("LocalSearch.jl")

function main()

    c = Commandline()

    println("Input File: \"",c.instance_path,"\"")
    println("Running code with seed=", c.seed)
    # Initialization of the problem data from the commandline
    params = Params(c.instance_path, c.output_path, c.seed, c.cpu_time)

    println("----- STARTING METAHEURISTIC OPTIMIZATION")

    # TODO: Run algorithm
    #p = [4  13  14   7  16  26  25  17   1  15  20  18  12  19   3  8  21   9   5   6  10  24   2  22  11  23]
    p = [i for i = 1:params.datasetSize]
    sol = Solution(params, p)
    printSolution(sol)

    println("Random solution:")
    Rsol = Solution(params)
    printSolution(Rsol)

    # Local Search
    println("Initial Solution:")
    printSolution(sol)
    
    bestSol = descentHeuristic(sol)

    println("Best solution after local search (descent heuristic):")
    printSolution(bestSol)

    #cost = sum(A[i,j]*B[p[i],p[j]] for i = 1:n, j = 1:n)
    #println("Cost=$cost")

    println("----- METAHEURISTIC OPTIMIZATION COMPLETED IN ")

    # TODO: Print final solution and export results
    # Printing the solution and exporting statistics (also export results into a file)

    println("----- END OF ALGORITHM")
end

main()
