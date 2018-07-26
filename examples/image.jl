# pkg> activate .
using BKMaxflow

# construct a n x n image
n = 128
# preallocate
g = create_graph(CImpl{Cdouble}, 17000, 200000)
weights, neighbors = create_graph(JuliaImpl{Cdouble,Int}, n*n+2)  # all pixels + 2 terminals

# data term
imageDims = (n,n)
pixelRange = CartesianIndices(imageDims)
pixelFirst, pixelEnd = first(pixelRange), last(pixelRange)
linearIdx = LinearIndices(imageDims)
for ii in pixelRange
    i = linearIdx[ii]
    source = rand()
    sink = rand()
    # julia
    add_edge!(weights, neighbors, 1, i+2, source, 0.0)
    add_edge!(weights, neighbors, 2, i+2, 0.0, sink)
    # c wrapper
    add_node(CImpl{Cdouble}, g)
    add_tweights(CImpl, g, i-1, source, sink)
end

# smooth term
costs = rand(200000)
idx = 0
for ii in pixelRange
    i = linearIdx[ii]
    neighborFirst = max(pixelFirst, ii-pixelFirst)
    neighborEnd = min(pixelEnd, ii+pixelFirst)
    neighborRange = CartesianIndices((neighborFirst[1]:neighborEnd[1], neighborFirst[2]:neighborEnd[2]))
    for jj in neighborRange
        if ii < jj
            j = linearIdx[jj]
            idx += 2
            # julia
            add_edge!(weights, neighbors, i+2, j+2, costs[idx-1], costs[idx])
            # c wrapper
            add_edge(CImpl, g, i-1, j-1, costs[idx-1], costs[idx])
        end
    end
end


flow, label = boykov_kolmogorov(1, 2, neighbors, weights)

flow = maxflow(CImpl{Cdouble}, g)

delete_graph(CImpl{Cdouble}, g)
