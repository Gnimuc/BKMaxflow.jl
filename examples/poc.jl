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





n = 128
const lg = LightGraphs
flow_graph = lg.DiGraph(n*n)

imageDims = (n,n)

capacity_matrix = zeros(n*n,n*n)
residualGraph = Float64[]
neighbors = Vector{Vector{Tuple{Int,Int}}}(n*n)
pixelRange = CartesianRange(imageDims)
pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
idx = 0
for ii in pixelRange
    i = sub2ind(imageDims, ii.I...)
    neighborRange = CartesianRange(max(pixelFirst, ii-5pixelFirst), min(pixelEnd, ii+5pixelFirst))
    neighbor = Tuple{Int,Int}[]
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
            push!(residualGraph, vf, vb)
            push!(neighbor, (j,idx))
        end
    end
    neighbors[i] = neighbor
end

for q in eachindex(neighbors)
    for (p,idx) in neighbors[q]
        q < p && push!(neighbors[p], (q,idx))
    end
end

neighbors

xxx = lg.DiGraph(lg.Graph(flow_graph))

# for i in eachindex(neighbors)
#     nn = [n[1] for n in neighbors[i]]
#     @show nn
#     @show lg.neighbors(xxx,i)
# end

lg.neighbors(xxx, 1)

lg.neighbors(flow_graph, 2)

residualGraph = reshape(residualGraph, 2, :)

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)
aa, cc = boykov_kolmogorov(1, n*n, neighbors, residualGraph)
@test a ≈ aa

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, n, 3n, capacity_matrix)
aa, cc = boykov_kolmogorov(n, 3n, neighbors, residualGraph)
@test a ≈ aa

# @enter boykov_kolmogorov(1, n*n, neighbors, residualPQ, residualQP)
# @enter LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)

Profile.clear()
@profiler boykov_kolmogorov(1, n*n, neighbors, residualGraph)

Profile.clear()
@profiler LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)


using BenchmarkTools

@benchmark LightGraphsFlows.boykov_kolmogorov_impl($xxx, 1, n*n, $capacity_matrix)

@benchmark boykov_kolmogorov(1, n*n, $neighbors, $residualGraph)

@benchmark boykov_kolmogorov(1, n*n, $neighbors, $residualGraph)

@benchmark boykov_kolmogorov(1, n*n, $neighbors, $residualGraph)



@code_warntype LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n, capacity_matrix)

@code_warntype boykov_kolmogorov(1, n*n, neighbors, residualGraph)


flow_graph = DiGraph(8);
# (node,node,flow)
flow_edges = [ (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
               (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
               (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
             ];

capacity_matrix = zeros(Int ,nv(flow_graph) ,nv(flow_graph));

for e in flow_edges
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

julia> maximum_flow(flow_graph, 1, 8, capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())[1]
28
