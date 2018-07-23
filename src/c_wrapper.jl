if VERSION >= v"0.7.0-DEV.3382"
    import Libdl
end

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("BKMaxflow was not build properly. Please run Pkg.build(\"BKMaxflow\")")
end
include(depsjl_path)

# Module initialization function
function __init__()
    # Always check your dependencies from `deps.jl`
    check_deps()
end

include(joinpath(@__DIR__, "..", "gen", "api", "bk_common.jl"))
include(joinpath(@__DIR__, "..", "gen", "api", "bk_api.jl"))
# high-level
export create_graph, delete_graph, check_error
export add_node, add_tweights, add_edge
export maxflow, what_segment
# low-level
export bk_error, bk_error_message, bk_error_release
export bk_create_graph_int, bk_create_graph_short, bk_create_graph_float, bk_create_graph_double
export bk_delete_graph_int, bk_delete_graph_short, bk_delete_graph_float, bk_delete_graph_double
export bk_add_node_int, bk_add_node_short, bk_add_node_float, bk_add_node_double
export bk_add_tweights_int, bk_add_tweights_short, bk_add_tweights_float, bk_add_tweights_double
export bk_add_edge_int, bk_add_edge_short, bk_add_edge_float, bk_add_edge_double
export bk_maxflow_int, bk_maxflow_short, bk_maxflow_float, bk_maxflow_double
export bk_what_segment_int, bk_what_segment_short, bk_what_segment_float, bk_what_segment_double

function check_error(err)
    if err[] != C_NULL
        message = unsafe_string(bk_error_message(err[]))
        error("$message")
    end
    bk_error_release(err[])
end

@generated function create_graph(::Type{CImpl{Tv}}, node_num_max::Integer, edge_num_max::Integer) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            graph = bk_create_graph_int(node_num_max, edge_num_max, err[])
            check_error(err)
            graph
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            graph = bk_create_graph_short(node_num_max, edge_num_max, err[])
            check_error(err)
            graph
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            graph = bk_create_graph_float(node_num_max, edge_num_max, err[])
            check_error(err)
            graph
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            graph = bk_create_graph_double(node_num_max, edge_num_max, err[])
            check_error(err)
            graph
        end
    end
end

@generated function delete_graph(::Type{CImpl{Tv}}, graph::Ptr{Cvoid}) where {Tv<:Real}
    if Tv == Cint
        return :(bk_delete_graph_int(graph))
    elseif Tv == Cshort
        return :(bk_delete_graph_short(graph))
    elseif Tv == Cfloat
        return :(bk_delete_graph_float(graph))
    elseif Tv == Cdouble
        return :(bk_delete_graph_double(graph))
    end
end

@generated function add_node(::Type{CImpl{Tv}}, graph::Ptr{Cvoid}, num::Integer=1) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            n = bk_add_node_int(graph, num, err[])
            check_error(err)
            n
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            n = bk_add_node_short(graph, num, err[])
            check_error(err)
            n
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            n = bk_add_node_float(graph, num, err[])
            check_error(err)
            n
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            n = bk_add_node_double(graph, num, err[])
            check_error(err)
            n
        end
    end
end

@generated function add_tweights(::Type{CImpl}, graph::Ptr{Cvoid}, id::Integer, cap_source::Tv, cap_sink::Tv) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_tweights_int(graph, id, cap_source, cap_sink, err[])
            check_error(err)
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_tweights_short(graph, id, cap_source, cap_sink, err[])
            check_error(err)
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_tweights_float(graph, id, cap_source, cap_sink, err[])
            check_error(err)
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_tweights_double(graph, id, cap_source, cap_sink, err[])
            check_error(err)
        end
    end
end

@generated function add_edge(::Type{CImpl}, graph::Ptr{Cvoid}, i::Integer, j::Integer, cap::Tv, rev_cap::Tv) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_edge_int(graph, i, j, cap, rev_cap, err[])
            check_error(err)
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_edge_short(graph, i, j, cap, rev_cap, err[])
            check_error(err)
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_edge_float(graph, i, j, cap, rev_cap, err[])
            check_error(err)
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            bk_add_edge_double(graph, i, j, cap, rev_cap, err[])
            check_error(err)
        end
    end
end

@generated function maxflow(::Type{CImpl{Tv}}, graph::Ptr{Cvoid}, reuse_trees::Bool=false) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            flow = bk_maxflow_int(graph, reuse_trees, err[])
            check_error(err)
            flow
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            flow = bk_maxflow_short(graph, reuse_trees, err[])
            check_error(err)
            flow
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            flow = bk_maxflow_float(graph, reuse_trees, err[])
            check_error(err)
            flow
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            flow = bk_maxflow_double(graph, reuse_trees, err[])
            check_error(err)
            flow
        end
    end
end

@generated function what_segment(::Type{CImpl{Tv}}, graph::Ptr{Cvoid}, i::Integer) where {Tv<:Real}
    if Tv == Cint
        return quote
            err = Ref{bk_error}(C_NULL)
            label = bk_what_segment_int(graph, i, err[])
            check_error(err)
            label
        end
    elseif Tv == Cshort
        return quote
            err = Ref{bk_error}(C_NULL)
            label = bk_what_segment_short(graph, i, err[])
            check_error(err)
            label
        end
    elseif Tv == Cfloat
        return quote
            err = Ref{bk_error}(C_NULL)
            label = bk_what_segment_float(graph, i, err[])
            check_error(err)
            label
        end
    elseif Tv == Cdouble
        return quote
            err = Ref{bk_error}(C_NULL)
            label = bk_what_segment_double(graph, i, err[])
            check_error(err)
            label
        end
    end
end
