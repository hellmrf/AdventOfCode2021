using FilePathsBase: SystemPath
using OhMyREPL

include(joinpath(@__DIR__, "ALU.jl"))

using .ALU

function runfile(filename::Union{String, SystemPath})
    lines = readlines(string(filename))
    print("Inputs: ")
    input = readline() |> strip |> string
    result = runprogram(lines, input)
    global tr = result
    @show result
end
function runprogram(code::Vector{String}, input::AbstractString)::ALU.State
    program = ALU.Instruction.(code)
    inputs = string.(strip.(split(input, ",")))
    state = ALU.run(program, inputs)
    return state
end

function part1(lines::Vector{String})::Int
    return 0 
end

function part2(lines::Vector{String})::Int
    return 0 
end





main(::Type{Val{:demo}}) = main(joinpath(@__DIR__, "demo1.in"))
main(::Type{Val{:demo1}}) = main(joinpath(@__DIR__, "demo1.in"))
main(::Type{Val{:demo2}}) = main(joinpath(@__DIR__, "demo2.in"))
main(::Type{Val{:demo3}}) = main(joinpath(@__DIR__, "demo3.in"))
main(::Type{Val{:input}}) = main(joinpath(@__DIR__, "input.in"))
main(s::Symbol) = main(Val{s})

function main(filename::Union{String,SystemPath})
    lines = readlines(string(filename))
    return main(lines)
end

function main(lines::Vector{String})
    return (part1(lines), part2(lines))
end





function debug(st::Bool)
    ENV["JULIA_DEBUG"] = st ? Main : nothing
end
