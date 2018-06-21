using BKMaxflow
using LightGraphsFlows
using Base.Test

@testset "proof" begin
    for i in [0.01, 0.1, 0.2, 0.4, 0.8, 1]
        n = 1000
        const lg = LightGraphs
        flow_graph = lg.DiGraph(n)
        vertices = collect(1:n)
        capacity_matrix = zeros(n, n)
        for u = 1:n, v = 1:n
            rand() > i && continue
            u == 1 && v == n && continue
            u == n && v == 1 && continue
            lg.add_edge!(flow_graph, u, v)
            lg.add_edge!(flow_graph, v, u)
            capacity_matrix[u,v] = rand()
        end
        xxx = lg.DiGraph(lg.Graph(flow_graph))
        a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)
        aa, bb, cc = boykov_kolmogorov(1, n, flow_graph.fadjlist, capacity_matrix)
        @test a ≈ aa
    end
end


n = 5
const lg = LightGraphs
flow_graph = lg.DiGraph(n)
capacity_matrix = zeros(n, n)

for u = 1:n, v = 1:n
    rand() > 0.5 && continue
    u == 1 && v == n && continue
    u == n && v == 1 && continue
    lg.add_edge!(flow_graph, u, v)
    lg.add_edge!(flow_graph, v, u)
    capacity_matrix[u,v] = rand()
end

# @enter lg.add_edge!(flow_graph, 1, 8)
# @enter lg.Graph(flow_graph)

# lg.neighbors(flow_graph, 1)

flow_graph.fadjlist

xxx.fadjlist
xxx.badjlist

xxx = lg.DiGraph(lg.Graph(flow_graph))

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)
aa, bb, cc = boykov_kolmogorov(1, n, flow_graph.fadjlist, capacity_matrix)
@test a ≈ aa
b ≈ bb
b - bb
vecnorm(b - bb)

# @enter boykov_kolmogorov(1, n, xxx.fadjlist, capacity_matrix)


Profile.clear()
@profiler boykov_kolmogorov(1, n, xxx.fadjlist, capacity_matrix)

Profile.clear()
@profiler LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)


using BenchmarkTools

@benchmark LightGraphsFlows.boykov_kolmogorov_impl($xxx, 1, n, $capacity_matrix)

@benchmark boykov_kolmogorov(1, n, $(xxx.fadjlist), $capacity_matrix)

# @benchmark boykov_kolmogorov(1, n, $(xxx.fadjlist), $capacity_matrix)



@code_warntype LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)

@code_warntype boykov_kolmogorov(1, n, xxx.fadjlist, capacity_matrix)




# improve coverage
flow_graph = lg.DiGraph(6)

flow_edges = [(1,2,5),(1,3,3),(1,4,2),(1,5,1),
              (2,6,5),(3,6,3),(4,6,2),(5,6,1),
              (2,3,6),(3,2,7)]

capacity_matrix = zeros(Int, 6, 6)

for e in flow_edges
    u,v,f = e
    lg.add_edge!(flow_graph,u,v)
    lg.add_edge!(flow_graph,v,u)
    capacity_matrix[u,v] = f
end

maximum_flow(flow_graph, 1, 6, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())

boykov_kolmogorov(1, 6, flow_graph.fadjlist, capacity_matrix)



flow_graph = lg.DiGraph(8)
flow_edges = [(1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),(2,6,15),(3,6,8),
              (4,7,16),(5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)]
capacity_matrix = zeros(Int, 8, 8)

for e in flow_edges
  u,v,f = e
  lg.add_edge!(flow_graph,u,v)
  lg.add_edge!(flow_graph,v,u)
  capacity_matrix[u,v] = f
end

maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())

boykov_kolmogorov(1, 8, flow_graph.fadjlist, capacity_matrix)
