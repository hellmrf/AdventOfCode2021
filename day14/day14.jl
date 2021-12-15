using FilePathsBase
using FilePathsBase: /
using OhMyREPL

struct Rule
    pair::Pair{String,Char}
end
function Rule(left::String, right::String)
    return Rule(left => right[1])
end
Rule(left::String, right::Char) = Rule(left, string(right))
function Rule(str::String)
    if !occursin(" -> ", str)
        error(ArgumentError("Rule must be in the form '<left> -> <right>'"))
    end

    splitted = split(str, " -> ")
    return Rule(splitted[1] => splitted[2][1])
end
function left(rule::Rule)
    return rule.pair.first
end
function right(rule::Rule)
    return rule.pair.second
end


function insertchar(str::String, char::Char, pos::Int, to = :right)
    if to == :left
        pos -= 1
    end
    return str[1:pos] * char * str[pos+1:end]
end

function insertstrs(str::String, toinsert::Vector{Tuple{Int,Char}})
    counter = 0
    for (i, char) ∈ toinsert
        str = insertchar(str, char, i + counter)
        counter += 1 # After each insertion, the String has one more char at the left, so we've to correct this here.
    end
    return str
end

function step(polymer::String, rules::Vector{Rule}, count_insertions = false)
    toinsert = Tuple{Int,Char}[]
    for i ∈ 1:length(polymer)-1
        for rule ∈ rules
            if polymer[i] == left(rule)[1] && polymer[i+1] == left(rule)[2]
                push!(toinsert, (i, right(rule)))
            end
        end
    end
    if count_insertions
        return insertstrs(polymer, toinsert), toinsert
    end
    return insertstrs(polymer, toinsert)
end


function runsteps(polymer::String, rules::Vector{Rule}, steps = 100)
    for _ = 1:steps
        polymer = step(polymer, rules, count_insertions)
    end
    return polymer
end


function part1(polymer::String, rules::Vector{Rule})::Int
    STEPS = 10
    polymer = runsteps(polymer, rules, STEPS)
    frequencies = countmap(polymer)
    min, max = dictextrema(frequencies)
    return max[2] - min[2]
end

function part2(polymer::String, rules::Vector{Rule})::Int
    return 0
end





main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    polymer, rules = open(filename, "r") do fl
        polymer = readline(fl)
        readline(fl) # ignore first blank line

        rules = [Rule(x) for x ∈ readlines(fl)]
        return polymer, rules
    end

    return main(polymer, rules)
end

function main(polymer::String, rules::Vector{Rule})
    return (part1(polymer, rules), part2(polymer, rules))
end