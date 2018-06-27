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

function boykov_kolmogorov(source::Int, sink::Int, neighbors::Vector{Dict{Int,Int}}, residuals)
    # initialize: S = {s}, T = {t},  A = {s,t}, O = ∅
    vertexNum = length(neighbors)
    PARENT = zeros(Int, vertexNum)
    STATUS = fill(BK_FREE, vertexNum)
    STATUS[source] = BK_S_ACTIVE
    STATUS[sink] = BK_T_ACTIVE
    MARK = similar(STATUS)
    A = Int[source, sink]  # this queue could also contains inactive nodes which will be automatically skipped in the growth stage
    O = Int[]
    residual = copy(residuals)
    flow = zero(Float64)
    # Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow
    # algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence,
    # IEEE Transactions on 26.9 (2004): 1124-1137.
    while true
        # “growth” stage: search trees S and T grow until they touch giving an s → t path
        # grow S or T to find an augmenting path P from s to t
        P = growth_stage!(source, sink, neighbors, residual, A, STATUS, PARENT)
        # @show P
        isempty(P) && break
        # “augmentation” stage: the found path is augmented, search tree(s) break into forest(s)
        flow += augmentation_stage!(neighbors, residual, P, O, STATUS, PARENT)
        # @show O
        # “adoption” stage: trees S and T are restored
        adoption_stage!(source, sink, neighbors, residual, O, A, MARK, STATUS, PARENT)
    end
    return flow, STATUS
end

function growth_stage!(source, sink, neighbors, residual, A, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    while !isempty(A)
        p = last(A)  # pick an active node p ∈ A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] & BK_ACTIVE == BK_ACTIVE || (pop!(A); continue)  # automatically skip inactive node
        for nb in neighbors[p]
            q, qᵢ = nb
            tree_cap = p < q ? (TREE(p)==BK_S ? residual[1,qᵢ] : residual[2,qᵢ]) : (TREE(p)==BK_S ? residual[2,qᵢ] : residual[1,qᵢ])
            tree_cap > 0 || continue
            if TREE(q) == ∅
                # then add q to search tree as an active node
                STATUS[q] = STATUS[p]
                PARENT[q] = p
                unshift!(A, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
            end
            TREE(q)≠∅ && TREE(q)≠TREE(p) && return TREE(p)==BK_S ? PATH(p,q,source,sink,PARENT) : PATH(q,p,source,sink,PARENT)
        end
        # remove p from A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] &= ~BK_ACTIVE
        pop!(A)
    end
    return Int[]
end

function augmentation_stage!(neighbors, residual, P, O, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    # find the bottleneck capacity Δ on P
    Δ = Inf
    idxs = zeros(Int,length(P)-1)
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        idxs[i] = neighbors[p][q]
        if p < q
            Δ > residual[1,idxs[i]] && (Δ = residual[1,idxs[i]];)
        else
            Δ > residual[2,idxs[i]] && (Δ = residual[2,idxs[i]];)
        end
    end
    # @show idxs
    # update the residual graph by pushing flow Δ through P
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        # residualMatrix = capacityMatrix - flowMatrix
        if p < q
            residual[1,idxs[i]] -= Δ
            residual[2,idxs[i]] += Δ
        else
            residual[2,idxs[i]] -= Δ
            residual[1,idxs[i]] += Δ
        end
        # for each edge (p,q) in P that becomes saturated
        if p < q
            residual[1,idxs[i]] == 0 || continue
        else
            residual[2,idxs[i]] == 0 || continue
        end
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

function adoption_stage!(source, sink, neighbors, residual, O, A, MARK, STATUS, PARENT)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    # tree_cap(x, idx) = TREE(x)==BK_S ? residualPQ[idx] : residualQP[idx]
    MARK .= STATUS
    while !isempty(O)
        # @show O
        # pick an orphan node p ∈ O and remove it from O
        p = pop!(O)
        # find a new valid parent for p among its neighbors
        has_valid_parent = false
        for nb in neighbors[p]
            q, qᵢ = nb
            MARK[q] & BK_ORPHAN == BK_ORPHAN && continue
            TREE(q) == TREE(p) || continue
            tree_cap = q < p ? (TREE(q)==BK_S ? residual[1,qᵢ] : residual[2,qᵢ]) : (TREE(q)==BK_S ? residual[2,qᵢ] : residual[1,qᵢ])
            tree_cap > 0 || continue
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
        has_valid_parent && continue
        for (q,qᵢ) in neighbors[p]
            TREE(q) == TREE(p) || continue
            tree_cap = q < p ? (TREE(q)==BK_S ? residual[1,qᵢ] : residual[2,qᵢ]) : (TREE(q)==BK_S ? residual[2,qᵢ] : residual[1,qᵢ])
            # tree_cap(q,pᵢ) > 0 && (STATUS[q] |= BK_ACTIVE; unshift!(A, q);)
            tree_cap > 0   && (STATUS[q] |= BK_ACTIVE; unshift!(A, q);)
            PARENT[q] == p && (PARENT[q]  = 0        ; unshift!(O, q);)
        end
        # TREE(p) := ∅, A := A - {p}
        STATUS[p] = BK_FREE   # note that this also marks p as inactive node
    end
end
