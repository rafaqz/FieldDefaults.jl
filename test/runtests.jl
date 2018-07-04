using Defaults
using Defaults: get_default

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@default_kw struct TestStruct
    foo::Int    | 1
    bar::Symbol | :bar
end

@test get_default(TestStruct, Val{:foo}) == 1
@test get_default(TestStruct, Val{:bar}) == :bar

t = TestStruct()
@test t.foo == 1
@test t.bar == :bar

t = TestStruct(foo = 2, bar=:foo)
@test t.foo == 2
@test t.bar == :foo

@redefault_kw struct TestStruct
    foo::Int    | 3
    bar::Symbol | :foobar
end

t = TestStruct()
@test t.foo == 3
@test t.bar == :foobar
