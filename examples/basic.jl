using LightGraphsFlows, LightGraphs

flow_graph = DiGraph(8)
# (node,node,flow)
flow_edges = [(1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
              (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
              (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)];
capacity_matrix = zeros(Int ,nv(flow_graph) ,nv(flow_graph));
for e in flow_edges
    u,v,f = e
    LightGraphs.add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end
xxx = LightGraphs.DiGraph(LightGraphs.Graph(flow_graph))
LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, 8, capacity_matrix)


# pkg> activate .
using BKMaxflow

weights, neighbors = create_graph(JuliaImpl{Float64,Int}, 8)

BKMaxflow.add_edge!(weights, neighbors, 1, 2, 10., 0.)
BKMaxflow.add_edge!(weights, neighbors, 1, 3, 5., 0.)
BKMaxflow.add_edge!(weights, neighbors, 1, 4, 15., 0.)
BKMaxflow.add_edge!(weights, neighbors, 2, 3, 4., 0.)
BKMaxflow.add_edge!(weights, neighbors, 2, 5, 9., 0.)
BKMaxflow.add_edge!(weights, neighbors, 2, 6, 15., 0.)
BKMaxflow.add_edge!(weights, neighbors, 3, 4, 4., 0.)
BKMaxflow.add_edge!(weights, neighbors, 3, 6, 8., 0.)
BKMaxflow.add_edge!(weights, neighbors, 4, 7, 16., 0.)
BKMaxflow.add_edge!(weights, neighbors, 5, 6, 15., 0.)
BKMaxflow.add_edge!(weights, neighbors, 5, 8, 10., 0.)
BKMaxflow.add_edge!(weights, neighbors, 6, 7, 15., 0.)
BKMaxflow.add_edge!(weights, neighbors, 6, 8, 10., 0.)
BKMaxflow.add_edge!(weights, neighbors, 7, 3, 6., 0.)
BKMaxflow.add_edge!(weights, neighbors, 7, 8, 10., 0.)

flow, label = boykov_kolmogorov(1, 8, neighbors, weights)

# c wrapper
g = create_graph(CImpl{Cdouble}, 8, 15)

add_node(CImpl{Cdouble}, g, 6)

add_tweights(CImpl, g, 0, 10., 0.)
add_tweights(CImpl, g, 1, 5., 0.)
add_tweights(CImpl, g, 2, 15., 0.)
add_tweights(CImpl, g, 3, 0., 10.)
add_tweights(CImpl, g, 4, 0., 10.)
add_tweights(CImpl, g, 5, 0., 10.)

add_edge(CImpl, g, 0, 1, 4., 0.)
add_edge(CImpl, g, 0, 3, 9., 0.)
add_edge(CImpl, g, 0, 4, 15., 0.)
add_edge(CImpl, g, 1, 2, 4., 0.)
add_edge(CImpl, g, 1, 4, 8., 0.)
add_edge(CImpl, g, 2, 5, 16., 0.)
add_edge(CImpl, g, 3, 4, 15., 0.)
add_edge(CImpl, g, 4, 5, 15., 0.)
add_edge(CImpl, g, 5, 1, 6., 0.)

flow = maxflow(CImpl{Cdouble}, g)  #-> 3

what_segment(CImpl{Cdouble}, g, 0)
what_segment(CImpl{Cdouble}, g, 1)
what_segment(CImpl{Cdouble}, g, 2)
what_segment(CImpl{Cdouble}, g, 3)
what_segment(CImpl{Cdouble}, g, 4)
what_segment(CImpl{Cdouble}, g, 5)

delete_graph(CImpl{Cdouble}, g)
