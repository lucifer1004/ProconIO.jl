module ProconIO

using MLStyle: @match, @as_record

export @input, @as_record

function read_until_whitespace()
    chars = Char[]
    c = read(stdin, Char)
    while isspace(c)
        c = read(stdin, Char)
    end
    push!(chars, c)
    while true
        c = read(stdin, Char)
        if isspace(c)
            break
        end
        push!(chars, c)
    end
    join(chars)
end

function parse_type(typ, dict)
    @match typ begin
        Expr(:tuple, args...) => Tuple{map(arg -> parse_type(arg, dict), args)...}
        Expr(:vect, args...) => begin
            real_types = parse_type.(args)
            if length(real_types) >= 1 && all(t <: real_types[1] for t in real_types)
                Vector{real_types[1]}
            else
                Vector{Any}
            end
        end
        Expr(:vcat, typ, shape) => Array{parse_type(typ, dict),length(parse_shape(shape, dict))}
        Expr(:call, :(=>), left, right) => Pair{parse_type(left, dict),parse_type(right, dict)}
        _ => eval(typ)
    end
end

function walk!(arg, dict)
    @match arg begin
        ::Expr => begin
            for i in eachindex(arg.args)
                @match arg.args[i] begin
                    ::Symbol => if arg.args[i] in keys(dict)
                        arg.args[i] = dict[arg.args[i]]
                    end
                    ::Expr => walk!(arg.args[i], dict)
                    _ => nothing
                end
            end
        end
        ::Symbol => dict[arg]
        _ => nothing
    end
end

function parse_shape(arg, dict)
    if !isa(arg, Expr) || arg.head != :tuple
        arg = Expr(:tuple, arg)
    end
    walk!(arg, dict)
    return eval(arg)
end

function read_array(typ, shape, dict)
    real_type = parse_type(typ, dict)
    arr = Array{real_type}(undef, shape)
    for index in CartesianIndices(shape)
        arr[index] = read_value(typ, dict)
    end
    return arr
end

function read_value(typ, dict)
    @show typ
    @match typ begin
        :String => readline()
        :Char => read_until_whitespace()[1]
        Expr(:tuple, args...) => tuple(map(arg -> read_value(arg, dict), args)...)
        Expr(:vect, args...) => map(read_value, args)
        Expr(:vcat, typ, shape) => read_array(typ, parse_shape(shape, dict), dict)
        Expr(:call, :(=>), left, right) => read_value(left, dict) => read_value(right, dict)
        _ => parse(eval(typ), read_until_whitespace())
    end
end

macro input(expr)
    dict = Dict{Symbol,Any}()
    blk = Expr(:block)
    map(filter(arg -> !isa(arg, LineNumberNode), expr.args)) do line
        sym, typ = line.args
        value = read_value(typ, dict)
        dict[sym] = value
        push!(blk.args, esc(:($sym = $value)))
    end

    @show blk
    blk
end

end
