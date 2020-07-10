module FieldDefaults

using FieldMetadata, Setfield
using FieldMetadata: @default, default, units
using Base: tail

export @default_kw, @udefault_kw, default_kw, udefault_kw

macro default_kw(ex)
    default_kw_unknown(ex, :default_kw, false)
end

macro default_kw(typ, ex)
    default_kw_block(typ, ex, :default_kw)
end

macro udefault_kw(ex)
    default_kw_unknown(ex, :udefault_kw, false)
end

macro udefault_kw(typ, ex)
    default_kw_block(typ, ex, :udefault_kw)
end

default_kw_block(typ, ex, func) = begin
    quote
        import FieldDefaults.default
        $(FieldMetadata.funcs_from_block(typ, ex, :default, Any))
        $(esc(typ))(;kwargs...) = $func($(esc(typ)); kwargs...)
    end
end

default_kw_unknown(ex, func, update) = begin
    typ = FieldMetadata.firsthead(ex, :struct) do typ_ex
        FieldMetadata.namify(typ_ex.args[2])
    end
    quote
        import FieldDefaults.default
        $(FieldMetadata.funcs_from_unknown(ex, :default, Any; update=update))
        $(esc(typ))(;kwargs...) = $func($(esc(typ)); kwargs...)
    end
end

insert_kwargs(kwargs, T::Type) = insert_kwargs(fn -> get_default(T, fn), kwargs, T)
insert_kwargs(defaultfunc, kwargs, T::Type) =
    insert_kwargs(defaultfunc, Tuple(fieldnames(T)), keys(kwargs.data), Tuple(kwargs.data))
insert_kwargs(defaultfunc, fieldnames::Tuple, keys, vals) = begin
    fn = fieldnames[1]
    ind = findfirst(n -> n == fn, keys)
    def = ind == nothing ? defaultfunc(fn) : vals[ind]
    (def, insert_kwargs(defaultfunc, tail(fieldnames), keys, vals)...)
end
insert_kwargs(defaultfunc, fieldnames::Tuple{}, keys, vals) = ()

default_kw(::Type{T}; kwargs...) where T = T(insert_kwargs(kwargs, T)...)

# Combined default() and units()
udefault_kw(::Type{T}; kwargs...) where T =
    T(insert_kwargs(fn -> maybeaddunits(get_default(T, fn), units(T, fn)), kwargs, T)...)

# Add units to Real, otherwise return as-is
maybeaddunits(def::Union{Real,AbstractArray}, units) = def * units
maybeaddunits(def, units) = def

# Somewhere to add custom methods to modify `default`
get_default(args...) = default(args...)

end # module
