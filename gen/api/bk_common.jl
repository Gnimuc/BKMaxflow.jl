# Automatically generated using Clang.jl wrap_c, version 0.0.0


# begin enum bk_termtype
const bk_termtype = UInt32
const SOURCE = 0 |> UInt32
const SINK = 1 |> UInt32
# end enum bk_termtype

mutable struct error
end

const bk_error = Ptr{Cvoid}

mutable struct graph_int
end

const bk_graph_int = Ptr{Cvoid}

mutable struct graph_short
end

const bk_graph_short = Ptr{Cvoid}

mutable struct graph_float
end

const bk_graph_float = Ptr{Cvoid}

mutable struct graph_double
end

const bk_graph_double = Ptr{Cvoid}
