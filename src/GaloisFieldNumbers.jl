module GaloisFieldNumbers

using Polynomials
using Random: Random, SamplerType, AbstractRNG
using SparseArrays

export GF, gf, GFNumber
export capacity, ppoly, eltype
export GFRange

# We only support P=2 case for now, but let's leave it here in case we want to make a more
# generic implementation.
abstract type GaloisFieldNumber <: Number end

include("prime_polynomial.jl")

"""
    GF{M}(x)
    GF{M,P}(x)
    GF{M,P,T<:Unsigned}(x::T)

Construct the element `x` in Galois Field with capacity `2ᴹ` and prime polynomial `P`. Both
`M` and `P` are Int numbers.

The default parameter `P` is the smallest prime polynomial in field 2ᴹ. Convenient alias are
made for `GF{M}`, e.g., `GF3(3)` is equivalent to `GF{3,11,UInt8}(3)`.

# Examples

```julia
julia> x = GF3(7) # equivalent to GF{3}(7)
GF3(7)

julia> capacity(x), ppoly(x), eltype(x)
(3, GF3(11), UInt8)

julia> x = GF{3,13}(7)
GFNumber{3, 13, UInt8}(7)

julia> capacity(x), ppoly(x), eltype(x)
(3, GFNumber{3, 13, UInt64}(13), UInt64)

julia> x = GF{3,13,UInt8}(3)
GFNumber{3, 13, UInt8}(3)

julia> capacity(x), ppoly(x), eltype(x)
(3, GFNumber{3, 13, UInt8}(13), UInt8)
```

GF numbers has different +, * definitions:

```jldoctest
julia> GF3(2) + GF3(3) # xor
GF3(1)

julia> GF3(2) * GF3(3) # polynomial product
GF3(6)
```

GF numbers can be put into common arrays, e.g.,

```jldoctest
julia> GF3.(0:4)
5-element Vector{GF3}:
 0
 1
 2
 3
 4
```

!!! warn "value check"
    `GF` and its alias (e.g., `GF3`) does not check the value for performance consideration,
    thus it won't error on invalid input e.g., `GF3(10000)`. If such safety is required, use
    the lowecase version, e.g., `gf3(10000)`.

```jldoctest
julia> GF3(10000) # invalid input, but won't error
GF3(10000)

julia> gf3(10000)
ERROR: ArgumentError: x should be in range [0, 11], instead it is: 10000
...
```
"""
struct GFNumber{M,P,T<:Unsigned} <: GaloisFieldNumber
    # Generically speaking, a GF number is a polynomial with coefficients in GF(2), e.g.,
    # (1, 0, 1, 1). If we see them as bit vector, then it can be represented by an integer.
    # This representation permits storage and efficient arithmetic operations (e.g., xor, +,
    # *). This is why we store GF(2^M) numbers as unsigned integer `T`
    x::T
end

# Julia doesn't support parameter for normal function gf{3}(3), thus we introduce a helper
# type gf to mimic this.
struct gf{M,P,T}
    # disable auto generated constructors
    gf(x) = error("unsupported usage")
end
gf{M}(x) where {M} = gf{M,ppoly(Val(M))}(x)
gf{M,P}(x::T) where {M,P,T<:Unsigned} = gf{M,P,T}(x)
gf{M,P}(x::Int) where {M,P} = gf{M,P,UInt}(x)
gf{M,P,T}(x) where {M,P,T} = GFNumber{M,P,T}(gfcheck(x, M, P))

function gfcheck(x::Integer, M::Int, P::Int)
    # TODO:(chenjiuning) check isprime(P)
    0 <= x <= P || throw(ArgumentError("x should be in range [0, $P], instead it is: $x"))
    return x
end

# GF is used in this package for two meanings: 1) the alias GF for convenience that is an
# abstract type, and 2) the type parameter for dispatch that is an concrete type when used.
# For instance, the following two usages introduce different meanings and results:
# f(x::GF) = GF # GF is the alias GFNumber
# f(x::GF) where {GF<:GFNumber} = GF # GF is a concrete type `typeof(x)`
const GF = GFNumber

# used for promotion
@inline function GF{M,P,T1}(x::GF{M,P,T2}) where {M,P,T1<:Unsigned,T2<:Unsigned}
    return GF{M,P,T1}(x.x)
end

function GF{M,P,T}(x) where {M,P,T<:Number}
    throw(ArgumentError("type $T is not supported, use `Unsigned` number instead"))
end
function GF(x, m::Integer)
    throw(ArgumentError("use `GF{m}(x)` format instead."))
end

@inline GF{M,P,Told}(::Type{T}) where {M,P,Told,T} = GF{M,P,T}
@inline GF{M}(x) where {M} = GF{M,ppoly(Val(M))}(x)
@inline function GF{M}(x::GF{M}) where {M}
    return GF{M,ppoly(Val(M))}(x)
end
@inline GF{M,P}(x::T) where {M,P,T<:Unsigned} = GF{M,P,T}(x)
@inline function GF{M,P}(x::Int) where {M,P}
    return GF{M,P}(_rawtype(Val(M))(x))
end

@inline Base.eltype(::GF{M,P,T}) where {M,P,T} = T
@inline Base.eltype(::Type{GF{M,P,T}}) where {M,P,T} = T

@inline Base.convert(::Type{Int}, x::GF) = Int(x.x)
@inline Base.Int(x::GF) = Int(x.x)

function Base.show(io::IO, x::GF{M,P,T}) where {M,P,T}
    compact = get(io, :compact, false)::Bool
    if compact || get(io, :typeinfo, Any) === typeof(x)
        print(io, x.x)
    else
        print(io, typeof(x), '(', x.x, ')')
    end
    return nothing
end

"""
    ppoly(m::Integer, [select=first])
    ppoly(m::GF{M,P})

Get the prime polynomial of given Galois Field of order `m`. If there are multiple
prime polynomials, the first(smallest) one is chosen by default. If `m` is a `GF` number,
its type `P` is returned.

```julia
julia> ppoly(3)
11

julia> ppoly(3, maximum)
13

julia> ppoly(GF{3, 11}(0))
11
```
"""
@generated function ppoly(::Val{M}, select::Function) where {M}
    M > length(_T_GF_PRIME_POLY_) &&
        throw(ArgumentError("GF with M=$M is not supported yet"))
    Ps = _T_GF_PRIME_POLY_[M]
    return :(select($Ps))
end
@inline ppoly(::Val{M}) where {M} = ppoly(Val(M), first)
@inline ppoly(x::GF) = ppoly(typeof(x))
@inline ppoly(::Type{GF{M,P,T}}) where {M,P,T} = P

"""
    capacity(x)

Infer the capacity `M` from `GF{M}`.
"""
@inline capacity(::GF{M}) where {M} = M
@inline capacity(::Type{GF}) where {M,GF<:GF{M}} = M

@inline Base.Integer(x::GF) = Base.Integer(x.x) # x.x as the representative element

include("bootstrap.jl")
include("basic_arithmetic.jl")
include("random.jl")
include("iterators.jl")
include("sparse.jl")

@generated function _rawtype(::Val{M}) where {M}
    UT = if M <= 8
        UInt8
    elseif M <= 16
        UInt16
    elseif M <= 32
        UInt32
    else
        UInt64
    end
    return UT
end
# make alias, e.g., gf3
for M in 1:length(_T_GF_PRIME_POLY_)
    sym = Symbol(:GF, M)
    T = GF{M,ppoly(Val(M)),_rawtype(Val(M))}
    @eval begin
        export $sym
        const $sym = $T
    end

    sym = Symbol(:gf, M)
    P = ppoly(Val(M))
    T = gf{M,ppoly(Val(M)),_rawtype(Val(M))}
    @eval begin
        export $sym
        const $sym = $T
    end
end

end # module
