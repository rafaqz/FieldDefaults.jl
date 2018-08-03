__precompile__()

module Defaults

using MetaFields, Setfield
using MetaFields: @default, default

export @default_kw, @redefault_kw, default_kw

macro default_kw(ex) 
    typ = get_type(ex)
    quote 
        import Defaults.default
        @default $(esc(ex))
        $typ(;kwargs...) = default_kw($typ; kwargs...)
    end
end

# macro redefault_kw(ex) 
#     typ = get_type(ex)
#     quote 
#         import Defaults.default
#         @redefault $(esc(ex))
#         $typ(;kwargs...) = default_kw($typ; kwargs...)
#     end
# end

get_type(ex) = 
    MetaFields.firsthead(ex, :type) do typ_ex
        return MetaFields.namify(typ_ex.args[2])
    end |> esc

default_kw(::Type{T}; kwargs...) where T = begin
    fnames = fieldnames(T)
    defaults = get_default(T)

    for (key, val) in kwargs
        key in fnames || error("$key is not a field of $T")
        ind = findfirst(n -> n == key, fnames)
        defaults = @set defaults[ind] = val
    end

    T(defaults...)
end


get_default(T::Type) = default(T) 

end # module
