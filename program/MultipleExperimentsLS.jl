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
    executionTime = Float64[],
    numTrials = Int64[],
    bestKnownCost = Any[],
    gap = Any[]
)


timenow = Dates.now()
start_datetime = Dates.format(timenow, "yyyy-mm-dd_HHMMSS")
experiment_dir = joinpath(PROJECT_DIR,"experiments",start_datetime)
mkdir(experiment_dir)

allinstances = [
    "wil100.dat","tho40.dat","ste36c.dat","tai60b.dat","tai80b.dat",
    "sko49.dat","sko100d.dat","scr20.dat","nug24.dat","nug30.dat",
    "bur26a.dat","bur26e.dat","esc32e.dat","tai150b.dat","tho150.dat",
    "esc16h.dat","esc128.dat","chr15a.dat","chr20c.dat","wil50.dat",
    "lipa40b.dat","lipa50a.dat","lipa90b.dat","wil100.dat","els19.dat"
]


results_file = "aggregate_results.txt"

cpu_time = 120

cols_tuple = Tuple(string(sym) for sym in describe(df).variable)
open(joinpath(experiment_dir, results_file),"a+") do txtfile
   write(txtfile,join(cols_tuple,"\t"),"\n") 
end

n_seed = 2:5
num_trials = 10^20

for seed = n_seed
    for instance_name in allinstances
        println("$instance_name; seed=$seed")
        instance_path = joinpath(PROJECT_DIR, "instances",instance_name)
        output_path = joinpath(experiment_dir,split(instance_name,'.')[1]*".jld")
        params = Params(instance_path, output_path, seed, cpu_time)

        Random.seed!(seed)
        sol, results = multistartLS(params, num_trials)
        
        println("LS solution:")
        printSolution(sol)
        println("Gap=",results["gap"])
        println()

        if occursin(" ", params.pathToOutput)
            throw("Your project path must not contain any spaces, because of the behaviour of the JLD package.")
        end
        #save(params.pathToOutput, "data", results) # for some unknown reason this does not work
        #save(joinpath("..\\..","experiments",start_datetime,split(instance_name,'.')[1]*".jld"), "data", results)

        new_tuple = (instance_name, 
            params.datasetSize,
            seed,
            results["finalCost"], 
            results["time"],
            results["numTrials"],
            params.solutionCost,
            results["gap"])
        push!(df, new_tuple)

        open(joinpath(experiment_dir, results_file),"a+") do txtfile
           write(txtfile,join(new_tuple,"\t"),"\n") 
        end
    end
end


