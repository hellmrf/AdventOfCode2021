using FilePathsBase
using FilePathsBase: /

function part1(input)
    increased_counter = 0
    for i ∈ 2:length(input)
        if input[i] > input[i-1]
            increased_counter += 1
        end
    end

    return increased_counter
end

function part2(input)
    increased_counter = 0
    last_measurement = 0
    for i ∈ 3:length(input)
        ∑ = sum(input[i-2:i])
        if ∑ > last_measurement > 0
            increased_counter += 1
        end
        last_measurement = ∑
    end
    return increased_counter;
end

main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"day1.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String, SystemPath})
    input = open(filename, "r") do fl
        parse.(Int, readlines(fl))
    end

    return main(input)
end

function main(input::Vector{Int})
    return (part1(input), part2(input))
end
