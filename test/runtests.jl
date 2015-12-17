using BKMaxflow
using Base.Test


# Copy from LightGraphs/test
# Construct DiGraph
flow_graph = DiGraph(8)

# Load custom dataset
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(3,2,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

capacity_matrix = zeros(Int ,nv(flow_graph) ,nv(flow_graph))

for e in flow_edges
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

# Construct the residual graph
residual_graph = LightGraphs.residual(flow_graph)

# warmup
@show maximum_flow(residual_graph, 1, 8, capacity_matrix, BoykovKolmogorovAlgorithm())[1]
@show LightGraphs.dinic_impl(residual_graph, 1, 8, capacity_matrix)[1]

@time boykov_kolmogorov_impl(residual_graph, 1, 8, capacity_matrix)[1]
@time LightGraphs.dinic_impl(residual_graph, 1, 8, capacity_matrix)[1]

# test
@test boykov_kolmogorov_impl(residual_graph, 1, 8, capacity_matrix)[1] == 28
