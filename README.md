# ProconIO.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://lucifer1004.github.io/ProconIO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lucifer1004.github.io/ProconIO.jl/dev/)
[![Build Status](https://github.com/lucifer1004/ProconIO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lucifer1004/ProconIO.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lucifer1004/ProconIO.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lucifer1004/ProconIO.jl)

Inspired by [proconio-rs](https://github.com/statiolake/proconio-rs), I wrote this package to handle inputs for competitive programming contests.

The usage is similar to `proconio-rs`. You need to specify the variable name and its structure.

```julia
@input a = Int
```

Multiple variables need to be nested in a block.

```julia
@input begin
    a = Char
    b = Float32
    c = (Int, Char)
    d = String
    e = Bool
end
```

Arrays need to be specified in the form of `[type; shape]`.

```julia
@input begin
    a = [Int; 3]
    b = [Float32; (2, 3)]
end
```

Complex structures can also be handled.

```julia
@input a = [(Int, [Int; (2, 2)], Char); (2, 2)]
```
