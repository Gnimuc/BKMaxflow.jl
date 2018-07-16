# The Boykov-Kolmogorov Maxflow Algorithm

[![Build Status](https://travis-ci.org/Gnimuc/BKMaxflow.jl.svg?branch=master)](https://travis-ci.org/Gnimuc/BKMaxflow.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/y185yw848ln0u405/branch/master?svg=true)](https://ci.appveyor.com/project/Gnimuc/bkmaxflow-jl/branch/master)
[![codecov.io](http://codecov.io/github/Gnimuc/BKMaxflow.jl/coverage.svg?branch=master)](http://codecov.io/github/Gnimuc/BKMaxflow.jl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Gnimuc/BKMaxflow.jl/badge.svg?branch=master)](https://coveralls.io/github/Gnimuc/BKMaxflow.jl?branch=master)

## Installation

`Pkg.clone("https://github.com/Gnimuc/BKMaxflow.jl.git")`

## Quick start:
### Julia API
```julia
using BKMaxflow

weights, neighbors = create_graph(JuliaImpl{Float64,Int}, 4)

add_edge!(weights, neighbors, 1, 2, 1., 1.)
add_edge!(weights, neighbors, 1, 3, 2., 2.)
add_edge!(weights, neighbors, 2, 3, 3., 4.)
add_edge!(weights, neighbors, 2, 4, 5., 5.)
add_edge!(weights, neighbors, 3, 4, 6., 6.)

w = reshape(weights, 2, :)
flow, label = boykov_kolmogorov(1, 4, neighbors, w)
```

### C API(high-level)
```julia
using BKMaxflow

g = create_graph(CImpl{Cdouble}, 2, 1)

add_node(CImpl{Cdouble}, g, 1)
add_node(CImpl{Cdouble}, g, 1)

add_tweights(CImpl, g, 0, 1., 5.)
add_tweights(CImpl, g, 1, 2., 6.)

add_edge(CImpl, g, 0, 1, 3., 4.)

flow = maxflow(CImpl{Cdouble}, g)  #-> 3

what_segment(CImpl{Cdouble}, g, 0)  #-> 1 which means it belongs to sink
what_segment(CImpl{Cdouble}, g, 1)  #-> 1 which means it belongs to sink

delete_graph(CImpl{Cdouble}, g)
```

### C API(low-level)
```julia
using BKMaxflow

err = Ref{bk_error}(C_NULL)

g = bk_create_graph_double(2, 1, err[])

bk_add_node_double(g, 1, err[])
bk_add_node_double(g, 1, err[])

bk_add_tweights_double(g, 0, 1., 5., err[])
bk_add_tweights_double(g, 1, 2., 6., err[])

bk_add_edge_double(g, 0, 1, 3., 4., err[])

flow = bk_maxflow_double(g, false, err[])

bk_what_segment_double(g, 0, err[])
bk_what_segment_double(g, 1, err[])

bk_delete_graph_double(g)
```

## Reference
Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence, IEEE Transactions on 26.9 (2004): 1124-1137.
