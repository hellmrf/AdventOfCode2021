using FilePathsBase
using FilePathsBase: /
using OhMyREPL
using StatsBase

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

function pairs(rule::Rule)
    return [left(rule)[1]*right(rule), right(rule)*left(rule)[2]]
end
 
struct Polymer
    polymer::Dict{String, Int}
end

function Polymer(polymer_str::String)::Polymer
    p = Dict{String, Int}();
    for i ∈ 1:length(polymer_str)-1
        str = polymer_str[i:i+1]
        p[str] = haskey(p, str) ? p[str] + 1 : 1;
    end
    return Polymer(p)
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

function step(polymer::String, rules::Vector{Rule})
    toinsert = Tuple{Int,Char}[]
    for i ∈ 1:length(polymer)-1
        for rule ∈ rules
            if polymer[i] == left(rule)[1] && polymer[i+1] == left(rule)[2]
                push!(toinsert, (i, right(rule)))
            end
        end
    end
    return insertstrs(polymer, toinsert)
end

function step(polymer::Polymer, rules::Vector{Rule})
    (; polymer) = polymer
    newpolymer = Dict(k => 0 for k ∈ keys(polymer))

    for rule ∈ rules
        leftrule = left(rule)
        if !haskey(polymer, leftrule)
            continue
        end
        occurences = polymer[leftrule] 
        for p ∈ pairs(rule)
            newpolymer[p] = haskey(newpolymer, p) ? newpolymer[p] + occurences : occurences
        end
    end
    
    return Polymer(newpolymer)
end

function dictextrema(d::Dict)
    mink = maxk = maxv = 0
    minv = Inf
    for (k, v) ∈ d
        if v < minv
            minv, mink = v, k
        end
        if v > maxv
            maxv, maxk = v, k
        end
    end
    return ((mink, minv), (maxk, maxv))
end


function runsteps(polymer, rules::Vector{Rule}, steps = 100)
    for _ = 1:steps
        polymer = step(polymer, rules)
    end
    return polymer
end

function countchars(polymer::Polymer, initialpolymer::String)::Dict{Char, Int}
    # The only character that doesn't begin a pair is the last character.
    lastchar = initialpolymer[end]
    counter = Dict{Char, Int}(lastchar => 1)

    for (k, v) ∈ polymer.polymer
        if haskey(counter, k[1])
            counter[k[1]] += v
        else
            counter[k[1]] = v
        end
    end

    return counter
end


"""
    part1(polymer::String, rules::Vector{Rule})::Int
I used the plain and simple "do everything and count" approach. Obviously this doesn't work for the second part. 
However, the complexity of the implementation is directly linked to the requirements of the problem.
Because of that, I'm keeping the simple solution and adding the improved one for the second part.
"""
function part1(polymer::String, rules::Vector{Rule})::Int
    STEPS = 10
    polymer = runsteps(polymer, rules, STEPS)
    frequencies = countmap(polymer)
    de = dictextrema(frequencies)
    min, max = de
    return max[2] - min[2]
end

"""
    part2(polymer::String, rules::Vector{Rule})::Int
Here I'm using an improved (actually totally reimplemented) approach to solve the problem.
This new implementation uses a space complexity of O(1), and a time complexity of O(n*m) (with n being the number of Rules and m being the number of steps).
The ideia is to parse the polymer string into a Polymer type, which is a Dict{String, Int} that counts how many times each pair occurs in the polymer.
Then, the process of insertions, i.e. NN -> C, is basically set NN to 0 and NC and CN to the number of time NN occurred first.
"""
function part2(polymer_str::String, rules::Vector{Rule})::Int
    STEPS = 40
    polymer = Polymer(polymer_str)
    lastpolymer = runsteps(polymer, rules, STEPS)
    countmap = countchars(lastpolymer, polymer_str)
    de = dictextrema(countmap)
    min, max = de
    return max[2] - min[2]
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