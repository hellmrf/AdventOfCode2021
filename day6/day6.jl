using FilePathsBase
using FilePathsBase: /

function stepday!(counters::Vector{Int})
    new_fishs = 0
    for i ∈ 1:length(counters)
        if counters[i] == 0
            counters[i] = 6
            new_fishs += 1
        else
            counters[i] -= 1
        end
    end
    append!(counters, fill(8, new_fishs))
    return counters
end

function life(counters::Vector{Int}, days::Int)
    x = copy(counters)
    for i ∈ 1:days
        stepday!(x)
    end
    return x
end

function individuals_after_n_days(counters::Vector{Int}, days::Int)
    return length(life(counters, days))
end

function part1(counters::Vector{Int})::Int
    return individuals_after_n_days(counters, 80)
end

############
## PART 2 ##
############

function stepday(d::Dict{Int, Int})
    dd = copy(d)
    for i ∈ Iterators.flatten((0:5, 7:7))
        dd[i] = d[i+1]
    end
    dd[6] = d[7] + d[0]
    dd[8] = d[0]
    return dd
end

function life(d::Dict{Int, Int}, days::Int)
    dd = d
    for _ ∈ 1:days
        dd = stepday(dd)
    end
    return dd
end

function individuals_after_n_days(d::Dict{Int, Int}, days::Int)
    return sum(values(life(d, days)))
end

function encode_counters_to_dict(counters::Vector{Int})::Dict{Int, Int}
    d = Dict(0=>0, 1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0)
    for c ∈ counters
        d[c] += 1
    end
    return d
end

function part2(counters::Vector{Int})::Int
    days2reproduce = encode_counters_to_dict(counters)
    return individuals_after_n_days(days2reproduce, 256)
end









main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    counters = open(filename, "r") do fl
        return parse.(Int, split(readline(fl), ","))
    end

    return main(counters)
end

function main(counters::Vector{Int})
    return (part1(counters), part2(counters))
end