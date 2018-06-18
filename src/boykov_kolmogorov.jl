const ∅ = BK_EMPTY

function PATH(s::Integer, t::Integer, source::Integer, sink::Integer, PARENT::Vector{Int})
    path = Int[]
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

@inline tree_cap(p, q, residualMatrix, STATUS) = STATUS[p] & BK_S == BK_S ? residualMatrix[p,q] : residualMatrix[q,p]

function boykov_kolmogorov(source::Int, sink::Int, neighbors::Vector{Vector{Int}}, capacityMatrix::AbstractMatrix{T}) where {T<:Real}
    # initialize: S = {s}, T = {t},  A = {s,t}, O = ∅
    vertexNum = length(neighbors)
    PARENT = zeros(Int, vertexNum)
    STATUS = fill(BK_FREE, vertexNum)
    STATUS[source] = BK_S_ACTIVE
    STATUS[sink] = BK_T_ACTIVE
    MARK = similar(STATUS)
    activeQueue = Int[source, sink]  # this queue could also contains inactive nodes which will be automatically skipped in the growth stage
    O = Int[]
    residualMatrix = copy(capacityMatrix)
    flow = zero(T)
    # Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow
    # algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence,
    # IEEE Transactions on 26.9 (2004): 1124-1137.
    while true
        # “growth” stage: search trees S and T grow until they touch giving an s → t path
        # grow S or T to find an augmenting path P from s to t
        P = growth_stage!(source, sink, neighbors, activeQueue, STATUS, PARENT, residualMatrix)
        isempty(P) && break
        # “augmentation” stage: the found path is augmented, search tree(s) break into forest(s)
        flow += augmentation_stage!(P, O, STATUS, PARENT, residualMatrix)
        # “adoption” stage: trees S and T are restored
        adoption_stage!(source, sink, neighbors, O, activeQueue, MARK, STATUS, PARENT, residualMatrix)
    end
    return flow, capacityMatrix-residualMatrix, STATUS
end

function growth_stage!(source::Integer, sink::Integer, neighbors::Vector{Vector{Int}}, activeQueue::Vector{Int},
                       STATUS::Vector{BKStatusBits}, PARENT::Vector{Int}, residualMatrix::AbstractMatrix)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    while !isempty(activeQueue)
        p = last(activeQueue)  # pick an active node p ∈ A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] & BK_ACTIVE == BK_ACTIVE || (pop!(activeQueue); continue)  # automatically skip inactive node
        if STATUS[p] & BK_S == BK_S
            @inbounds for q in neighbors[p]
                residualMatrix[p,q] > 0 || continue
                if TREE(q) == ∅
                    # then add q to search tree as an active node
                    STATUS[q] = STATUS[p]
                    PARENT[q] = p
                    unshift!(activeQueue, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
                end
                TREE(q)≠∅ && TREE(q)≠TREE(p) && return TREE(p)==BK_S ? PATH(p,q,source,sink,PARENT) : PATH(q,p,source,sink,PARENT)
            end
        else
            @inbounds for q in neighbors[p]
                residualMatrix[q,p] > 0 || continue
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

function augmentation_stage!(P::Vector{Int}, O::Vector{Int}, STATUS::Vector{BKStatusBits},
                             PARENT::Vector{Int}, residualMatrix::AbstractMatrix{T}) where {T<:Real}
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

function adoption_stage!(source::Int, sink::Int, neighbors::Vector{Vector{Int}}, O::Vector{Int}, activeQueue::Vector{Int}, MARK::Vector{BKStatusBits},
    STATUS::Vector{BKStatusBits}, PARENT::Vector{Int}, residualMatrix::AbstractMatrix{T}) where {T<:Real}
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    MARK .= STATUS
    while !isempty(O)
        # pick an orphan node p ∈ O and remove it from O
        p = pop!(O)
        # find a new valid parent for p among its neighbors
        has_valid_parent = false
        if STATUS[p] & BK_S == BK_S
            @inbounds for q in neighbors[p]
                MARK[q] & BK_ORPHAN == BK_ORPHAN && continue
                TREE(q) == TREE(p) || continue
                residualMatrix[q,p] > 0 || continue
                # the “origin” of q should be either source or sink, it should not originates from orphan
                x = q
                while PARENT[x] ≠ 0
                    x = PARENT[x]
                    MARK[x] & BK_ORPHAN == BK_ORPHAN && break
                    MARK[x] |= BK_ORPHAN
                end
                if x == source || x == sink
                    PARENT[p] = q
                    has_valid_parent = true
                    MARK .= STATUS
                    break
                end
            end
        else
            @inbounds for q in neighbors[p]
                MARK[q] & BK_ORPHAN == BK_ORPHAN && continue
                TREE(q) == TREE(p) || continue
                residualMatrix[p,q] > 0 || continue
                # the “origin” of q should be either source or sink, it should not originates from orphan
                x = q
                while PARENT[x] ≠ 0
                    x = PARENT[x]
                    MARK[x] & BK_ORPHAN == BK_ORPHAN && break
                    MARK[x] |= BK_ORPHAN
                end
                if x == source || x == sink
                    PARENT[p] = q
                    has_valid_parent = true
                    MARK .= STATUS
                    break
                end
            end
        end
        has_valid_parent && continue
        for q in neighbors[p]
            TREE(q) == TREE(p) || continue
            if tree_cap(q, p, residualMatrix, STATUS) > 0
                STATUS[q] |= BK_ACTIVE
                unshift!(activeQueue, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
            end
            PARENT[q] == p && (PARENT[q] = 0; unshift!(O, q))
        end
        # TREE(p) := ∅, A := A - {p}
        STATUS[p] = BK_FREE   # note that this also marks p as inactive node
    end
end
