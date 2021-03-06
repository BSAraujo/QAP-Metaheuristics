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
    datasetName = split(pathToInstance, '\\')[end]
    sz, A, B = loadInstance(pathToInstance)

    solutionName = split(datasetName,'.')[1]*".sln"
    solution_path = joinpath(join(split(pathToInstance,'\\')[1:end-2],'\\'),"solutions",solutionName)

    if isfile(solution_path)
        sz_sol, cost, sol = loadSolution(solution_path)
        if sz != sz_sol
            throw("Size in instance file and solution file should be the same!")
        end
    else
        cost = NaN
        sol = NaN
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
    s = split(strip(replace(s,"\n" => " ")), r"\s+")

    sz = parse(Int, s[1])
    if (length(s) != sz*sz*2+1)
        throw("Size of instance does not match the size specified!")
    end

    s = s[2:end]

    A = map(x->parse(Int64,x), reshape(s[1:sz^2],sz,sz))

    s = s[sz^2+1:end]

    B = map(x->parse(Int64,x), reshape(s[1:sz^2],sz,sz))

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