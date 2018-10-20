module FieldDefaults

using FieldMetadata
using FieldMetadata: @default, @redefault, default

export @default_kw, default_kw

macro default_kw(ex)
    typ = get_type(ex)
    quote
        import FieldDefaults.default
        $(FieldMetadata.add_field_funcs(ex, :default))
        $(esc(typ))(;kwargs...) = default_kw($(esc(typ)); kwargs...)
    end
end

macro redefault_kw(ex)
    typ = get_type(ex)
    quote
        import FieldDefaults.default
        $(FieldMetadata.add_field_funcs(ex, :default; update=true))
        $(esc(typ))(;kwargs...) = default_kw($(esc(typ)); kwargs...)
    end
end

get_type(ex) =
    FieldMetadata.firsthead(ex, :struct) do typ_ex
        return FieldMetadata.namify(typ_ex.args[2])
    end

default_kw(::Type{T}; kwargs...) where T = begin
    fnames = fieldnames(T)
    defaults = get_default(T)

    for (key, val) in kwargs
        key in fnames || error("$key is not a field of $T")
        ind = findfirst(n -> n == key, fnames)
        defaults = (defaults[1:ind-1]..., val, defaults[ind+1:end]...)
    end

    T(defaults...)
end

get_default(args...) = default(args...)

end # module
