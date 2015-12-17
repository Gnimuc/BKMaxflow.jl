using BKMaxflow
using LightGraphs
using Base.Test


# Copy from LightGraphs/test
# Construct DiGraph
flow_graph = DiGraph(8)

# Load custom dataset
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
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
@show maximum_flow(residual_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())[1]
@show maximum_flow(residual_graph, 1, 8, capacity_matrix, algorithm=DinicAlgorithm())[1]

@time maximum_flow(residual_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())
@time maximum_flow(residual_graph, 1, 8, capacity_matrix, algorithm=DinicAlgorithm())

# test
@test maximum_flow(residual_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())[1] == 28
