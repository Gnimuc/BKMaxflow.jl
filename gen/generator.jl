using Clang.wrap_c
using Clang.cindex

llvmcfg = "llvm-config"

@static if is_apple()
    using Homebrew
    !Homebrew.installed("llvm") && Homebrew.add("llvm")
    llvmcfg = joinpath(Homebrew.prefix(), "opt/llvm/bin/llvm-config")
end

const LLVM_VERSION = readchomp(`$llvmcfg --version`)
const LLVM_LIBDIR  = readchomp(`$llvmcfg --libdir`)
const LLVM_INCLUDE = joinpath(LLVM_LIBDIR, "clang", LLVM_VERSION, "include")

const BK_INCLUDE = joinpath(@__DIR__, "..", "deps", "usr", "include") |> normpath
const BK_HEADERS = [joinpath(root, file) for (root, dirs, files) in walkdir(BK_INCLUDE) for file in files]

function rewriter(ex::Expr)
    if Meta.isexpr(ex, :type)
        block = ex.args[3]
        isempty(block.args) && (typename = ex.args[2]; return :($typename = Void);)
    end
    Meta.isexpr(ex, :function) || return ex
    signature = ex.args[1]
    for i = 2:length(signature.args)
        func_arg = signature.args[i]
        if !(func_arg isa Symbol) && Meta.isexpr(func_arg, :(::))
            signature.args[i] = func_arg.args[1]
        end
    end
    return ex
end
rewriter(A::Array) = [rewriter(a) for a in A]
rewriter(arg) = arg

function wrap_header(top_hdr::String, cursor_header::String)
    startswith(dirname(cursor_header), BK_INCLUDE) && (top_hdr == cursor_header)
end

wc = wrap_c.init(;
                headers = BK_HEADERS,
                output_file = joinpath(@__DIR__, "api", "bk_api.jl"),
                common_file = joinpath(@__DIR__, "api", "bk_common.jl"),
                clang_includes = vcat(LLVM_INCLUDE, BK_INCLUDE),
                header_wrapped = wrap_header,
                header_library = x->"libbkmaxflow",
                clang_diagnostics = true,
                rewriter=rewriter)

# wrap_structs, immutable_structs
wc.options = wrap_c.InternalOptions(true, true)
run(wc)
