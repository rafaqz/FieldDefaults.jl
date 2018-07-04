__precompile__()

module Defaults

using MetaFields

export @default, @kw_default, default, kw_default

@metafield default nothing

macro kw_default(ex)
    typ = MetaFields.firsthead(ex, :type) do typ_ex
        return MetaFields.namify(typ_ex.args[2])
    end |> esc

    quote 
        import Defaults.default
        @default $(esc(ex))
        $typ(;kwargs...) = kw_default($typ; kwargs...)
    end
end

kw_default(::Type{T}; kwargs...) where T = begin
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
