using FilePathsBase: SystemPath
using OhMyREPL

"""
    myshow(mat::Matrix{Char})::Nothing

Space-effective `Matrix{Char}` display.
"""
function myshow(mat::Matrix{Char})::Nothing
    println(join(join.(eachrow(mat), ""), '\n'));
end


"""
    lookahead(mat::Matrix{Char}, i::Int, j::Int)::Tuple{Int, Int}

Check the next index to where the current cucumber will go in the next step.
If there's nowhere to go, return the current index (it'll remain in the same place).
"""
function lookahead(mat::Matrix{Char}, i::Int, j::Int)::Tuple{Int, Int}
    m, n = size(mat)
    if !checkbounds(Bool, mat, i, j)
        error(ArgumentError("($i, $j) out of bounds."))
    end
    action = mat[i, j]

    next_i, next_j = i, j

    if action == '>'
        next_j = j % n + 1
    elseif action == 'v'
        next_i = i % m + 1
    end

    if mat[next_i, next_j] == '.'
        return next_i, next_j
    else
        return i, j
    end        
end

"""
    nextstep(mat::Matrix{Char})::Matrix{Char}

Calculates the next step for `mat` and returns it.
"""
function nextstep(mat::Matrix{Char})::Matrix{Char}
    newmat = copy(mat)

    # East-facing cucumbers moves first
    for ind ∈ findall(==('>'), mat)
        i, j = ind.I
        here = mat[i, j]
        next_i, next_j = lookahead(mat, i, j)
        newmat[i, j] = '.'
        newmat[next_i, next_j] = here
    end
    mat = copy(newmat)

    # Now, South-facing cucumbers
    for ind ∈ findall(==('v'), mat)
        i, j = ind.I
        here = mat[i, j]
        next_i, next_j = lookahead(mat, i, j)
        newmat[i, j] = '.'
        newmat[next_i, next_j] = here
    end

    return newmat
end

function part1(mat::Matrix{Char})::Int
    @debug "Initial state:"
    @debug myshow(mat)

    lastmat = mat
    counter = 0
    while true
        mat = nextstep(lastmat)
        if mat == lastmat
            break
        else
            lastmat = mat
            counter += 1
        end
        @debug "\nAfter $counter steps:"
        @debug myshow(mat)
    end
    return counter + 1 # For some reason, the last step is counted twice in the AoC description.
end

function part2(mat::Matrix{Char})::Int
    global t = mat
    return 0
end





main(::Type{Val{:demo}}) = main(joinpath(@__DIR__, "demo.in"))
main(::Type{Val{:input}}) = main(joinpath(@__DIR__, "input.in"))
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    mat = permutedims(hcat(collect.(readlines(string(filename)))...))
    return main(mat)
end

function main(mat::Matrix{Char})
    return (part1(mat), part2(mat))
end
