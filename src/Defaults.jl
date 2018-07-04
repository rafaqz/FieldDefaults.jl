__precompile__()

module Defaults

using MetaFields
export @default, @default_kw, @redefault_kw, default, default_kw
@metafield default nothing

macro default_kw(ex) 
    typ = get_type(ex)
    quote 
        import Defaults.default
        @default $(esc(ex))
        $typ(;kwargs...) = default_kw($typ; kwargs...)
    end
end

macro redefault_kw(ex) 
    typ = get_type(ex)
    quote 
        import Defaults.default
        @redefault $(esc(ex))
        $typ(;kwargs...) = default_kw($typ; kwargs...)
    end
end

get_type(ex) = 
    MetaFields.firsthead(ex, :type) do typ_ex
        return MetaFields.namify(typ_ex.args[2])
    end |> esc

default_kw(::Type{T}; kwargs...) where T = begin
    dict = Dict()
    fnames = fieldnames(T)
    for fname in fnames
       dict[fname] = get_default(T, Val{fname})
    end

    for (key, val) in kwargs
        key in fnames || error("$key is not a field of $T")
        dict[key] = val
    end

    T(getindex.(dict, fnames)...)
end

get_default(T::Type, F::Type) = default(T, F) 

end # module
