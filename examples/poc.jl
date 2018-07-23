using LightGraphsFlows
using Test

n = 128
const lg = LightGraphs
flow_graph = lg.DiGraph(n*n)

g = create_graph(CImpl{Cdouble}, 20000, 200000)

# delete_graph(CImpl{Cdouble}, g)

imageDims = (n,n)
capacity_matrix = zeros(n*n,n*n)
pixelRange = CartesianRange(imageDims)
pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
weights, neighbors = create_graph(JuliaImpl{Cdouble,Int}, n*n)
idx = -1
for ii in pixelRange
    i = sub2ind(imageDims, ii.I...)
    neighborRange = CartesianRange(max(pixelFirst, ii-5pixelFirst), min(pixelEnd, ii+5pixelFirst))
    for jj in neighborRange
        if ii < jj
            idx += 1
            j = sub2ind(imageDims, jj.I...)
            # lg
            lg.add_edge!(flow_graph, i, j)
            lg.add_edge!(flow_graph, j, i)
            vf = 100*rand()
            vb = 100*rand()
            capacity_matrix[i,j] = vf
            capacity_matrix[j,i] = vb
            # bk
            BKMaxflow.add_edge!(weights, neighbors, i, j, vf, vb)
            # c
            add_node(CImpl{Cdouble}, g)
            if ii.I == (1,1)
                add_tweights(CImpl, g, idx, vf, 0.)
            elseif

            end
        end
    end
end




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

neighbors

xxx = lg.DiGraph(lg.Graph(flow_graph))
w = reshape(weights, 2, :)

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, 1, n*n, capacity_matrix)
flow, label = boykov_kolmogorov(1, n*n, neighbors, w)
@test a ≈ flow

a, b, c = LightGraphsFlows.boykov_kolmogorov_impl(xxx, n, 3n, capacity_matrix)
flow, label = boykov_kolmogorov(n, 3n, neighbors, w)
@test a ≈ flow

using BenchmarkTools

@benchmark LightGraphsFlows.boykov_kolmogorov_impl($xxx, 1, n*n, $capacity_matrix)

@benchmark boykov_kolmogorov(1, n*n, $neighbors, $w)




@code_warntype boykov_kolmogorov(1, n*n, neighbors, residualGraph)

using BKMaxflow

function foo_j()
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
end

using LightGraphsFlows, LightGraphs

function foo_f()
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
end

function foo_c()
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
end



using BenchmarkTools



@benchmark foo_f()

@benchmark foo_j()

@benchmark foo_c()


function foo()
    x = 1
    for i = 1:100000
        foo_c()
    end
    1
end

Profile.clear()
@profiler foo()
