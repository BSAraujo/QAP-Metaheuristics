struct Params
    # GENERAL PARAMETERS
    pathToInstance::String            # Path to the instance
    pathToOutput::String              # Path to the output solution
    # PARAMETERS OF THE ALGORITHM
    seed::Int 
    maxTime::Int 
    # DATASET INFORMATION
    datasetName::String  
    datasetSize::Int
    A::Array{Int64}
    B::Array{Int64}
    solutionCost::Any
    solution::Any
end

# Constructor of struct Params
function Params(pathToInstance::String, pathToOutput::String, seed::Int, maxTime::Int)
    datasetName = split(pathToInstance, '/')[end]
    sz, A, B = loadInstance(pathToInstance)

    solutionName = split(datasetName,'.')[1]*".sln"
    solution_path = join(split(pathToInstance,'/')[1:end-2],'/')*"/solutions/"*solutionName

    if isfile(solution_path)
        sz_sol, cost, sol = loadSolution(solution_path)
        if sz != sz_sol
            throw("Size in instance file and solution file should be the same!")
        end
    else
        cost = nothing
        sol = nothing
    end
    params = Params(pathToInstance, pathToOutput, seed, maxTime, datasetName, sz, A, B, cost, sol)
    return params
end

function loadInstance(pathToInstance::String)
    """
    Loads instance file
    """
    s = open(pathToInstance) do file
        read(file, String)
    end
    lines = split(s, '\n')
    lines = [strip(l) for l in lines]
    lines = lines[lines .!= ""]

    sz = parse(Int, strip(lines[1]))
    lines = lines[2:end]

    A = Array{Int64}(undef, sz, sz)
    for row = 1:sz
        line = lines[row] 
        for (col,elem) in enumerate(split(strip(line), r"\s+"))
            A[row, col] = parse(Int64, elem)
        end
    end

    lines = lines[sz:end] 

    # Read array B
    B = Array{Int64}(undef, sz, sz)
    for row = 1:sz
        line = lines[row] 
        for (col,elem) in enumerate(split(strip(line), r"\s+"))
            B[row, col] = parse(Int64, elem)
        end
    end
    return sz, A, B
end

function loadSolution(solution_path::String)
    """
    Loads solution file
    """
    s = open(solution_path) do file
        read(file, String)
    end
    s = replace(s,',' => ' ')
    elements = split(strip(s), r"\s+")
    sz = parse(Int, strip(elements[1]))
    cost = parse(Int, strip(elements[2]))
    sol = Array{Int64}(undef, sz)
    elements = elements[3:end]
    for row = 1:sz
        sol[row] = parse(Int64, elements[row])
    end
    return sz, cost, sol
end