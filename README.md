# Advent Of Code 2021
>Héliton Martins

These are my solution in [Julia](https://julialang.org/) for [AdventOfCode2021](https://adventofcode.com/2021). As I'm currently very busy, I'm not trying to find the best or cleverest solutions, but rather I just want to finish the challenge.

Each day is placed inside its own folder, with `dayn.jl` being the code, `demo.in` being the example available with the problem description (although sometimes there are `demo1.in`, `demo2.in` and so on), and `input.in` being my own puzzle input.

I'll probably use features available on Julia 1.7, so be aware of this. To run each program, just `include()` the code in your REPL and you'll have three options to call the `main` function:

```julia
julia> main(:demo) # run the program for the demo input
(7, 5)
julia> main(:input) # run the program for my own input
(1665, 1702)
julia> main("/path/to/any/input.txt") # run the program with the input specified
```

The `main` function always return a tuple containing the answer for the two parts of the problem, in the format `(part1, part2)`, except for Day 13, in which it returns `nothing` and prints the result (I could write a parser for the second part and return a `Tuple{Int, String}`, but I won't).

## Contact
You can contact me on [Telegram](https://t.me/helitonmrf).