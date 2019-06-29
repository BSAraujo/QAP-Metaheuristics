include("Solution.jl")
include("Params.jl")

""" Recombination Operations for the Genetic Algorithm

Implemented recombinations:
- Order 1 Crossover - order1cx
- Partially Mapped Crossover (PMX) - PMXcx
- Cycle Crossover - cyclecx

TODO:
- Edge Recombination
- Order Multiple Crossover
- Direct Insertion Crossover
- Cohesive Merging Procedure
- Scrambled Merging Procedure
"""

##############################################################################
# Recombination operations

function hasUniqueValues(y::Array{Int64})::Bool
    u = unique(y)
    d = Dict([(i,count(x->x==i,y)) for i in u])
    return all(x->x==true, [v for (k,v) in d] .== 1)
end


function order1op(p1::Array{Int64},p2::Array{Int64},s=nothing)
    n = length(p1)
    if ~((sort(p1) == 1:n) && (sort(p2) == 1:n))
        throw("Input parents must be a permutation arrays") 
    end
    c_perm = zeros(Int, n)
    if s == nothing
        s = rand(1:n)
    end
    cp_idx = s:min(n,s+Int(floor(n/2))-1)
    if s+Int(floor(n/2))-1 > n
        cp_idx = vcat(cp_idx, 1:(s+Int(floor(n/2))-1) % n)
    end
    c_perm[cp_idx] = p1[cp_idx]

    # Child 1
    filled = 0
    i = s+Int(floor(n/2))
    if i > n
        i = (s+Int(floor(n/2))) % n
    end
    j = i
    while filled < Int(ceil(n/2))
        if i > n
            i = 1
        end
        if j > n
            j = 1
        end
        tmp = p2[i]
        if ~(tmp in c_perm)
            c_perm[j] = tmp
            filled += 1
            j += 1
        end
        i += 1
    end
    if ~hasUniqueValues(c_perm)
        throw("Child permutation must have unique values")
    end
    if sort(c_perm) != 1:n
        throw("Child must be a permutation") 
    end
    return c_perm, s
end

function order1cx(p1::Solution,p2::Solution)
    # Order 1 crossover: http://www.rubicite.com/Tutorials/GeneticAlgorithms/CrossoverOperators/Order1CrossoverOperator.aspx
    c1_perm,s = order1op(p1.permutation,p2.permutation) # Child 1
    c2_perm,_ = order1op(p2.permutation,p1.permutation,s) # Child 2
    params = p1.params
    c1 = Solution(params,c1_perm)
    c2 = Solution(params,c2_perm)
    return (c1,c2)
end


function PMXop(p1::Array{Int64},p2::Array{Int64},s=nothing)
    n = length(p1)
    if ~((sort(p1) == 1:n) && (sort(p2) == 1:n))
        throw("Input parents must be permutation arrays") 
    end
    c_perm = zeros(Int, n)
    if s == nothing
        s = rand(1:n)
    end
    cp_idx = s:min(n,s+Int(floor(n/2))-1)
    if s+Int(floor(n/2))-1 > n
        cp_idx = vcat(cp_idx, 1:(s+Int(floor(n/2))-1) % n)
    end
    c_perm[cp_idx] = p1[cp_idx]

    filled_idx = cp_idx
    for i in cp_idx
        p2_idx = i
        p2_val = p2[p2_idx]
        if ~(p2_val in c_perm[cp_idx])
            include_val = p2_val
            while (p2_idx in filled_idx)            
                p1_idx = p2_idx
                p1_val = p1[p1_idx]
                p2_idx = findfirst(p2 .== p1_val)
                p2_val = p2[p2_idx]
            end
            c_perm[p2_idx] = include_val
        end
    end
    c_perm[c_perm .== 0] = p2[c_perm .== 0]

    if ~hasUniqueValues(c_perm)
        throw("Child permutation must have unique values")
    end
    if sort(c_perm) != 1:n
        throw("Child must be a permutation") 
    end
    return c_perm, s
end

function PMXcx(p1::Solution,p2::Solution)
    # PMX crossover: http://www.rubicite.com/Tutorials/GeneticAlgorithms/CrossoverOperators/PMXCrossoverOperator.aspx
    c1_perm,s = PMXop(p1.permutation,p2.permutation) # Child 1
    c2_perm,_ = PMXop(p2.permutation,p1.permutation,s) # Child 2
    params = p1.params # TODO: p1.params and p2.params should be the same. Explicitly check if they are the same
    c1 = Solution(params,c1_perm)
    c2 = Solution(params,c2_perm)
    return (c1,c2)
end

function cycleop(p1::Array{Int64},p2::Array{Int64})
    n = length(p1)
    if ~((sort(p1) == 1:n) && (sort(p2) == 1:n))
        throw("Input parents must be permutation arrays") 
    end
    c_perm = zeros(Int, n)
    allcycles = []
    visited_idx = []

    p2_idx = 1
    p2_val = p2[1]

    # Identify all cycles
    while length(visited_idx) < n
        cycle = []
        p2_idx = findfirst(x -> ~(x in visited_idx), 1:n)
        p2_val = p2[p2_idx]
        start_val = p2_val
        p1_val = 0
        while (p1_val != start_val)
            append!(cycle,p2_idx)
            p1_idx = p2_idx
            p1_val = p1[p1_idx]
            p2_idx = findfirst(p2 .== p1_val)
            p2_val = p2[p2_idx]
        end
        append!(visited_idx,cycle)
        if length(cycle) > 1
            push!(allcycles,cycle)
        end
    end

    # Copy alternate cycles to child
    for (i,cycle) in enumerate(allcycles)
        if i % 2 == 0
            c_perm[cycle] = p2[cycle]
        else
            c_perm[cycle] = p1[cycle]
        end
    end

    c_perm[c_perm .== 0] = p1[c_perm .== 0]

    if ~hasUniqueValues(c_perm)
        throw("Child permutation must have unique values")
    end
    if sort(c_perm) != 1:n
        throw("Child must be a permutation") 
    end
    return c_perm
end

function cyclecx(p1::Solution,p2::Solution)
    # Cycle crossover: http://www.rubicite.com/Tutorials/GeneticAlgorithms/CrossoverOperators/CycleCrossoverOperator.aspx
    c1_perm = cycleop(p1.permutation,p2.permutation) # Child 1
    c2_perm = cycleop(p2.permutation,p1.permutation) # Child 2
    params = p1.params # TODO: p1.params and p2.params should be the same. Explicitly check if they are the same
    c1 = Solution(params,c1_perm)
    c2 = Solution(params,c2_perm)
    return (c1,c2)
end

function cohesiveMergecx(p1::Solution,p2::Solution)
    # Cohesive Merging crossover: Zvi Drezner, "A new Genetic Algorithm for the QAP"
    # TODO
    return (c1,c2)
end

function scrambledMergecx(p1::Solution,p2::Solution)
    # Scrambled Merging crossover: Zvi Drezner, "A new Genetic Algorithm for the QAP"
    # TODO
    return (c1,c2)
end


function recombinationOp(parents,recombine::Function=order1cx)::Array{Solution}
    offspring = Array{Solution}(undef, 0)
    for (p1,p2) in parents
        (c1,c2) = recombine(p1,p2)
        offspring = vcat(offspring, c1, c2)
    end
    return offspring
end