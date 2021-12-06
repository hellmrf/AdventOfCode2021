using FilePathsBase
using FilePathsBase: /
using DelimitedFiles
using Parsers

struct Point{T<:Number}
    x::T
    y::T
    Point(x::T, y::T) where {T} = new{T}(x, y)
    Point(x::Tuple{T,T}) where {T} = new{T}(x...)
    Point(x::Vector{T}) where {T} = new{T}(x...)
end

struct Pair{T<:Number}
    start::Point{T}
    stop::Point{T}
    Pair(x::Point{T}, y::Point{T}) where {T} = new{T}(x, y)
    Pair(x::Tuple{Point{T},Point{T}}) where {T} = new{T}(x...)
    Pair(x::Vector{Point{T}}) where {T} = new{T}(x...)
end

function dropdiagonals!(x::Vector{Pair{T}}) where {T}
    points_to_drop = Int[]
    @inbounds for i ∈ 1:length(x)
        (; start, stop) = x[i]
        if start.x != stop.x && start.y != stop.y
            push!(points_to_drop, i)
        end
    end
    return deleteat!(x, points_to_drop)
end

function get_board_size(x::Vector{Pair{T}})::Int where T
    size = 0
    for p ∈ x
        max_point = max(p.start.x, p.start.y, p.stop.x, p.stop.y)
        if max_point > size
            size = max_point
        end
    end
    return size+1
end

function part1(points::Vector{Pair{T}})::Int where {T}
    x = copy(points)
    dropdiagonals!(x)
    boardsize = get_board_size(x)
    board = fill(0, boardsize, boardsize)

    for pair ∈ x
        (; start, stop) = pair
        xs = start.x < stop.x ? (start.x+1:stop.x+1) : (stop.x+1:start.x+1)
        ys = start.y < stop.y ? (start.y+1:stop.y+1) : (stop.y+1:start.y+1)
        board[ys, xs] .+= 1
    end

    return count(>=(2), board)
end

"""
Return a tuple containing two functions: stepx and stepy, which knows how to step each component.
"""
function get_step_functions(p::Pair{T}) where T
    (; start, stop) = p
    if start.y == stop.y && start.x < stop.x
        return x->x+1, y->y # right
    elseif start.y == stop.y && start.x > stop.x
        return x->x-1, y->y # left
    elseif start.x == stop.x && start.y < stop.y
        return x->x, y->y+1 # down
    elseif start.x == stop.x && start.y > stop.y
        return x->x, y->y-1 # up
    elseif start.x < stop.x && start.y < stop.y
        return x->x+1, y->y+1 # down-right
    elseif start.x > stop.x && start.y < stop.y
        return x->x-1, y->y+1 # down-left
    elseif start.x < stop.x && start.y > stop.y
        return x->x+1, y->y-1 # up-right
    elseif start.x > stop.x && start.y > stop.y
        return x->x-1, y->y-1 # up-left
    end
end

function part2(points::Vector{Pair{T}})::Int where {T}
    x = points
    boardsize = get_board_size(x)
    board = fill(0, boardsize, boardsize)

    for pair ∈ x
        (; start, stop) = pair
        stepx, stepy = get_step_functions(pair)
        (;x, y) = start
        xstop, ystop = stop.x, stop.y
        while true
            board[y+1, x+1] += 1

            if x == xstop && y == ystop
                break
            else
                x = stepx(x)
                y = stepy(y)
            end
        end
    end

    return count(>=(2), board)
end






main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    points = open(filename, "r") do fl
        points_str = split.(readlines(fl), " -> ")
        points = [
            Pair(Point(parse.(Int, split(x[1], ","))), Point(parse.(Int, split(x[2], ",")))) for x ∈ points_str
        ]
        return points
    end
    # @show points
    global teste = points

    return main(points)
end

function main(points::Vector{Pair{T}}) where {T}
    return (part1(points), part2(points))
end
