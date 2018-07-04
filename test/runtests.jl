using Defaults
using Defaults: get_default

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@kw_default struct Test
    foo::Int    | 1
    bar::Symbol | :bar
end

@test get_default(Test, Val{:foo}) == 1
@test get_default(Test, Val{:bar}) == :bar

t = Test()
@test t.foo == 1
@test t.bar == :bar

t = Test(foo = 2, bar=:foobar)
@test t.foo == 2
@test t.bar == :foobar
