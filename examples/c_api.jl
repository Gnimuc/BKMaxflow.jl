using BKMaxflow
import BKMaxflow: bk_error, bk_create_graph_double, bk_delete_graph_double,
                  bk_add_node_double, bk_add_tweights_double, bk_add_edge_double,
                  bk_maxflow_double, bk_what_segment_double

err = Ptr{bk_error}(C_NULL)

g = bk_create_graph_double(2, 1, err)

bk_add_node_double(g, 1, err)
bk_add_node_double(g, 1, err)

bk_add_tweights_double(g, 0, 1, 5, err)
bk_add_tweights_double(g, 1, 2, 6, err)

bk_add_edge_double(g, 0, 1, 3, 4, err)

@time bk_maxflow_double(g, false, err)

bk_what_segment_double(g, 0, err)

bk_what_segment_double(g, 1, err)

bk_delete_graph_double(g)


using LightGraphsFlows

const lg = LightGraphs
flow_graph = lg.DiGraph(4)


lg.add_edge!(flow_graph, j, i)
capacity_matrix = zeros(4,4)
lg.add_edge!(flow_graph, 1, 2)
capacity_matrix[1,2] = 1
capacity_matrix[2,1] = 1
lg.add_edge!(flow_graph, 2, 1)

lg.add_edge!(flow_graph, 1, 3)
capacity_matrix[1,3] = 2
capacity_matrix[3,1] = 2
lg.add_edge!(flow_graph, 3, 1)

lg.add_edge!(flow_graph, 2, 3)
capacity_matrix[2,3] = 3
capacity_matrix[3,2] = 4
lg.add_edge!(flow_graph, 3, 2)

lg.add_edge!(flow_graph, 2, 4)
capacity_matrix[2,4] = 5
capacity_matrix[4,2] = 5
lg.add_edge!(flow_graph, 4, 2)

lg.add_edge!(flow_graph, 3, 4)
capacity_matrix[3,4] = 6
capacity_matrix[4,3] = 6
lg.add_edge!(flow_graph, 4, 3)
xxx = lg.DiGraph(lg.Graph(flow_graph))
a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, 4, capacity_matrix)

@time LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, 4, capacity_matrix)




import BKMaxflow: JuliaBKMaxflow
weights, neighbors = create_graph(JuliaBKMaxflow{Float64,Int}, 4)
add_edge!(weights, neighbors, 1, 2, 1., 1.)
add_edge!(weights, neighbors, 1, 3, 2., 2.)
add_edge!(weights, neighbors, 2, 3, 3., 4.)
add_edge!(weights, neighbors, 2, 4, 5., 5.)
add_edge!(weights, neighbors, 3, 4, 6., 6.)

residualGraph = reshape(weights, 2, :)

@time boykov_kolmogorov(1, 4, neighbors, residualGraph)
