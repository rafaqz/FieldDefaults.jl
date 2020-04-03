module FieldDefaults

using FieldMetadata, Setfield
using FieldMetadata: @default, @redefault, default, units
using Base: tail

export @default_kw, @udefault_kw, @redefault_kw, @reudefault_kw, default_kw, udefault_kw

macro default_kw(ex)
    default_kw_macro(ex, :default_kw, false)
end

macro redefault_kw(ex)
    default_kw_macro(ex, :default_kw, true)
end

macro udefault_kw(ex)
    default_kw_macro(ex, :udefault_kw, false)
end

macro reudefault_kw(ex)
    default_kw_macro(ex, :udefault_kw, true)
end

default_kw_macro(ex, func, update) = begin
    typ = FieldMetadata.firsthead(ex, :struct) do typ_ex
        FieldMetadata.namify(typ_ex.args[2])
    end
    quote
        import FieldDefaults.default
        $(FieldMetadata.add_field_funcs(ex, :default; update=update))
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
    T(insert_kwargs(fn -> get_default(T, fn) * units(T, fn), kwargs, T)...)

get_default(args...) = default(args...)

end # module
