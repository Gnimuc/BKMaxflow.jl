using BKMaxflow
using Base.Test

# Julia API
weights, neighbors = create_graph(JuliaImpl{Float64,Int}, 4)

add_edge!(weights, neighbors, 1, 2, 1., 1.)
add_edge!(weights, neighbors, 1, 3, 2., 2.)
add_edge!(weights, neighbors, 2, 3, 3., 4.)
add_edge!(weights, neighbors, 2, 4, 5., 5.)
add_edge!(weights, neighbors, 3, 4, 6., 6.)

w = reshape(weights, 2, :)
flow, label = boykov_kolmogorov(1, 4, neighbors, w)
@test flow == 3
@test label[2] == label[3] == BK_T

# C API
# low-level
err = Ref{bk_error}(C_NULL)

g = bk_create_graph_double(2, 1, err[])

bk_add_node_double(g, 1, err[])
bk_add_node_double(g, 1, err[])

bk_add_tweights_double(g, 0, 1., 5., err[])
bk_add_tweights_double(g, 1, 2., 6., err[])

bk_add_edge_double(g, 0, 1, 3., 4., err[])

@test bk_maxflow_double(g, false, err[]) == 3

@test bk_what_segment_double(g, 0, err[]) == 1  # sink
@test bk_what_segment_double(g, 1, err[]) == 1  # sink

bk_delete_graph_double(g)

# high-level
g = create_graph(CImpl{Cdouble}, 2, 1)

add_node(CImpl{Cdouble}, g, 1)
add_node(CImpl{Cdouble}, g, 1)

add_tweights(CImpl, g, 0, 1., 5.)
add_tweights(CImpl, g, 1, 2., 6.)

add_edge(CImpl, g, 0, 1, 3., 4.)

@test maxflow(CImpl{Cdouble}, g) == 3

@test what_segment(CImpl{Cdouble}, g, 0) == 1  # sink
@test what_segment(CImpl{Cdouble}, g, 1) == 1  # sink

delete_graph(CImpl{Cdouble}, g)
