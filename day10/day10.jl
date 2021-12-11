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
const SYNTAX_CONTESTS = Dict{Char, Int}(')' => 3, ']' => 57, '}' => 1197, '>' => 25137)
const AUTOCOMPLETE_CONTESTS = Dict{Char, Int}(')' => 1, ']' => 2, '}' => 3, '>' => 4)

function pair(c::Char)::Char
    PAIRS = Dict{Char, Char}('(' => ')', '[' => ']', '{' => '}', '<' => '>', ')' => '(', ']' => '[', '}' => '{', '>' => '<')
    return PAIRS[c]
end

function highlight_position(s::String, pos::Int)::String
    if pos < 1 || pos > length(s)
        error(ArgumentError("Invalid position"))
    end
    return s[1:pos-1] * "\033[1;31m" * s[pos] * "\033[0m" * s[pos+1:end]
end

function part1(lines::Vector{String})::Int
    errors = Dict{Char, Int}(')' => 0, ']' => 0, '}' => 0, '>' => 0)
    opened = Char[]
    for l ∈ lines
        for c ∈ l
            if c ∈ OPENERS
                push!(opened, c)
            elseif c ∈ CLOSERS
                if c == pair(opened[end])
                    pop!(opened)
                else
                    errors[c] += 1
                    break
                end
            end
        end
    end

    return sum(values(errors * SYNTAX_CONTESTS))
end

function autocomplete(line::String)::String
    opened = Char[]
    for c ∈ line
        if c ∈ OPENERS
            push!(opened, c)
        elseif c ∈ CLOSERS
            if c == pair(opened[end])
                pop!(opened)
            else
                return ""
            end
        end
    end
    return opened |> reverse .|> pair |> join
end

function score_completion(completion::String)::Int
    comp = collect(completion)
    score = 0
    for c ∈ comp
        score *= 5
        score += AUTOCOMPLETE_CONTESTS[c]
    end
    return score
end

function part2(lines::Vector{String})::Int
    scores = Int[]
    for l ∈ lines
        completion = autocomplete(l)
        if completion == ""
            continue
        end
        score = score_completion(completion)
        push!(scores, score)
    end

    sort!(scores)

    # I can use Int() because the problem ensures that we'll allways have an even number of lines.
    return Int(median(scores)) 
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