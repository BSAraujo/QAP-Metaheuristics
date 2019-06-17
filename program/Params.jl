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
end

function Params(pathToInstance::String, pathToOutput::String, seed::Int, maxTime::Int)
    datasetName = split(pathToInstance, '/')[end]
    sz, A, B = loadInstance(pathToInstance)
    params = Params(pathToInstance, pathToOutput, seed, maxTime, datasetName, sz, A, B)
    return params
end

function loadInstance(pathToInstance::String)
    s = open(pathToInstance) do file
        read(file, String)
    end
    input_data = split(s,"\n\n")

    # Read size of instance
    sz = parse(Int, input_data[1])

    # Read array A
    A = Array{Int64}(undef, sz, sz)
    input_A = input_data[2]
    for (row,line) in enumerate(split(input_A, '\n'))
        for (col,elem) in enumerate(split(line, ' '))
            A[row, col] = parse(Int64, elem)
        end
    end

    # Read array B
    B = Array{Int64}(undef, sz, sz)
    input_B = input_data[3]
    for (row,line) in enumerate(split(input_B, '\n'))
        for (col,elem) in enumerate(split(strip(line), r"\s+"))
            B[row, col] = parse(Int64, elem)
        end
    end
    return sz, A, B
end