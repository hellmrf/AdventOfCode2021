using FilePathsBase
using FilePathsBase: /
using OhMyREPL
using SparseArrays
using UnicodePlots

const Point = Tuple{Int, Int}

abstract type Line end
struct VerticalLine <: Line
    pos::Int
end
struct HorizontalLine <: Line
    pos::Int
end

function fold(mat::BitMatrix, line::VerticalLine) 
    (; pos) = line;
    restmatrix = mat[:, 1:pos-1]
    foldmatrix = mat[:, pos+1:end]
    foldedmatrix = reverse(foldmatrix, dims=2)
    return restmatrix .|| foldedmatrix
end

function fold(mat::BitMatrix, line::HorizontalLine) 
    (; pos) = line;
    restmatrix = mat[1:pos-1, :]
    foldmatrix = mat[pos+1:end, :]
    foldedmatrix = reverse(foldmatrix, dims=1)
    return restmatrix .|| foldedmatrix
end

"""
    points_maxima(points::Vector{Point})::Tuple{Int, Int}
I tried to get the maxima with the beautiful `max.(points...)`. Although it works with :demo, it raises an unhandled StackOverflow (from the C side).
So I implemented this simple function to do this using the simple for-loop approach.
"""
function points_maxima(points::Vector{Point})::Tuple{Int, Int}
    maxx = maxy = 0
    for (x, y) ∈ points 
        x > maxx && (maxx = x)
        y > maxy && (maxy = y)
    end
    return (maxx, maxy)
end

function assemble_matrix(points::Vector{Point})::BitMatrix
    n, m = points_maxima(points) .+ 1
    matrix = falses(m, n)
    for (x, y) ∈ points
        matrix[y+1, x+1] = true
    end
    return matrix
end

function part1(points::Vector{Point}, instructions::Vector{Line})::Int
    matrix = fold(assemble_matrix(points), instructions[1])
    return count(matrix)
end

function part2(points::Vector{Point}, instructions::Vector{Line})
    matrix = assemble_matrix(points)
    
    for instruction ∈ instructions
        matrix = fold(matrix, instruction)
    end

    return spy(sparse(matrix))
end





main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    points = Tuple{Int, Int}[]
    points, instructions = open(filename) do fl
        while true
            line = readline(fl)
            if line == ""
                break
            end
            push!(points, tuple(parse.(Int, split(line, ","))...))
        end
        instructions = Line[]
        for line ∈ readlines(fl) 
            line = line[12:end]
            axis, pos = split(line, "=")
            pos = parse(Int, pos)
            push!(instructions, axis == "x" ? VerticalLine(pos+1) : HorizontalLine(pos+1))
        end
        return points, instructions
    end

    return main(points, instructions)
end

function main(points::Vector{Point}, instructions::Vector{Line})
    Part1 = part1(points, instructions)
    Part2 = part2(points, instructions)
    @info "Results" Part1 Part2
end