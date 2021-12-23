using FilePathsBase
using FilePathsBase: /
using OhMyREPL
using SparseArrays
using OffsetArrays

@enum Power on=true off=false

struct RebootStep
    power::Power
    x::UnitRange{Int}
    y::UnitRange{Int}
    z::UnitRange{Int}
end
function RebootStep(power::AbstractString, x1::Int, x2::Int, y1::Int, y2::Int, z1::Int, z2::Int)
    if power ∉ ["on", "off"]
        error(ArgumentError("power must be 'on' or 'off'. Got $power."))
    end
    p = power == "on" ? on : off;
    return RebootStep(p, x1:x2, y1:y2, z1:z2);
end

"""
    restrict_region!(steps::Vector{RebootStep}, x::UnitRange{Int}, y::UnitRange{Int}, z::UnitRange{Int})

Restricts the range of each coordinate of each step to the given range. If the RebootStep is completely
outside the given region, it'll be removed.
"""
function restrict_region!(steps::Vector{RebootStep}, x::UnitRange{Int}, y::UnitRange{Int}, z::UnitRange{Int})
    todrop = Int[]
    for i ∈ eachindex(steps)
        step = steps[i];
        newx = intersect(step.x, x);
        newy = intersect(step.y, y);
        newz = intersect(step.z, z);
        steps[i] = RebootStep(step.power, newx, newy, newz);
        if any(map(x -> length(x) == 0, [newx, newy, newz]))
            push!(todrop, i);
        end
    end
    deleteat!(steps, todrop);
    return steps
end
function restrict_region(steps::Vector{RebootStep}, x::UnitRange{Int}, y::UnitRange{Int}, z::UnitRange{Int})
    return restrict_region!(copy(steps), x, y, z);
end


"""
    compute_boundary(steps::Vector{RebootStep})

Computes the boundary of the given steps. The boundary is defined as the smallest cuboid that
contains all the points of the steps.
"""
function compute_boundary(steps::Vector{RebootStep})
    x1 = y1 = z1 = typemax(Int)
    x2 = y2 = z2 = typemin(Int)
    for step ∈ steps
        x1 = min(x1, step.x.start);
        x2 = max(x2, step.x.stop);
        y1 = min(y1, step.y.start);
        y2 = max(y2, step.y.stop);
        z1 = min(z1, step.z.start);
        z2 = max(z2, step.z.stop);
    end
    return (x1:x2, y1:y2, z1:z2)
end

function part1(steps::Vector{RebootStep})::Int
    steps = restrict_region(steps, -50:50, -50:50, -50:50);
    xs, ys, zs = compute_boundary(steps)
    cubes = OffsetArray(fill(false, length(xs), length(ys), length(zs)), xs, ys, zs)

    for step ∈ steps
        cubes[step.x, step.y, step.z] .= Bool(step.power)
    end
    return count(cubes)
end

function part2(steps::Vector{RebootStep})::Int
    return 0 
end





main(::Type{Val{:demo}}) = main(Path(@__DIR__) / p"demo.in")
main(::Type{Val{:demo2}}) = main(Path(@__DIR__) / p"demo2.in")
main(::Type{Val{:input}}) = main(Path(@__DIR__) / p"input.in")
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    lines = readlines(string(filename))
    steps = RebootStep[]
    re = r"((?:o|n|f){2,3})\sx=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)"
    for line ∈ lines
        power, xyz... = match(re, line).captures
        x1, x2, y1, y2, z1, z2 = parse.(Int, xyz)
        push!(steps, RebootStep(power, x1, x2, y1, y2, z1, z2))
    end
    return main(steps)
end

function main(steps::Vector{RebootStep})
    return (part1(steps), part2(steps))
end