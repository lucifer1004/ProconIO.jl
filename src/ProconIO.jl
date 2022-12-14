module ProconIO

using MLStyle: @match, @as_record

export @input

@as_record struct ShapedArray
    typ
    shape
    dims
end

@as_record struct DynamicVector
    typ
end

@as_record struct TypedTuple
    types
end

@as_record struct TypedPair
    left
    right
end

function read_until_whitespace()
    chars = Char[]
    c = read(stdin, Char)
    while isspace(c)
        c = read(stdin, Char)
    end
    push!(chars, c)
    while !eof(stdin)
        c = read(stdin, Char)
        if isspace(c)
            break
        end
        push!(chars, c)
    end
    join(chars)
end

function parse_type(typ)
    @match typ begin
        Expr(:tuple, args...) => TypedTuple(parse_type.(args))
        Expr(:vcat, typ) => DynamicVector(parse_type(typ))
        Expr(:vcat, typ, shape) => ShapedArray(parse_type(typ), parse_shape(shape)...)
        Expr(:call, :(=>), left, right) => TypedPair(parse_type(left), parse_type(right))
        _ => eval(typ)
    end
end

function restore_type(typ)
    @match typ begin
        TypedTuple(types) => Tuple{restore_type.(types)...}
        TypedPair(left, right) => Pair{restore_type(left),restore_type(right)}
        ShapedArray(typ, _, dims) => Array{restore_type(typ),dims}
        DynamicVector(typ) => Vector{restore_type(typ)}
        _ => typ
    end
end

function walk!(arg, dict)
    @match arg begin
        ::Expr => begin
            for i in eachindex(arg.args)
                @match arg.args[i] begin
                    sym::Symbol => if string(sym) ∈ keys(dict)
                        arg.args[i] = dict[string(sym)]
                    end
                    expr::Expr => walk!(expr, dict)
                    _ => nothing
                end
            end
        end
        sym::Symbol => string(sym) ∈ keys(dict) ? dict[string(sym)] : sym
        _ => nothing
    end
end

function parse_shape(arg)
    dims = 1
    if !isa(arg, Expr) || arg.head != :tuple
        arg = Expr(:tuple, arg)
    else
        dims = length(arg.args)
    end

    return arg, dims
end

function read_array(typ, shape, dict)
    real_type = restore_type(typ)
    walk!(shape, dict)
    shape = eval(shape)
    arr = Array{real_type}(undef, shape)
    for index in CartesianIndices(shape)
        arr[index] = read_value(typ, dict)
    end
    return arr
end

function read_value(typ, dict)
    @match typ begin
        ::Type{String} => readline()
        ::Type{Char} => read_until_whitespace()[1]
        TypedTuple(types) => tuple(map(typ -> read_value(typ, dict), types)...)
        TypedPair(left, right) => read_value(left, dict) => read_value(right, dict)
        ShapedArray(typ, shape, _) => read_array(typ, shape, dict)
        DynamicVector(typ) => begin
            len = read_value(Int, dict)
            read_array(typ, (len,), dict)
        end
        _ => parse(typ, read_until_whitespace())
    end
end

"""
The usage is similar to [proconio-rs](https://github.com/statiolake/proconio-rs). You need to specify the variable name and its structure.

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

In CP, the size of arrays is usually specified by the input itself. This can be handled by using variables already read in.

Note that [ProconIO.jl](https://github.com/lucifer1004/ProconIO.jl) follows Julia's column-major convention, instead of the row-major which is commonly used in CP. So you may need to swap the row and column indices when reading the array.

```julia
@input begin
    n = Int
    m = Int
    v = [Int; (m, n)]
end
```

If you prefer a row-major flavor, you can use a vector of vectors instead.

```julia
@input begin
    n = Int
    m = Int
    v = [[Int; m]; n]
end
```

Sometimes the input is a vector of variable-length vectors. This can be handled by leaving out the shape and reading it from the input instead. The following code reads in a vector of `n` variable-length vectors.

```julia
@input begin
    n = Int
    v = [[Int; ]; n]
end
```
```
"""
macro input(expr)
    if expr.head != :block
        expr = Expr(:block, expr)
    end

    esc(quote
        local dict = Dict{String,Any}()

        $(map(filter(arg -> !isa(arg, LineNumberNode), expr.args)) do line
            sym, typ = line.args
            sym_str = string(sym)
            real_type = parse_type(typ)

            quote
                value = $read_value($real_type, dict)
                dict[$sym_str] = value
                $sym = value
            end
        end...)
    end)
end

end
