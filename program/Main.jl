include("Commandline.jl")
include("Params.jl")

function main()

    c = Commandline()

    println("Input File: \"",c.instance_path,"\"")
    println("Running code with seed=", c.seed)
    # Initialization of the problem data from the commandline
    params = Params(c.instance_path, c.output_path, c.seed, c.cpu_time)

    println("----- STARTING METAHEURISTIC OPTIMIZATION")

    # TODO: Run algorithm

    println("----- METAHEURISTIC OPTIMIZATION COMPLETED IN ")

    # TODO: Print final solution and export results
    # Printing the solution and exporting statistics (also export results into a file)

    println("----- END OF ALGORITHM")
end

main()
