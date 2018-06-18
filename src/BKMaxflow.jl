module BKMaxflow

include("bitmask.jl")
export BKStatusBits, BK_EMPTY, BK_FREE, BK_S, BK_T, BK_ACTIVE, BK_ORPHAN
export BK_S_ACTIVE, BK_T_ACTIVE, BK_S_ORPHAN, BK_T_ORPHAN, BK_S_ACTIVE_ORPHAN, BK_T_ACTIVE_ORPHAN

include("boykov_kolmogorov.jl")
export boykov_kolmogorov


end # module
