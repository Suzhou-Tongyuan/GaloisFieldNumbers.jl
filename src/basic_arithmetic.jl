@inline Base.iszero(x::GFNumber) = iszero(x.x)
@inline Base.one(x::GFNumber) = one(typeof(x))
@inline function Base.one(::Type{GFNumber{M,P,T}}) where {M,P,T}
    return GFNumber{M,P,T}(one(T))
end
@inline Base.oneunit(x::GFNumber) = oneunit(typeof(x))
@inline function Base.oneunit(::Type{GFNumber{M,P,T}}) where {M,P,T}
    return GFNumber{M,P,T}(oneunit(T))
end
@inline Base.zero(x::GFNumber) = zero(typeof(x))
@inline function Base.zero(::Type{GFNumber{M,P,T}}) where {M,P,T}
    return GFNumber{M,P,T}(zero(T))
end

@inline Base.hash(x::GF) where {GF<:GFNumber} = hash((x.x, GF))

@inline Base.typemin(::GF) where {GF<:GFNumber} = typemin(GF)
@inline Base.typemin(::Type{GF}) where {GF<:GFNumber} = GF(zero(eltype(GF)))
@inline Base.typemax(::GF) where {GF<:GFNumber} = typemax(GF)
@generated Base.typemax(::Type{GF}) where {GF<:GFNumber} = GF(2^capacity(GF) - 1)

@inline Base.abs(x::GFNumber) = x # always positive: -x == x
@inline Base.abs2(x::GFNumber) = x * x
@inline Base.conj(x::GFNumber) = x # conj(x) + x == 2real(x)

@inline Base.div(x::GF, y::GF) where {GF<:GFNumber} = /(x, y)
@inline function Base.rem(x::GF, y::GF) where {GF<:GFNumber}
    return iszero(y) ? throw(DivideError()) : zero(x)
end

@inline function Base.log2(a::GFNumber)
    iszero(a) && throw(DomainError(a, "log2 is not defined for zero"))
    _, P2E = _generate_gf_table(typeof(a))
    return @inbounds P2E[a.x + 1]
end

# This is technically not natural logarithm, but since
# we don't have e in Galois Field, it's okay to abuse
# the name as a deprecation.
function Base.log(x::GFNumber)
    Base.depwarn("log(x) is not natural logarithm, but logarithm to base 2.", :log)
    return log2(x)
end

function Base.sqrt(x::GFNumber)
    throw(DomainError(x, "sqrt is not defined for Galois field."))
end
function Base.:(^)(x::GFNumber, r::AbstractFloat)
    throw(DomainError(x, "^ for non-integer $r is not defined for Galois field."))
end
function Base.:(^)(x::GFNumber, r::Rational)
    throw(DomainError(x, "^ for non-integer $r is not defined for Galois field."))
end

@inline function Base.promote_rule(
    ::Type{GF1}, ::Type{GF2}
) where {M,P,GF1<:GFNumber{M,P},GF2<:GFNumber{M,P}}
    return GFNumber{M,P,promote_type(eltype(GF1), eltype(GF2))}
end

function Base.promote_rule(::Type{GF1}, ::Type{GF2}) where {GF1<:GFNumber,GF2<:GFNumber}
    msg = "GFNumber in different fields are not allowed to promote automatically, get: $(GF1) and $(GF2)"
    throw(ArgumentError(msg))
end

function Base.promote_rule(::Type{GF}, ::Type{T}) where {GF<:GFNumber,T}
    msg = "promotion between GFNumber and $T is not allowed"
    throw(ArgumentError(msg))
end

@inline Base.isless(a::GF, b::GF) where {GF<:GFNumber} = isless(a.x, b.x)
@inline Base.:(<)(a::GF, b::GF) where {GF<:GFNumber} = isless(a, b)
@inline Base.:(<=)(a::GF, b::GF) where {GF<:GFNumber} = <=(a.x, b.x)

@inline function Base.isapprox(a::GF, b::GF; kwargs...) where {GF<:GFNumber}
    return isapprox(a.x, b.x; kwargs...)
end

@inline Base.:(+)(x::GF, y::GF) where {GF<:GFNumber} = GF(xor(x.x, y.x))
@inline Base.:(-)(x::GF) where {GF<:GFNumber} = x
@inline Base.:(-)(x::GF, y::GF) where {GF<:GFNumber} = x + (-y)

@inline Base.:(*)(x::GF, y::GF) where {GF<:GFNumber} = _lookup_multiply(x, y)
@inline function Base.:(*)(x::GF, y::GF) where {GF<:GFNumber{1}}
    # no need to use lookup table, we know it in prior
    return ifelse(iszero(x) | iszero(y), zero(GF), one(GF))
end
@inline function Base.:(*)(x::Integer, y::GF) where {GF<:GFNumber}
    return iseven(x) ? zero(GF) : y
end
@inline Base.:(*)(x::GFNumber, y::Integer) = *(y, x)

@inline Base.inv(x::GFNumber) = _lookup_inv(x)
@inline Base.:(/)(x::GF, y::GF) where {GF<:GFNumber} = _lookup_divide(x, y)
@inline Base.:(\)(x::GF, y::GF) where {GF<:GFNumber} = _lookup_divide(y, x)

# not exported
@inline function conv(x::AbstractVector{GF}, y::AbstractVector{GF}) where {GF<:GFNumber}
    return reverse(coeffs(Polynomial(reverse(x)) * Polynomial(reverse(y))))
end
