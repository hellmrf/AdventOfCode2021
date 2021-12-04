using FilePathsBase
using FilePathsBase: /


function power_consumption(input::Matrix{Bool})::Int
    γ = UInt16(0)
    m, n = size(input)
    half = m / 2
    for col ∈ eachcol(input)
        γ = γ << 1
        if count(col) > half
            γ += UInt16(1)
        end
    end

    ε = ~(γ << (16 - n)) >> (16 - n)

    return Int(γ) * Int(ε)
end

function oxygen_generator_rating(input::Matrix{Bool})::Int
    m, n = size(input)
    data = input 

    for j ∈ 1:n
        col = data[:, j]

        if length(col) == 1
            break
        end

        half = length(col) ÷ 2

        if count(!, col) <= half
            data = data[findall(col), :]
        else
            data = data[findall(!, col), :]
        end
    end

    return parse(Int, string(Int.(data[1, :])...), base = 2)
end

function CO₂_scrubber_rating(input::Matrix{Bool})::Int
    m, n = size(input)
    data = input

    for j ∈ 1:n
        col = data[:, j]

        if length(col) == 1
            break
        end

        half = length(col) ÷ 2

        if count(!, col) <= half
            data = data[findall(!, col), :]
        else
            data = data[findall(col), :]
        end
    end

    return parse(Int, string(Int.(data[1, :])...), base = 2)
end


life_support_rating(input::Matrix{Bool})::Int =
    oxygen_generator_rating(input) * CO₂_scrubber_rating(input)


main(s::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(s::Type{Val{:input}}) = main(Path(@__DIR__) / p"day3.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String, SystemPath})
    input = open(filename, "r") do fl
        v = split.(readlines(fl), "")
        return [parse(Bool, v[i][j]) for i ∈ 1:size(v)[1], j ∈ 1:size(v[1])[1]]
    end

    return main(input)
end

function main(input::Matrix{Bool})
    return (power_consumption(input), life_support_rating(input))
end
