PROJECT_DIR = pwd()*"\\.."

using DataFrames
using Dates
#using HDF5, JLD

include("Params.jl")
include("Solution.jl")
include("LocalSearch.jl")
include("GeneticAlgorithm.jl")

#allinstances = readdir("../../instances/");
#allsolutions = readdir("../../solutions/");

#println("Number of instance files: ",length(allinstances))
#println("Number of solution files: ",length(allsolutions))

df = DataFrame(
    instance = String[], 
    size = Int64[],
    seed = Int64[],
    finalCost = Int64[],
    populationSize = Int64[],
    maxGenerations = Int64[],
    recombineOp = Function[],
    distanceFunc = Function[],
    entropyReduceFunc = Function[],
    mutate = Any[],
    selection = Any[],
    executionTime = Float64[],
    numIndividuals = Int64[],
    finalEntropy = Float64[],
    numGenerations = Int64[],
    bestKnownCost = Any[],
    gap = Any[]
)


timenow = Dates.now()
start_datetime = Dates.format(timenow, "yyyy-mm-dd_HHMMSS")
experiment_dir = joinpath(PROJECT_DIR,"experiments",start_datetime)
mkdir(experiment_dir)

results_file = "aggregate_results.txt"

cpu_time = 120

cols_tuple = Tuple(string(sym) for sym in describe(df).variable)
open(joinpath(experiment_dir, results_file),"a+") do txtfile
   write(txtfile,join(cols_tuple,"\t"),"\n") 
end

# Grid search of parameters
n_seed = 1:5
n_maxGenerations = 10^10
n_populationSize = [50]
n_recombineOp = [order1cx,PMXcx,cyclecx]
n_distanceFunc = [hamming]
n_entropyReduceFunc = [mean]
n_mutate = [cyclicHeuristic]
n_selection = [fitnessSelection,biasedFitnessSelection]

allinstances = [
    "wil100.dat","tho40.dat","ste36c.dat","tai60b.dat","tai80b.dat",
    "sko49.dat","sko100d.dat","nug30.dat","tai150b.dat",#"tho150.dat",
    #"chr20c.dat","wil50.dat","lipa40b.dat","lipa50a.dat","lipa90b.dat"
    #"els19.dat"
    #"bur26a.dat","bur26e.dat","esc16h.dat","esc32e.dat","esc128.dat","chr15a.dat","nug24.dat","scr20.dat"
]

for gaParams in Iterators.product(
        n_seed,n_maxGenerations,n_populationSize,n_recombineOp,n_distanceFunc,
        n_entropyReduceFunc,n_mutate,n_selection,allinstances)
	# Unpack parameters for GA
    seed,maxGenerations,populationSize,recombine,distFunc,
        entropyReduce, mutate, selection, instance_name = gaParams

    println(gaParams)
    println("$instance_name; seed=$seed; maxGen=$maxGenerations; popSize=$populationSize")
    instance_path = joinpath(PROJECT_DIR, "instances",instance_name)
    output_path = joinpath(experiment_dir,split(instance_name,'.')[1]*".jld")
    params = Params(instance_path, output_path, seed, cpu_time)

    Random.seed!(seed)
    solGA, results = runGA(params, maxGenerations, populationSize,
                           recombineOp=recombine, 
                           distanceFunc=distFunc, 
                           entropyReduceFunc=entropyReduce, 
                           mutate=mutate,
                           selectionOp=selection,
                           selectionOpts=Dict{String,Any}("fitnessThreshold"=>0.45))
    
    println("GA solution:")
    printSolution(solGA)
    println("Gap=",results["gap"][end])
    println()

    if occursin(" ", params.pathToOutput)
        throw("Your project path must not contain any spaces, because of the behaviour of the JLD package.")
    end
    #save(params.pathToOutput, "data", results) # for some unknown reason this does not work
    #save(joinpath("..\\..","experiments",start_datetime,split(instance_name,'.')[1]*".jld"), "data", results)

    new_tuple = (instance_name, 
        params.datasetSize,
        seed,
        results["cost"][end], 
        results["populationSize"], 
        results["maxGenerations"],
        recombine,
        distFunc,
        entropyReduce,
        mutate,
        selection,
        results["time"],
        results["numIndividuals"][end],
        results["entropy"][end],
        results["generations"],
        params.solutionCost,
        results["gap"][end])
    push!(df, new_tuple)

    open(joinpath(experiment_dir, results_file),"a+") do txtfile
       write(txtfile,join(new_tuple,"\t"),"\n") 
    end
end

println("Finished execution.")
