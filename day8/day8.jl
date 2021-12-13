using FilePathsBase
using FilePathsBase: /
using OhMyREPL

##################
## DIGIT STRUCT ##
##################
struct Digit
    segments::Set{Char}
    correctly_mapped::Bool
    Digit(segments::String, correctly_mapped::Bool = true) =
        new(Set(collect(segments)), correctly_mapped)
    Digit(segments::Set{Char}, correctly_mapped::Bool = true) = new(segments, correctly_mapped)
end

segments(digit::Digit) = digit.segments

function correct_digit(digit::Digit, mapping::Dict{Char,Char})
    if digit.correctly_mapped
        return digit
    end
    reversed_mapping = Dict(v => k for (k, v) ∈ mapping)
    return Digit(Set{Char}([reversed_mapping[x] for x ∈ digit.segments]), true)
end

function Base.convert(::Type{T}, digit::Digit)::T where {T<:AbstractString}
    digit.segments |> collect |> sort |> join
end

function Base.convert(::Type{T}, digit::Digit)::T where {T<:Union{Int32,Int64}}
    if !digit.correctly_mapped
        error(
            ArgumentError(
                "Digit must be mapped to correct segments. Use correct_digit() with the appropriate mapping to correct it.",
            ),
        )
    end

    conversor = Dict(
        Set(collect("abcefg")) => 0,
        Set(collect("cf")) => 1,
        Set(collect("acdeg")) => 2,
        Set(collect("acdfg")) => 3,
        Set(collect("bcdf")) => 4,
        Set(collect("abdfg")) => 5,
        Set(collect("abdefg")) => 6,
        Set(collect("acf")) => 7,
        Set(collect("abcdefg")) => 8,
        Set(collect("abcdfg")) => 9,
    )
    return conversor[digit.segments]
end

(::Type{T})(digit::Digit) where {T<:Union{Int32,Int64}} = convert(T, digit)
Base.string(digit::Digit) = convert(String, digit)
Base.length(digit::Digit) = length(digit.segments)

######################
## HELPER FUNCTIONS ##
######################

const Line = Tuple{Vector{Digit},Vector{Digit}};

function Base.:-(s1::Set{T}, s2::Set{T})::Set{T} where {T} 
    return setdiff(s1, s2)
end
function Base.:-(s1::Set{T}, v::T)::Set{T} where {T}
    s2 = copy(s1)
    delete!(s2, v)
    return s2
end

function Δ(s1::Set{T}, s2::Set{T})::Set{T} where {T} 
    return symdiff(s1, s2)
end
Δ(d1::Digit, d2::Digit)::Set{Char} = Δ(d1.segments, d2.segments)

function part1(lines::Vector{Line})::Int
    outputs = [x[2] for x ∈ lines]
    counter = 0
    for out ∈ outputs
        counter += count(x -> length(x) ∈ [2, 3, 4, 7], out)
    end
    return counter
end

Base.sort(s::String)::String = s |> collect |> sort |> join

"""
    unwrap_one(s::Set)

unwrap a Set containing a single element to that element
"""
function unwrap_one(s::Set)
    if length(s) > 1
        error(ArgumentError("Set must contain exactly one element."))
    end
    return collect(s)[1]
end

"""
    find_mapping(input::Vector{Digit})::Dict{Char,Char}

find the mapping that makes the input digits correct
"""
function find_mapping(input::Vector{Digit})::Dict{Char,Char}
    # 1, 4, 7 and 8 are known by the length
    digits = Dict{Int,Digit}(
        1 => input[findfirst(x -> length(x) == 2, input)],
        4 => input[findfirst(x -> length(x) == 4, input)],
        7 => input[findfirst(x -> length(x) == 3, input)],
        8 => input[findfirst(x -> length(x) == 7, input)],
    )

    mapping = Dict{Char,Union{Char,Nothing}}(
        'a' => nothing,
        'b' => nothing,
        'c' => nothing,
        'd' => nothing,
        'e' => nothing,
        'f' => nothing,
        'g' => nothing,
    )

    # 7 - 1 = A
    mapping['a'] = unwrap_one(digits[7].segments - digits[1].segments)

    # length(Δ(2, 5)) = 4
    # Δ(2, 5) = {C, E, B, F}
    # Δ(2, 5) ∩ (4 – 1) = B
    four_minus_one = (digits[4].segments - digits[1].segments)
    fivenumbers = [x for x ∈ input if length(x) == 5]
    Δ25 = 0
    for i ∈ 1:(length(fivenumbers) - 1), j ∈ (i+1):length(fivenumbers)
        delta = Δ(fivenumbers[i], fivenumbers[j])
        if length(delta) == 4
            Δ25 = delta
            break
        end
    end
    mapping['b'] = unwrap_one(Δ25 ∩ four_minus_one)

    # B ∉ Δ(2, 3)
    # Δ(2, 5) – Δ(2, 3) – B = C
    Δ23 = 0
    for i ∈ 1:length(fivenumbers) - 1, j ∈ (i+1):length(fivenumbers)
        delta = Δ(fivenumbers[i], fivenumbers[j])
        if mapping['b'] ∉ delta
            Δ23 = delta
            break
        end
    end
    mapping['c'] = unwrap_one((Δ25 - Δ23) - mapping['b'])

    # 1 – {C} = F
    mapping['f'] = unwrap_one(segments(digits[1]) - mapping['c'])

    # 4 – {B, C, F} = D
    mapping['d'] =
        unwrap_one(segments(digits[4]) - mapping['b'] - mapping['c'] - mapping['f'])

    # b ∈ 5
    # 5 – {A, B, D, F} = G
    digits[5] = fivenumbers[findfirst(x -> mapping['b'] ∈ segments(x), fivenumbers)]
    mapping['g'] = unwrap_one(
        segments(digits[5]) - mapping['a'] - mapping['b'] - mapping['d'] - mapping['f'],
    )

    # The other is E
    mapping['e'] = unwrap_one(
        segments(digits[8]) - Set{Char}(filter(!isnothing, collect(values(mapping)))),
    )

    return mapping
end

function part2(lines::Vector{Line})::Int
    sum = 0
    for line ∈ lines
        input, output = line
        mapping = find_mapping(input)
        corrected_output = [correct_digit(dig, mapping) for dig ∈ output]
        sum += parse(Int, join(string.(Int.(corrected_output))))
    end

    return sum
end





main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    lines = open(filename, "r") do fl
        pairs = split.(readlines(fl), "|")
        list = [tuple(Vector{String}.(split.(strip.(p), " "))...) for p ∈ pairs]
        [(Digit.(x[1], false), Digit.(x[2], false)) for x ∈ list]
    end

    return main(lines)
end

function main(lines::Vector{Line})
    return (part1(lines), part2(lines))
end