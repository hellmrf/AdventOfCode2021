using FilePathsBase
using FilePathsBase: /
using OhMyREPL

function get_adjacents(mat::Matrix{Int}, i::Int, j::Int)
    m, n = size(mat)
    irange = i == m ? i - 1 : i == 1 ? i + 1 : [i - 1, i + 1]
    jrange = j == n ? j - 1 : j == 1 ? j + 1 : [j - 1, j + 1]
    return (irange, jrange)
end

function get_adjacents_values(mat::Matrix{Int}, i::Int, j::Int)
    irange, jrange = get_adjacents(mat, i, j)
    return [mat[irange, j]..., mat[i, jrange]...]
end

function part1(mat::Matrix{Int})::Int
    m, n = size(mat)
    sum = 0
    for i ∈ 1:m, j ∈ 1:n
        adj = get_adjacents_values(mat, i, j)
        if all(mat[i, j] .< adj)
            sum += mat[i, j] + 1
        end
    end
    return sum
end

±(a, b) = (a + b, a - b)

function follow_positive_gradient(mat, i, j, memory=Tuple{Int, Int}[])
    irange, jrange = get_adjacents(mat, i, j)
    val = mat[i, j]
    if val == 9
        return Set{Tuple{Int, Int}}()
    end
    positions = Set{Tuple{Int, Int}}([(i, j)])
    push!(memory, (i, j))
    for i′ ∈ irange
        if (i′, j) ∉ memory && mat[i′, j] ∈ val ± 1 && mat[i′, j] != 9
            positions = positions ∪ Set([(i′, j)])
            nexts = follow_positive_gradient(mat, i′, j, memory)
            positions = positions ∪ nexts
        end
    end
    for j′ ∈ jrange
        if (i, j′) ∉ memory && mat[i, j′] ∈ val ± 1 && mat[i, j′] != 9
            positions = positions ∪ Set([(i, j′)])
            nexts = follow_positive_gradient(mat, i, j′, memory)
            positions = positions ∪ nexts
        end
    end

    return positions
end

function part2(mat::Matrix{Int})::Int
    greatests = Int[]
    saved_basins = Set{Tuple{Int,Int}}[]
    m, n = size(mat)
    for i ∈ 1:m, j ∈ 1:n
        basin = follow_positive_gradient(mat, i, j)
        basinsize = length(basin)

        if basin ∈ saved_basins
            continue
        else
            push!(saved_basins, basin)
        end

        if length(greatests) < 3 && length(basin) > 0
            push!(greatests, basinsize)
        elseif any(basinsize .> greatests)
            deleteat!(greatests, argmin(greatests))
            push!(greatests, basinsize)
        end
    end
    return reduce(*, greatests)
end


main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    mat = permutedims(parse.(Int, hcat(split.(readlines(string(filename)), "")...)))
    global t = mat
    return main(mat)
end

function main(mat::Matrix{Int})
    return (part1(mat), part2(mat))
end