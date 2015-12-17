module BKMaxflow
using LightGraphs
import LightGraphs: AbstractFlowAlgorithm, maximum_flow
import Base: show


"""
Forces the maximum_flow function to use Boykov-Kolmogorov's maximum flow algorithm
"""
type BoykovKolmogorovAlgorithm <: AbstractFlowAlgorithm
end


"""
Method for Boykov-Kolmogorov's algorithm
"""
function maximum_flow{T<:Number}(
    flow_graph::LightGraphs.DiGraph,
    source::Int,
    target::Int,
    capacity_matrix::AbstractArray{T,2},
    algorithm::BoykovKolmogorovAlgorithm
    )
    residual_graph = LightGraphs.residual(flow_graph)
    return boykov_kolmogorov_impl(residual_graph, source, target, capacity_matrix)
end


"""
Type for Boykov-Kolmogorov's algorithm
"""
type Node
    id::Int
    tree::Symbol      # :S :T or :free
    status::Symbol    # :active or :passive
    neighborList::Vector{Int}
    parent::Node
    function Node(id::Int, tree::Symbol, status::Symbol, neighborList::Vector{Int})
        if tree ∉ [:S,:T,:free]
            error("not a valid tree.")
        end
        if status ∉ [:active,:passive]
            error("not a valid status.")
        end
        obj = new()
        obj.id = id
        obj.tree = tree
        obj.status = status
        obj.neighborList = neighborList
        obj.parent = obj
        obj
    end
end
Node() = Node(0, :free, :passive, Int[])

show(io::IO, x::Node) = print(io, "Node($(x.id),$(x.tree),$(x.status))")


# Utility functions for Boykov-Kolmogorov's algorithm
TREE(p::Node) = p.tree
PARENT(p::Node) = p.parent
isfree(p::Node) = p.tree == :free ? true : false
neighbors(nodes_vector::Vector{Node}, p::Node) = [nodes_vector[id] for id in p.neighborList]

"""
tree_cap(p->q)
"""
function tree_capacity{T<:Number}(p::Node, q::Node, capacity_matrix::AbstractArray{T,2}, flow_matrix::AbstractArray{T,2})
    if TREE(p) == :S
        return capacity_matrix[p.id,q.id] - flow_matrix[p.id,q.id]
    elseif TREE(p) == :T
        return capacity_matrix[q.id,p.id] - flow_matrix[q.id,p.id]
    else
        error("never here.")
    end
end

"""
PATHs->t
"""
function PATH(q::Node, p::Node, source::Int, target::Int)
    if q.tree == :S
        s = q
        t = p
    else
        s = p
        t = q
    end
    path = Vector{Node}()
    while s.id != source
        unshift!(path, s)
        s = s.parent
    end
    unshift!(path, s)
    while t.id != target
        push!(path, t)
        t = t.parent
    end
    push!(path, t)
    return path
end


"""
Implementation for Boykov-Kolmogorov's algorithm
"""
function boykov_kolmogorov_impl{T<:Number}(
    residual_graph::LightGraphs.DiGraph,   # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2}    # edge flow capacities
    )

    n = nv(residual_graph)                 # number of vertices
    flow_matrix = zeros(T, n, n)           # initialize flow matrix

    flow = 0

    # initialize nodes vector
    nodes_vector = [Node(residual_graph.vertices[i], :free, :passive, residual_graph.fadjlist[i]) for i in 1:n]
    # initialize: S = {s}, T = {t},  A = {s,t}, O = ∅
    s = nodes_vector[source]
    s.tree = :S
    s.status = :active
    t = nodes_vector[target]
    t.tree = :T
    t.status = :active
    ActiveNodes = [s, t]
    Orphans = Node[]

    # algorithm: Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow algorithms for energy minimization in vision."
    #            Pattern Analysis and Machine Intelligence, IEEE Transactions on 26.9 (2004): 1124-1137.
    while true
        # update ActiveNodes
        for i = 1:length(ActiveNodes)
            ActiveNodes[i] = nodes_vector[ActiveNodes[i].id]
        end
        # “growth” stage: search trees S and T grow until they touch giving an s → t path
        # grow S or T to find an augmenting path P from s to t
        P = growthstage!(source, target, ActiveNodes, nodes_vector, capacity_matrix, flow_matrix)
        isempty(P) && break
        # “augmentation” stage: the found path is augmented, search tree(s) break into forest(s)
        # augment on P
        augment = augmentationstage!(P, Orphans, nodes_vector, capacity_matrix, flow_matrix)
        flow += augment
        # “adoption” stage: trees S and T are restored.
        # adopt orphans
        adoptionstage!(Orphans, ActiveNodes, nodes_vector, capacity_matrix, flow_matrix)
    end

    return flow, flow_matrix
end


"""
Growth stage of Boykov-Kolmogorov's algorithm
"""
function growthstage!{T<:Number}(
    source::Int,
    target::Int,
    ActiveNodes::Vector{Node},
    nodes_vector::Vector{Node},
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2}
    )
    while !isempty(ActiveNodes)
        p = ActiveNodes[1]    # pick an active node p ∈ A ("First-In-First-Out")
        for q in neighbors(nodes_vector, p)
            if tree_capacity(p, q, capacity_matrix, flow_matrix) > 0
                if TREE(q) == :free
                    # then add q to search tree as an active node
                    q.tree = TREE(p)
                    q.parent = p
                    q.status = :active
                    push!(ActiveNodes, q)    # "First-In-First-Out"
                    # update nodes vector
                    nodes_vector[q.id] = q
                end
                if TREE(q)!=:free && TREE(q)!=TREE(p)
                    return PATH(p, q, source, target)
                end
            end
        end
        p.status = :passive
        shift!(ActiveNodes)    # remove p from A ("First-In-First-Out")
        # update nodes vector
        nodes_vector[p.id] = p
    end
    return P = Node[]
end


"""
Augmentation stage of Boykov-Kolmogorov's algorithm
"""
function augmentationstage!{T<:Number}(
    P::Vector{Node},
    Orphans::Vector{Node},
    nodes_vector::Vector{Node},
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2}
    )
    # find the bottleneck capacity Δ on P
    Δ = typemax(T)
    lenPath = length(P)
    for i = 1:lenPath-1
        p = P[i]
        q = P[i+1]
        residual_capacity = capacity_matrix[p.id,q.id] - flow_matrix[p.id,q.id]
        @assert (residual_capacity > 0) "hmm... this is wired, residual_capacity is supposed to be positive."
        if Δ > residual_capacity
            Δ = residual_capacity
        end
    end
    # update the "residual graph" by pushing flow Δ through P
    for i = 1:lenPath-1
        flow_matrix[P[i].id,P[i+1].id] += Δ
    end
    # produce orphans
    for i = 1:length(P)-1
        p = P[i]
        q = P[i+1]
        if capacity_matrix[p.id,q.id] - flow_matrix[p.id,q.id] == 0
            if TREE(p)==:S && TREE(q)==:S
                # decoupling its kinship
                q.parent = Node()
                push!(Orphans, q)
                # update nodes vector
                nodes_vector[q.id] = q
            end
            if TREE(p)==:T && TREE(q)==:T
                # decoupling its kinship
                p.parent = Node()
                push!(Orphans, p)
                # update nodes vector
                nodes_vector[p.id] = p
            end
        end
    end
    return Δ
end


"""
Adoption stage of Boykov-Kolmogorov's algorithm
"""
function adoptionstage!{T<:Number}(
    Orphans::Vector{Node},
    ActiveNodes::Vector{Node},
    nodes_vector::Vector{Node},
    capacity_matrix::AbstractArray{T,2},
    flow_matrix::AbstractArray{T,2}
    )
    while !isempty(Orphans)
        # pick an orphan node p ∈ O and remove it from O
        p = shift!(Orphans)
        # process p
        # find a new valid parent for p among its neighbors
        no_valid_parent_flag = true
        for q in neighbors(nodes_vector, p)
            if TREE(q)==TREE(p) && tree_capacity(q, p, capacity_matrix, flow_matrix)>0 && q.tree != :free
                p.parent = q
                # update nodes vector
                nodes_vector[p.id] = p
                no_valid_parent_flag = false
                break
            end
        end
        # if p does not find a valid parent
        if no_valid_parent_flag
            # scan all neighbors q of p
            for q in neighbors(nodes_vector, p)
                if TREE(q)==TREE(p) && tree_capacity(q, p, capacity_matrix, flow_matrix)>0
                    # need further test
                    if q.status != :active
                        q.status = :active
                        push!(ActiveNodes, q)
                    end
                end
                if TREE(q)==TREE(p) && PARENT(q) == p
                    q.parent = Node()
                    push!(Orphans, q)
                end
                # update node vector
                nodes_vector[q.id] = q
            end
            # TREE(p) := ∅, A := A - {p}
            p.tree = :free
            p.status = :passive
            for i = 1:length(ActiveNodes)
                if ActiveNodes[i].id == p.id
                    deleteat!(ActiveNodes, i)
                    break
                end
            end
            # update node vector
            nodes_vector[p.id] = p
        end
    end
end


# exports
export BoykovKolmogorovAlgorithm
export maximum_flow


end # module
