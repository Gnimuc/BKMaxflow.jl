if VERSION >= v"0.7.0-DEV.3382"
    import Libdl
end

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("BKMaxflow was not build properly. Please run Pkg.build(\"BKMaxflow\")")
end
include(depsjl_path)

# Module initialization function
function __init__()
    # Always check your dependencies from `deps.jl`
    check_deps()
end

include(joinpath(@__DIR__, "..", "gen", "api", "bk_common.jl"))
include(joinpath(@__DIR__, "..", "gen", "api", "bk_api.jl"))
