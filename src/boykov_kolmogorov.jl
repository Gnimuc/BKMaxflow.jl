const ∅ = BK_EMPTY

function PATH(s, t, source, sink, PARENT::AbstractVector{T}) where {T<:Real}
    path = Vector{T}()
    while s != source
        unshift!(path, s)
        s = PARENT[s]
    end
    unshift!(path, s)
    while t != sink
        push!(path, t)
        t = PARENT[t]
    end
    push!(path, t)
    return path
end

@inline neighbors(residualGraph, x) = keys(residualGraph[x])


function boykov_kolmogorov(source::Integer, sink::Integer, graph::Vector{Dict{Ti,Bool}},
                           capacityMatrix::AbstractMatrix{Tv}) where {Ti<:Integer,Tv<:Real}
    # initialize: S = {s}, T = {t},  A = {s,t}, O = ∅
    residualGraph = deepcopy(graph)
    residualMatrix = copy(capacityMatrix)
    vertexNum = length(residualGraph)
    PARENT = zeros(Ti, vertexNum)
    STATUS = fill(BK_FREE, vertexNum)
    STATUS[source] = BK_S_ACTIVE
    STATUS[sink] = BK_T_ACTIVE
    ORPHAN = fill(false, vertexNum)
    activeQueue = Vector{Ti}([source, sink])  # this queue could also contains inactive nodes which will be automatically skipped in the growth stage
    O = Vector{Ti}()
    flow = zero(Tv)
    # Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow
    # algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence,
    # IEEE Transactions on 26.9 (2004): 1124-1137.
    while true
        # “growth” stage: search trees S and T grow until they touch giving an s → t path
        # grow S or T to find an augmenting path P from s to t
        P = growth_stage!(source, sink, residualGraph, residualMatrix, activeQueue, STATUS, PARENT)
        # @show P
        isempty(P) && break
        # “augmentation” stage: the found path is augmented, search tree(s) break into forest(s)
        flow += augmentation_stage!(residualGraph, residualMatrix, P, O, STATUS, PARENT)
        # “adoption” stage: trees S and T are restored
        adoption_stage!(source, sink, residualGraph, residualMatrix, O, activeQueue, ORPHAN, STATUS, PARENT)
    end
    return flow, STATUS
end

function growth_stage!(source, sink, residualGraph, residualMatrix, activeQueue, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    # tree_cap(p,q) = STATUS[p] & BK_S == BK_S ? residualGraph[p][q] : residualGraph[q][p]
    while !isempty(activeQueue)
        p = last(activeQueue)  # pick an active node p ∈ A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] & BK_ACTIVE == BK_ACTIVE || (pop!(activeQueue); continue)  # automatically skip inactive nodes
        rp = residualGraph[p]
        if STATUS[p] & BK_S == BK_S
            for q in neighbors(residualGraph, p)
                rp[q] || continue
                if TREE(q) == ∅
                    # then add q to search tree as an active node
                    STATUS[q] = STATUS[p]
                    PARENT[q] = p
                    unshift!(activeQueue, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
                end
                TREE(q)≠∅ && TREE(q)≠TREE(p) && return TREE(p)==BK_S ? PATH(p,q,source,sink,PARENT) : PATH(q,p,source,sink,PARENT)
            end
        else
            for q in neighbors(residualGraph, p)
                residualGraph[q][p] || continue
                if TREE(q) == ∅
                    # then add q to search tree as an active node
                    STATUS[q] = STATUS[p]
                    PARENT[q] = p
                    unshift!(activeQueue, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
                end
                TREE(q)≠∅ && TREE(q)≠TREE(p) && return TREE(p)==BK_S ? PATH(p,q,source,sink,PARENT) : PATH(q,p,source,sink,PARENT)
            end
        end
        # remove p from A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] &= ~BK_ACTIVE
        pop!(activeQueue)
    end
    return Int[]
end

function augmentation_stage!(residualGraph, residualMatrix, P, O, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    # find the bottleneck capacity Δ on P
    Δ = Inf
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        Δ > residualMatrix[p,q] && (Δ = residualMatrix[p,q];)
    end
    # update the residual graph by pushing flow Δ through P
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        # residualMatrix = capacityMatrix - flowMatrix
        residualMatrix[p,q] -= Δ
        residualMatrix[q,p] += Δ
        # for each edge (p,q) in P that becomes saturated
        residualMatrix[p,q] == 0 || continue
        residualGraph[p][q] = false
        if TREE(p) == TREE(q) == BK_S
            PARENT[q] = 0
            unshift!(O, q)
        end
        if TREE(p) == TREE(q) == BK_T
            PARENT[p] = 0
            unshift!(O, p)
        end
    end
    return Δ
end

function adoption_stage!(source, sink, residualGraph, residualMatrix, O, activeQueue, ORPHAN, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    tree_cap(p,q) = STATUS[p] & BK_S == BK_S ? residualGraph[p][q] : residualGraph[q][p]
    fill!(ORPHAN, false)
    while !isempty(O)
        # pick an orphan node p ∈ O and remove it from O
        p = pop!(O)
        rp = residualGraph[p]
        # find a new valid parent for p among its neighbors
        has_valid_parent = false
        if STATUS[p] & BK_S == BK_S
            for q in neighbors(residualGraph,p)
                ORPHAN[q] && continue
                TREE(q) == TREE(p) || continue
                residualGraph[q][p] || continue
                # the “origin” of q should be either source or sink, it should not originates from orphan
                x = q
                while PARENT[x] ≠ 0
                    x = PARENT[x]
                    ORPHAN[x] && break
                    ORPHAN[x] = true
                end
                if x == source || x == sink
                    PARENT[p] = q
                    has_valid_parent = true
                    fill!(ORPHAN, false)
                    break
                end
            end
        else
            for q in neighbors(residualGraph,p)
                ORPHAN[q] && continue
                TREE(q) == TREE(p) || continue
                rp[q] || continue
                # the “origin” of q should be either source or sink, it should not originates from orphan
                x = q
                while PARENT[x] ≠ 0
                    x = PARENT[x]
                    ORPHAN[x] && break
                    ORPHAN[x] = true
                end
                if x == source || x == sink
                    PARENT[p] = q
                    has_valid_parent = true
                    fill!(ORPHAN, false)
                    break
                end
            end
        end
        has_valid_parent && continue
        for q in neighbors(residualGraph,p)
            TREE(q) == TREE(p) || continue
            if tree_cap(q,p)
                STATUS[q] |= BK_ACTIVE
                unshift!(activeQueue, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
            end
            PARENT[q] == p && (PARENT[q] = 0; unshift!(O, q))
        end
        # TREE(p) := ∅, A := A - {p}
        STATUS[p] = BK_FREE   # note that this also marks p as inactive node
    end
end
