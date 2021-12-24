module ALU

@enum Op inp add mul div mod eql
function Op(s::AbstractString)
    if s ∈ ["inp", "add", "mul", "div", "mod", "eql"]
        return eval(Symbol(s))
    else
        error(ArgumentError("Invalid ALU operation: $s"))
    end
end

@enum Var w x y z
function Var(s::Symbol)::Var
    if s ∈ [:w, :x, :y, :z]
        return eval(s);
    else
        error(ArgumentError("Invalid ALU register: $s"))
    end
end
function Var(s::AbstractString)::Var
    return Var(Symbol(s))
end

abstract type AbstractInstruction end

struct Inp <: AbstractInstruction
    var::Var
    val::Union{Int, Nothing}
end
struct Add <: AbstractInstruction
    operand::Var
    value::Union{Var, Int}
end
struct Mul <: AbstractInstruction
    operand::Var
    value::Union{Var, Int}
end
struct Div <: AbstractInstruction
    operand::Var
    value::Union{Var, Int}
end
struct Mod <: AbstractInstruction
    operand::Var
    value::Union{Var, Int}
end
struct Eql <: AbstractInstruction
    operand::Var
    value::Union{Var, Int}
end

# TODO: improve this implementation. Check if . and - occurs only once, and if - occurs only in the beginning.
function isnumeric(s::AbstractString)
    all(x -> x ∈ ['-'] || Base.isnumeric(x), s)
end

function Instruction(s::Op, operands...)::AbstractInstruction
    if s == inp
        return Inp(operands..., nothing);
    elseif s == add
        return Add(operands...);
    elseif s == mul
        return Mul(operands...);
    elseif s == div
        return Div(operands...);
    elseif s == mod
        return Mod(operands...);
    elseif s == eql
        return Eql(operands...);
    else
        error(ArgumentError("$s not implemented."))
    end
end
function Instruction(s::AbstractString)::AbstractInstruction
    op, operands... = split(s);
    op = Op(op);
    operands = map(x -> isnumeric(x) ? parse(Int, x) : Var(Symbol(x)), operands);
    return Instruction(op, operands...);
end
function Instruction(s::AbstractString, val::Int)::Inp
    op, operands... = split(s);
    op = Op(op);
    if op != inp
        error(ArgumentError("$s not an inp instruction. Use `Instruction(s::String)` instead."))
    elseif length(operands) != 1
        error(ArgumentError("Only one operand is expected for an inp instruction. Got $(length(operands))."))
    end
    operand = Var(operands...);
    return Inp(operand, val);
end

mutable struct State
    w::Int
    x::Int
    y::Int
    z::Int
end
function Base.getindex(s::State, v::Var)
    return getfield(s, Symbol(v));
end
function Base.setindex!(s::State, i::Int, v::Var)
    setfield!(s, Symbol(v), i)
end
function Base.setindex!(s::State, i::Number, v::Var)
    ii = Int(round(i))
    setfield!(s, Symbol(v), ii)
end

function valueof(s::State, v::Var)::Int
    return s[v]
end
function valueof(::State, v::Int)::Int
    return v
end

function run!(state::State, inst::Inp)::State
    state[inst.var] = valueof(state, inst.val)
    return state;
end
function run!(state::State, inst::Add)::State
    state[inst.operand] += valueof(state, inst.value)
    return state;
end
function run!(state::State, inst::Mul)::State
    state[inst.operand] *= valueof(state, inst.value)
    return state;
end
function run!(state::State, inst::Div)::State
    state[inst.operand] = state[inst.operand] ÷ valueof(state, inst.value)
    return state;
end
function run!(state::State, inst::Mod)::State
    state[inst.operand] = state[inst.operand] % valueof(state, inst.value)
    return state;
end
function run!(state::State, inst::Eql)::State
    state[inst.operand] = Int(valueof(state, inst.operand) == valueof(state, inst.value))
    return state;
end

function run!(state::State, program::Vector{AbstractInstruction}, io::Vector{<:AbstractString})
    @debug "io" io
    for inst ∈ program
        if inst isa Inp 
            length(io) == 0 && (error(ArgumentError("Not enough input values.")))
            input = popfirst!(io)
            oldinst = inst
            inst = Inp(inst.var, parse(Int, input));
            @debug "Inp" oldinst io input inst 
            state = run!(state, inst);
            # state = run!(state, inst, Int(input));
        else
            @debug "Instruction" inst
            run!(state, inst);
        end
        @debug "New state" state
    end
    if length(io) > 0
        @warn "The input wasn't entirely ingested. This can indicate a bug in your program."
    end
    return state;
end
function run(program::Vector{AbstractInstruction}, io::Vector{<:AbstractString})
    state = State(0, 0, 0, 0);
    return run!(state, program, io);
end

end