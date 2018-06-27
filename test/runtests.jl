using BKMaxflow
using LightGraphsFlows
using Base.Test


n = 32
const lg = LightGraphs
flow_graph = lg.DiGraph(n*n)

imageDims = (n,n)

capacity_matrix = zeros(n*n,n*n)
residualPQ = Float64[]
residualQP = Float64[]
neighbors = Vector{Dict{Int,Int}}(n*n)
pixelRange = CartesianRange(imageDims)
pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
idx = 0
for ii in pixelRange
    i = sub2ind(imageDims, ii.I...)
    neighborRange = CartesianRange(max(pixelFirst, ii-5pixelFirst), min(pixelEnd, ii+5pixelFirst))
    neighbor = Dict{Int,Int}()
    for jj in neighborRange
        if ii < jj
            j = sub2ind(imageDims, jj.I...)
            # lg
            lg.add_edge!(flow_graph, i, j)
            lg.add_edge!(flow_graph, j, i)
            vf = 100*rand()
            vb = 100*rand()
            capacity_matrix[i,j] = vf
            capacity_matrix[j,i] = vb
            # bk
            idx += 1
            push!(residualPQ, vf)
            push!(residualQP, vb)
            neighbor[j] = idx
        end
    end
    neighbors[i] = neighbor
end

for q in eachindex(neighbors)
    for (p,idx) in neighbors[q]
        q < p && (neighbors[p][q] = idx;)
    end
end

neighbors

xxx = lg.DiGraph(lg.Graph(flow_graph))

# for i in eachindex(neighbors)
#     nn = [n[1] for n in neighbors[i]]
#     @show nn
#     @show lg.neighbors(xxx,i)
# end

lg.neighbors(xxx, n*n)


a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)
aa, cc = boykov_kolmogorov(1, n*n, neighbors, residualPQ, residualQP)
@test a ≈ aa

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, n, 3n, capacity_matrix)
aa, cc = boykov_kolmogorov(n, 3n, neighbors, residualPQ, residualQP)
@test a ≈ aa

# @enter boykov_kolmogorov(1, n*n, neighbors, residualPQ, residualQP)
# @enter LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)

Profile.clear()
@profiler boykov_kolmogorov(1, n*n, neighbors, residualPQ, residualQP)

Profile.clear()
@profiler LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)


using BenchmarkTools

@benchmark LightGraphsFlows.boykov_kolmogorov_impl($xxx, 1, n*n, $capacity_matrix)

@benchmark boykov_kolmogorov(1, n*n, $neighbors, $residualPQ, $residualQP)

# @benchmark boykov_kolmogorov(1, n, $(xxx.fadjlist), $residuals)



@code_warntype LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)

@code_warntype boykov_kolmogorov(1, n*n, neighbors, residualPQ, residualQP)




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
