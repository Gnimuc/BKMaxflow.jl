const ∅ = BK_EMPTY

function PATH(s, t, i, source, sink, PARENT, INDEX)
    path = Int[]
    idxs = Int[]
    sᵢ = tᵢ = i
    while s != source
        unshift!(path, s)
        unshift!(idxs, sᵢ)
        s, sᵢ = PARENT[s], INDEX[s]
    end
    unshift!(path, s)
    unshift!(idxs, sᵢ)
    pop!(idxs)  # pop i out since we gonna push it again
    while t != sink
        push!(path, t)
        push!(idxs, tᵢ)
        t, tᵢ = PARENT[t], INDEX[t]
    end
    push!(path, t)
    push!(idxs, tᵢ)
    return path, idxs
end

function boykov_kolmogorov(source::Int, sink::Int, neighbors::Vector{Vector{Tuple{Int,Int}}}, residualPQ, residualQP)
    # initialize: S = {s}, T = {t},  A = {s,t}, O = ∅
    vertexNum = length(neighbors)
    PARENT = zeros(Int, vertexNum)
    INDEX = zeros(Int, vertexNum)
    STATUS = fill(BK_FREE, vertexNum)
    STATUS[source] = BK_S_ACTIVE
    STATUS[sink] = BK_T_ACTIVE
    ORPHAN = fill(false, vertexNum)
    A = Int[source, sink]  # this queue could also contains inactive nodes which will be automatically skipped in the growth stage
    O = Int[]
    PQ = copy(residualPQ)
    QP = copy(residualQP)
    flow = zero(Float64)
    # Boykov, Yuri, and Vladimir Kolmogorov. "An experimental comparison of min-cut/max-flow
    # algorithms for energy minimization in vision." Pattern Analysis and Machine Intelligence,
    # IEEE Transactions on 26.9 (2004): 1124-1137.
    while true
        # “growth” stage: search trees S and T grow until they touch giving an s → t path
        # grow S or T to find an augmenting path P from s to t
        P, IDX = growth_stage!(source, sink, neighbors, PQ, QP, A, STATUS, PARENT, INDEX)
        isempty(P) && break
        # “augmentation” stage: the found path is augmented, search tree(s) break into forest(s)
        flow += augmentation_stage!(neighbors, PQ, QP, P, IDX, O, STATUS, PARENT, INDEX)
        # “adoption” stage: trees S and T are restored
        adoption_stage!(source, sink, neighbors, PQ, QP, O, A, ORPHAN, STATUS, PARENT, INDEX)
    end
    return flow, STATUS
end

function growth_stage!(source, sink, neighbors, residualPQ, residualQP, A, STATUS, PARENT, INDEX)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    while !isempty(A)
        p = last(A)  # pick an active node p ∈ A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] & BK_ACTIVE == BK_ACTIVE || (pop!(A); continue)  # automatically skip inactive node
        for (q,qᵢ) in neighbors[p]
            tree_cap = p < q ? (TREE(p)==BK_S ? residualPQ[qᵢ] : residualQP[qᵢ]) : (TREE(p)==BK_S ? residualQP[qᵢ] : residualPQ[qᵢ])
            tree_cap > 0 || continue
            if TREE(q) == ∅
                # then add q to search tree as an active node
                STATUS[q] = STATUS[p]
                PARENT[q] = p
                unshift!(A, q)  # "First-In-First-Out": enqueue -> queue -> dequeue
                INDEX[q] = qᵢ   # cache index for referencing residual in augmentation stage
            end
            TREE(q)≠∅ && TREE(q)≠TREE(p) && return TREE(p)==BK_S ? PATH(p,q,qᵢ,source,sink,PARENT,INDEX) : PATH(q,p,qᵢ,source,sink,PARENT,INDEX)
        end
        # remove p from A ("First-In-First-Out"): enqueue -> queue -> dequeue
        STATUS[p] &= ~BK_ACTIVE
        pop!(A)
    end
    return Int[], Int[]
end

function augmentation_stage!(neighbors, residualPQ, residualQP, P, IDX, O, STATUS, PARENT, INDEX)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    # find the bottleneck capacity Δ on P
    Δ = Inf
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        if p < q
            Δ > residualPQ[IDX[i]] && (Δ = residualPQ[IDX[i]];)
        else
            Δ > residualQP[IDX[i]] && (Δ = residualQP[IDX[i]];)
        end
    end
    # update the residual graph by pushing flow Δ through P
    for i = 1:length(P)-1
        p, q = P[i], P[i+1]
        if p < q
            residualPQ[IDX[i]] -= Δ
            residualQP[IDX[i]] += Δ
            residualPQ[IDX[i]] == 0 || continue
        else
            residualQP[IDX[i]] -= Δ
            residualPQ[IDX[i]] += Δ
            residualQP[IDX[i]] == 0 || continue
        end
        if TREE(p) == TREE(q) == BK_S
            PARENT[q] = 0
            unshift!(O, q)
            INDEX[q] = 0  # clean up index cache
        end
        if TREE(p) == TREE(q) == BK_T
            PARENT[p] = 0
            unshift!(O, p)
            INDEX[p] = 0  # clean up index cache
        end
    end
    return Δ
end

function adoption_stage!(source, sink, neighbors, residualPQ, residualQP, O, A, ORPHAN, STATUS, PARENT, INDEX)
    TREE(x) = STATUS[x] & (BK_S | BK_T)
    fill!(ORPHAN, false)
    while !isempty(O)
        # pick an orphan node p ∈ O and remove it from O
        p = pop!(O)
        # find a new valid parent for p among its neighbors
        has_valid_parent = false
        for (q,qᵢ) in neighbors[p]
            ORPHAN[q] && continue
            TREE(q) == TREE(p) || continue
            tree_cap = q < p ? (TREE(q)==BK_S ? residualPQ[qᵢ] : residualQP[qᵢ]) : (TREE(q)==BK_S ? residualQP[qᵢ] : residualPQ[qᵢ])
            tree_cap > 0 || continue
            # the “origin” of q should be either source or sink, it should not originates from orphan
            x = q
            while PARENT[x] ≠ 0
                x = PARENT[x]
                ORPHAN[x] && break
                ORPHAN[x] = true
            end
            if x == source || x == sink
                PARENT[p] = q
                INDEX[p] = qᵢ
                has_valid_parent = true
                fill!(ORPHAN, false)
                break
            end
        end
        has_valid_parent && continue
        for (q,qᵢ) in neighbors[p]
            TREE(q) == TREE(p) || continue
            tree_cap = q < p ? (TREE(q)==BK_S ? residualPQ[qᵢ] : residualQP[qᵢ]) : (TREE(q)==BK_S ? residualQP[qᵢ] : residualPQ[qᵢ])
            tree_cap > 0   && (STATUS[q] |= BK_ACTIVE; unshift!(A, q);)
            PARENT[q] == p && (PARENT[q] = 0; INDEX[q] = 0; unshift!(O, q);)
        end
        # TREE(p) := ∅, A := A - {p}
        STATUS[p] = BK_FREE   # note that this also marks p as inactive node
    end
end
