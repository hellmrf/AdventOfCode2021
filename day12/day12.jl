using OhMyREPL
using FilePathsBase: SystemPath

######################
## HELPER FUNCTIONS ##
######################
isupper(s::AbstractString)::Bool = all(isuppercase, s)

######################
## TYPE DEFINITIONS ##
######################
abstract type Cave end
struct StartCave <: Cave 
end
struct EndCave <: Cave 
end
struct BigCave <: Cave
    name::String
end
struct SmallCave <: Cave
    name::String
end
function Cave(cave::AbstractString)::Cave
    cave == "start" && return StartCave()
    cave == "end" && return EndCave()
    isupper(cave) && return BigCave(cave)
    return SmallCave(cave)
end

Base.string(::StartCave) = "start"
Base.string(::EndCave) = "end"
Base.string(x::Cave) = x.name

const Connection = Tuple{Cave, Cave}
const ConnectionModel = Dict{Cave, Vector{Cave}}

###############
## FUNCTIONS ##
###############

function appendtokey!(dict::Dict{TK, Vector{TV}}, k::TK, v::TV) where {TK, TV}
    if haskey(dict, k)
        push!(dict[k], v)
    else
        dict[k] = TV[v]
    end
    return dict
end

function model_connections(connlist::Vector{Connection})::ConnectionModel
    conns = ConnectionModel()
    for conn ∈ connlist
        appendtokey!(conns, conn[1], conn[2])
        appendtokey!(conns, conn[2], conn[1])
    end
    return conns
end

"""
    drop_redundant_connections(connmodel::ConnectionModel)

Connections of the type SmallCave(?) => SmallCave[?, ?] are redundant because, 
    if a SmallCave is only connected with SmallCaves, is impossible to get back 
    from there, as any route would pass by a SmallCave again.
Connections of the type EndCave() => Any[] are redundant because we'll never
    get back once we get to the end.
Connections of the type Cave() => [StartCave(), ...] are redundant because
    it's impossible to get back to the StartCave, as it's necessarily an SmallCave.
We can then drop these connections.
"""
function drop_redundant_connections!(connmodel::ConnectionModel)
    for (k, v) ∈ connmodel
        if k isa EndCave || (k isa SmallCave && all(x -> x isa SmallCave, v))
            delete!(connmodel, k)
        else
            filter!(x -> !isa(x, StartCave), connmodel[k])
        end
    end
end

"""
    stringify_path(path::Vector{Cave})

Takes a path (Vector{Cave}) and returns the string representation, just like the problem description.

# Examples:
```julia
julia> stringify_path([StartCave(), BigCave("A"), SmallCave("c"), BigCave("A"), SmallCave("b"), BigCave("A"), EndCave()])
"start,A,c,A,b,A,end"
julia> stringify_path([StartCave(), BigCave("A"), SmallCave("c"), BigCave("A"), SmallCave("b"), BigCave("A")])
"start,A,c,A,b,A,end"
```
"""
function stringify_path(path::Vector{Cave})
    if !isa(path[end], EndCave)
        return join(string.(path), ",") * ",end"
    end
    return join(string.(path), ",")
    
end

"""
    showpaths(p::Set{Vector{Cave}})

Prints all paths contained in the Set `p` and its length.

# Examples
```julia
julia> p = Set([[StartCave(), Cave("A"), EndCave()], [StartCave(), Cave("A"), Cave("c"), Cave("A"), EndCave()]]);

julia> showpaths(p)
┌ Info: Found 2 paths:
│ start,A,c,A,end
└ start,A,end
```
"""
function showpaths(p::Set{Vector{Cave}})::Nothing
    @info "Found $(length(p)) paths:\n$(join(stringify_path.(p), "\n"))" 
end

"""
    followpath(connmodel::ConnectionModel)::Set{Vector{Cave}}

Returns a Set containing all possible paths to go from `StartCave()` to `EndCave()`, visiting each `SmallCave` at most once.

    followpath(connmodel::ConnectionModel, at::Cave, visited::Vector{Cave}=Cave[])

Recursively visits all paths going from `at` to `EndCave()`, visiting each `SmallCave` at most once and avoiding any `SmallCave` listed in `visited`.
Returns a Set of the paths found.
"""
function followpath(connmodel::ConnectionModel, at::Cave=StartCave(), visited::Vector{Cave}=Cave[])
    todrop(x) = !isa(x, BigCave) && x ∈ visited
    if !haskey(connmodel, at) # Nowhere to go.
        return Set{Vector{Cave}}()
    end

    neighbours = filter(!todrop, connmodel[at])

    if length(neighbours) == 0 # Nowhere to go.
        return Set{Vector{Cave}}()
    end

    paths = Set{Vector{Cave}}()

    for neighbour ∈ neighbours
        new_paths = followpath(connmodel, neighbour, Cave[visited..., at])
        length(new_paths) == 0 && continue
        push!(paths, new_paths...)
    end
    return paths
end

"""
    followpath(::ConnectionModel, ::EndCave, visited::Vector{Cave}=Cave[])

Returns a Set contaning the path used to get to the EndCave(). It's also the base case (or base method?) for the recursive function, but in a Multiple Dispatch world!
"""
function followpath(::ConnectionModel, ::EndCave, visited::Vector{Cave}=Cave[])
    return Set{Vector{Cave}}([visited])
end


##############
## SOLUTION ##
##############
function part1(connections::Vector{Connection})::Int
    model = model_connections(connections)
    drop_redundant_connections!(model)
    p = followpath(model)
    return length(p) 
end

function part2(connections::Vector{Connection})::Int
    return 0
end








main(::Type{Val{:demo}}) = main(joinpath(@__DIR__, "demo.in"))
main(::Type{Val{:demo2}}) = main(joinpath(@__DIR__, "demo2.in"))
main(::Type{Val{:demo3}}) = main(joinpath(@__DIR__, "demo3.in"))
main(::Type{Val{:input}}) = main(joinpath(@__DIR__, "input.in"))
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    lines = readlines(string(filename))
    conns = [tuple(Cave.(split(line, "-"))...) for line ∈ lines]
    global t = conns
    return main(conns)
end

function main(connections::Vector{Connection})
    return (part1(connections), part2(connections))
end