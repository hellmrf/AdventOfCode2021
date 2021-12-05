using FilePathsBase
using FilePathsBase: /
using DelimitedFiles
using Parsers

function mark_if_exists!(boardmarks, board, number::Int)
    pos = findfirst(==(number), board)
    if isnothing(pos)
        return boardmarks
    end
    boardmarks[pos] = true
    return boardmarks
end

function checkvictory(boardmarks)::Bool
    for col ∈ eachcol(boardmarks)
        if all(==(true), col)
            return true
        end
    end
    for line ∈ eachrow(boardmarks)
        if all(==(true), line)
            return true
        end
    end
    return false
end

function findwinner(boardsmarks, boards, numbers)::Tuple{Int, Int}
    for n ∈ numbers
        @inbounds for i ∈ 1:length(boardsmarks)
            mark_if_exists!(boardsmarks[i], boards[i], n)
            if checkvictory(boardsmarks[i])
                return i, n
            end
        end
    end
    return 0, n
end

function findloser(boardsmarks, boards, numbers)::Tuple{Int, Int}
    numboards = length(boards)
    victories = 0
    won = Int[]
    for n ∈ numbers
        @inbounds for i ∈ 1:length(boardsmarks)
            mark_if_exists!(boardsmarks[i], boards[i], n)
            if isnothing(findfirst(==(i), won)) && checkvictory(boardsmarks[i])
                victories += 1
                push!(won, i)
            end
            if victories == numboards
                return i, n
            end
        end
    end
    return 0, n
end

function part1(numbers::Vector{Int}, boards::Vector{Matrix{Int}})::Int
    boardsmarks = [fill(false, size(board)) for board ∈ boards]
    won, number = findwinner(boardsmarks, boards, numbers)

    notmarked = findall(==(false), boardsmarks[won])
    ∑ = sum(boards[won][notmarked]) 
    points = ∑ * number
    
    return points
end

function part2(numbers::Vector{Int}, boards::Vector{Matrix{Int}})::Int
    boardsmarks = [fill(false, size(board)) for board ∈ boards]
    lose, number = findloser(boardsmarks, boards, numbers)

    notmarked = findall(==(false), boardsmarks[lose])
    ∑ = sum(boards[lose][notmarked]) 
    points = ∑ * number
    
    return points
end






main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String, SystemPath})
    numbers, boards = open(filename, "r") do fl
        numbers = parse.(Int, split(readline(fl), ","))
        readline(fl) # skips the second (empty) line

        boards_str = String[]

        while true
            lines = [readline(fl) for _ ∈ 1:5]
            readline(fl)
            if lines[1] == ""
                break
            end
            push!(boards_str, join(lines, "\n"))
        end
        boards = readdlm.(IOBuffer.(boards_str), Int) 
        return numbers, boards
    end

    return main(numbers, boards)
end

function main(number::Vector{Int}, boards::Vector{Matrix{Int}})
    return (part1(number, boards), part2(number, boards))
end
