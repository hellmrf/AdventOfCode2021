using FilePathsBase
using FilePathsBase: /
using OhMyREPL

function Base.:*(d1::Dict{T1, T2}, d2::Dict{T1, T2})::Dict{T1, T2} where {T1, T2 <: Number}
    if keys(d1) != keys(d2)
        error(ArgumentError("Dictionaries have different keys"))
    end
    d3 = Dict{T1, T2}()
    @inbounds for k in keys(d1)
        d3[k] = d1[k] * d2[k]
    end
    return d3
end

const OPENERS = Char['(', '{', '[', '<']
const CLOSERS = Char[')', '}', ']', '>']
const PENALTIES = Dict{Char, Int}(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)
const PAIRS = Dict{Char, Char}(')' => '(', ']' => '[', '}' => '{', '>' => '<')

function part1(lines::Vector{String})::Int
    errors = Dict{Char, Int}(')' => 0, ']' => 0, '}' => 0, '>' => 0)
    opened = Char[]
    for l ∈ lines
        for c ∈ l
            if c ∈ OPENERS
                push!(opened, c)
            elseif c ∈ CLOSERS
                if PAIRS[c] == opened[end]
                    pop!(opened)
                else
                    errors[c] += 1
                    break
                end
            end
        end
    end

    return sum(values(errors * PENALTIES))
end

function part2(lines::Vector{String})::Int
    return 0
end





main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    return main(readlines(string(filename)))
end

function main(lines::Vector{String})
    return (part1(lines), part2(lines))
end