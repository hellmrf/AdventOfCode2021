using FilePathsBase
using FilePathsBase: /

function part1(input)
    h = v = 0
    for (dir, dist) in input 
        if dir == "forward"
            h += dist
        elseif dir == "down"
            v += dist
        elseif dir == "up"
            v -= dist
        end
    end
    @show h*v
end

function part2(input)
    h = v = aim = 0
    for (dir, dist) in input 
        if dir == "forward"
            h += dist
            v += aim * dist
        elseif dir == "down"
            aim += dist
        elseif dir == "up"
            aim -= dist
        end
    end
    return h * v
end


main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"day2.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String, SystemPath})
    input = open(filename, "r") do fl
        v = readlines(fl)
        [ (x[1], parse(Int, x[2])) for x ∈ split.(v, " ") ]
    end

    return main(input)
end

function main(input::Vector)
    return (part1(input), part2(input))
end
