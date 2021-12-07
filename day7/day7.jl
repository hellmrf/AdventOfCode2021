using FilePathsBase
using FilePathsBase: /

function align(positions::Vector{Int}, cost::Function)::Int
    best_fuel = Inf
    for here ∈ 1:maximum(positions)
        fuel = cost(positions, here)
        if fuel < best_fuel
            best_fuel = fuel
        end
    end
    return best_fuel
end

function fuel_consumption(pos1::Int, pos2::Int)::Int
    aₙ = n = abs(pos2 - pos1)
    a₁ = 1
    Sₙ = n * (a₁ + aₙ) / 2
    return Sₙ
end

function part1(positions::Vector{Int})::Int
    cost(pos, here) = sum(abs.(pos .- here))
    return align(positions, cost)
end

function part2(positions::Vector{Int})::Int
    cost(pos, here) = sum(fuel_consumption.(pos, here))
    return align(positions, cost)
end





main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    positions = open(filename, "r") do fl
        return parse.(Int, split(readline(fl), ","))
    end

    return main(positions)
end

function main(positions::Vector{Int})
    return (part1(positions), part2(positions))
end