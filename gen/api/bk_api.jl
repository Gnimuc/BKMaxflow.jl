# Julia wrapper for header: /Users/gnimuc/.julia/v0.6/BKMaxflow/deps/usr/include/bk.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0


function bk_error_message(error)
    ccall((:bk_error_message, libbkmaxflow), Cstring, (bk_error,), error)
end

function bk_error_release(error)
    ccall((:bk_error_release, libbkmaxflow), Cvoid, (bk_error,), error)
end

function bk_create_graph_int(node_num_max, edge_num_max, error)
    ccall((:bk_create_graph_int, libbkmaxflow), bk_graph_int, (Cint, Cint, Ptr{bk_error}), node_num_max, edge_num_max, error)
end

function bk_create_graph_short(node_num_max, edge_num_max, error)
    ccall((:bk_create_graph_short, libbkmaxflow), bk_graph_short, (Cint, Cint, Ptr{bk_error}), node_num_max, edge_num_max, error)
end

function bk_create_graph_float(node_num_max, edge_num_max, error)
    ccall((:bk_create_graph_float, libbkmaxflow), bk_graph_float, (Cint, Cint, Ptr{bk_error}), node_num_max, edge_num_max, error)
end

function bk_create_graph_double(node_num_max, edge_num_max, error)
    ccall((:bk_create_graph_double, libbkmaxflow), bk_graph_double, (Cint, Cint, Ptr{bk_error}), node_num_max, edge_num_max, error)
end

function bk_delete_graph_int(g)
    ccall((:bk_delete_graph_int, libbkmaxflow), Cvoid, (bk_graph_int,), g)
end

function bk_delete_graph_short(g)
    ccall((:bk_delete_graph_short, libbkmaxflow), Cvoid, (bk_graph_short,), g)
end

function bk_delete_graph_float(g)
    ccall((:bk_delete_graph_float, libbkmaxflow), Cvoid, (bk_graph_float,), g)
end

function bk_delete_graph_double(g)
    ccall((:bk_delete_graph_double, libbkmaxflow), Cvoid, (bk_graph_double,), g)
end

function bk_add_node_int(g, num, error)
    ccall((:bk_add_node_int, libbkmaxflow), Cint, (bk_graph_int, Cint, Ptr{bk_error}), g, num, error)
end

function bk_add_node_short(g, num, error)
    ccall((:bk_add_node_short, libbkmaxflow), Cint, (bk_graph_short, Cint, Ptr{bk_error}), g, num, error)
end

function bk_add_node_float(g, num, error)
    ccall((:bk_add_node_float, libbkmaxflow), Cint, (bk_graph_float, Cint, Ptr{bk_error}), g, num, error)
end

function bk_add_node_double(g, num, error)
    ccall((:bk_add_node_double, libbkmaxflow), Cint, (bk_graph_double, Cint, Ptr{bk_error}), g, num, error)
end

function bk_add_tweights_int(g, id, cap_source, cap_sink, error)
    ccall((:bk_add_tweights_int, libbkmaxflow), Cvoid, (bk_graph_int, Cint, Cint, Cint, Ptr{bk_error}), g, id, cap_source, cap_sink, error)
end

function bk_add_tweights_short(g, id, cap_source, cap_sink, error)
    ccall((:bk_add_tweights_short, libbkmaxflow), Cvoid, (bk_graph_short, Cint, Cint, Cint, Ptr{bk_error}), g, id, cap_source, cap_sink, error)
end

function bk_add_tweights_float(g, id, cap_source, cap_sink, error)
    ccall((:bk_add_tweights_float, libbkmaxflow), Cvoid, (bk_graph_float, Cint, Cfloat, Cfloat, Ptr{bk_error}), g, id, cap_source, cap_sink, error)
end

function bk_add_tweights_double(g, id, cap_source, cap_sink, error)
    ccall((:bk_add_tweights_double, libbkmaxflow), Cvoid, (bk_graph_double, Cint, Cdouble, Cdouble, Ptr{bk_error}), g, id, cap_source, cap_sink, error)
end

function bk_add_edge_int(g, i, j, cap, rev_cap, error)
    ccall((:bk_add_edge_int, libbkmaxflow), Cvoid, (bk_graph_int, Cint, Cint, Cint, Cint, Ptr{bk_error}), g, i, j, cap, rev_cap, error)
end

function bk_add_edge_short(g, i, j, cap, rev_cap, error)
    ccall((:bk_add_edge_short, libbkmaxflow), Cvoid, (bk_graph_short, Cint, Cint, Int16, Int16, Ptr{bk_error}), g, i, j, cap, rev_cap, error)
end

function bk_add_edge_float(g, i, j, cap, rev_cap, error)
    ccall((:bk_add_edge_float, libbkmaxflow), Cvoid, (bk_graph_float, Cint, Cint, Cfloat, Cfloat, Ptr{bk_error}), g, i, j, cap, rev_cap, error)
end

function bk_add_edge_double(g, i, j, cap, rev_cap, error)
    ccall((:bk_add_edge_double, libbkmaxflow), Cvoid, (bk_graph_double, Cint, Cint, Cdouble, Cdouble, Ptr{bk_error}), g, i, j, cap, rev_cap, error)
end

function bk_maxflow_int(g, reuse_trees, error)
    ccall((:bk_maxflow_int, libbkmaxflow), Cint, (bk_graph_int, Cint, Ptr{bk_error}), g, reuse_trees, error)
end

function bk_maxflow_short(g, reuse_trees, error)
    ccall((:bk_maxflow_short, libbkmaxflow), Cint, (bk_graph_short, Cint, Ptr{bk_error}), g, reuse_trees, error)
end

function bk_maxflow_float(g, reuse_trees, error)
    ccall((:bk_maxflow_float, libbkmaxflow), Cfloat, (bk_graph_float, Cint, Ptr{bk_error}), g, reuse_trees, error)
end

function bk_maxflow_double(g, reuse_trees, error)
    ccall((:bk_maxflow_double, libbkmaxflow), Cdouble, (bk_graph_double, Cint, Ptr{bk_error}), g, reuse_trees, error)
end

function bk_what_segment_int(g, i, error)
    ccall((:bk_what_segment_int, libbkmaxflow), bk_termtype, (bk_graph_int, Cint, Ptr{bk_error}), g, i, error)
end

function bk_what_segment_short(g, i, error)
    ccall((:bk_what_segment_short, libbkmaxflow), bk_termtype, (bk_graph_short, Cint, Ptr{bk_error}), g, i, error)
end

function bk_what_segment_float(g, i, error)
    ccall((:bk_what_segment_float, libbkmaxflow), bk_termtype, (bk_graph_float, Cint, Ptr{bk_error}), g, i, error)
end

function bk_what_segment_double(g, i, error)
    ccall((:bk_what_segment_double, libbkmaxflow), bk_termtype, (bk_graph_double, Cint, Ptr{bk_error}), g, i, error)
end
