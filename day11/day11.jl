using FilePathsBase
using FilePathsBase: /
using OhMyREPL

function get_adjacents(mat::Matrix{Int}, i::Int, j::Int)
    m, n = size(mat)
    irange = max(1, i-1):min(m, i+1)
    jrange = max(1, j-1):min(n, j+1)
    return mat[irange, jrange]
end

function restore_coordinates(i::Int, j::Int, i′::Int, j′::Int)
    i2 = i == 1 ? i′ : i + i′ - 2
    j2 = j == 1 ? j′ : j + j′ - 2
    return (i2, j2)
end

function flash!(mat::Matrix{Int}, i::Int, j::Int)::Tuple{Matrix{Int}, Int}
    if mat[i, j] < 10
        @warn "No need to flash at position ($i, $j)."
        return mat, 0
    end

    mat[i, j] = 0 # Ok, piscou

    adjacents = get_adjacents(mat, i, j)
    m′, n′ = size(adjacents)
    for i′ ∈ 1:m′, j′ ∈ 1:n′
        if adjacents[i′, j′] == 0 # Esse cara já piscou, tenho certeza.
            continue
        end 
        mat[restore_coordinates(i, j, i′, j′)...] += 1
    end

    return mat, 1
end
function flash(mat::Matrix{Int}, i::Int, j::Int)
    mat2 = copy(mat)
    return flash!(mat2, i, j)
end

function step!(mat::Matrix{Int})
    m, n = size(mat)
    mat .+= 1

    counter = 0
    inner_counter = 1
    while inner_counter > 0
        inner_counter = 0
        for i ∈ 1:m, j ∈ 1:n
            if mat[i, j] > 9
                _, cntr = flash!(mat, i, j)
                inner_counter += cntr
            end
        end
        counter += inner_counter
    end
    return mat, counter
end
function step(mat::Matrix{Int})
    return step!(copy(mat))
end

function part1!(mat::Matrix{Int})::Int
    STEPS = 100
    counter = 0
    for _ ∈ 1:STEPS
        _, cntr = step!(mat)
        counter += cntr
    end

    return counter 
end

function part2!(mat::Matrix{Int})::Int
    n_elems = prod(size(mat))
    step = 0
    while true
        _, cntr = step!(mat)
        step += 1
        cntr == n_elems && (break)
    end
    return step
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
    return (part1!(copy(mat)), part2!(copy(mat)))
end