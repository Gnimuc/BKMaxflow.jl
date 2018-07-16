# The Boykov-Kolmogorov Maxflow Algorithm

[![Build Status](https://travis-ci.org/Gnimuc/BKMaxflow.jl.svg?branch=master)](https://travis-ci.org/Gnimuc/BKMaxflow.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/y185yw848ln0u405/branch/master?svg=true)](https://ci.appveyor.com/project/Gnimuc/bkmaxflow-jl/branch/master)
[![codecov.io](http://codecov.io/github/Gnimuc/BKMaxflow.jl/coverage.svg?branch=master)](http://codecov.io/github/Gnimuc/BKMaxflow.jl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Gnimuc/BKMaxflow.jl/badge.svg?branch=master)](https://coveralls.io/github/Gnimuc/BKMaxflow.jl?branch=master)

The package provides one implementation of the **[Hungarian algorithm](https://en.wikipedia.org/wiki/Hungarian_algorithm)**(*Kuhn-Munkres algorithm*) based on its matrix interpretation. This implementation uses a sparse matrix to keep tracking those marked zeros, so it costs less time and memory than [Munkres.jl](https://github.com/FugroRoames/Munkres.jl). Benchmark details can be found [here](https://github.com/Gnimuc/Hungarian.jl/tree/master/benchmark).

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
