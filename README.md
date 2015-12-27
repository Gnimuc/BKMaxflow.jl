# The Boykov-Kolmogorov Max-flow Algorithm

[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](http://www.repostatus.org/badges/latest/abandoned.svg)](http://www.repostatus.org/#abandoned) bacause there has already been a BK-maxflow method in LightGraphs.jl.

Currently, the algorithm is fully implemented in Julia. If you are new to BK-Maxflow algorithm and stumped by the C++ source code [here](http://vision.csd.uwo.ca/code/), you may find this Julia version of the algorithm is much simpler. <strike>I also plan to add an interface by which users can alternatively choose which version they prefer to use in the future.</strike>
 
## Installation

`Pkg.clone("https://github.com/Gnimuc/BKMaxflow.jl.git")`

## Examples:

```julia
using BKMaxflow, LightGraphs

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
```

## Reference
Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence, IEEE Transactions on 26.9 (2004): 1124-1137.
