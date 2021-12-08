using FilePathsBase
using FilePathsBase: /
using OhMyREPL

const Line = Tuple{Vector{String},Vector{String}};


function part1(lines::Vector{Line})::Int
    outputs = [x[2] for x ∈ lines]
    counter = 0
    for out ∈ outputs
        counter += count(x -> length(x) ∈ [2, 3, 4, 7], out)
    end
    return counter
end


function part2(lines::Vector{Line})::Int
    return 0
end




main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    lines = open(filename, "r") do fl
        pairs = split.(readlines(fl), "|")
        [tuple(Vector{String}.(split.(strip.(p), " "))...) for p ∈ pairs]
    end

    return main(lines)
end

function main(lines::Vector{Line})
    return (part1(lines), part2(lines))
end