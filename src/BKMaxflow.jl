module BKMaxflow

include("bitmask.jl")
export BKStatusBits, BK_EMPTY, BK_FREE, BK_S, BK_T, BK_ACTIVE, BK_ORPHAN
export BK_S_ACTIVE, BK_T_ACTIVE, BK_S_ORPHAN, BK_T_ORPHAN, BK_S_ACTIVE_ORPHAN, BK_T_ACTIVE_ORPHAN

include("boykov_kolmogorov.jl")
export boykov_kolmogorov

abstract type AbstractBKMaxflow{Tv,Ti} end
struct JuliaImpl{Tv<:Real,Ti<:Integer} <: AbstractBKMaxflow{Tv,Ti} end
struct CImpl{Tv<:Real} <: AbstractBKMaxflow{Tv,Integer} end

function create_graph(::Type{JuliaImpl{Tv,Ti}}, vertexNum::Integer) where {Tv<:Real,Ti<:Integer}
    weights = Vector{Tv}()
    neighbors = [Vector{Tuple{Ti,Ti}}() for i = 1:vertexNum]
    return weights, neighbors
end

function add_edge!(weights::AbstractVector{Tv}, neighbors::AbstractVector{Vector{Tuple{Ti,Ti}}},
                   p::Ti, q::Ti, weightp2q::Tv, weightq2p::Tv) where {Tv<:Real,Ti<:Integer}
    idx = length(weights) ÷ 2
    # store forward and reverse weights compactly for cache efficiency,
    # assume a forward weight is the weight from a smaller index to a bigger index
    if p < q
        push!(weights, weightp2q, weightq2p)
        push!(neighbors[p], (q,idx+1))
        push!(neighbors[q], (p,idx+1))
    else
        push!(weights, weightq2p, weightp2q)
        push!(neighbors[q], (p,idx+1))
        push!(neighbors[p], (q,idx+1))
    end
end

export AbstractBKMaxflow, JuliaImpl, CImpl
export create_graph, add_edge!

include("c_wrapper.jl")


end # module
