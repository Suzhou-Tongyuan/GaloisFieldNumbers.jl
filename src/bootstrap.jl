# For small M we can eagerly build a 2ᴹx2ᴹ lookup table without worrying about the memory
const SmallBits = Union{Val{1},Val{2},Val{3},Val{4},Val{5},Val{6},Val{7},Val{8}}

# the fast version of mod(x, 2^M-1)
function _unsafe_lookup_mod(x, ::Val{M}) where {M}
    N, tb = _build_mod_M_table(Val(M))
    i = x + N + 1
    return @inbounds tb[i]
end

@generated function _build_mod_M_table(::Val{M}) where {M}
    r = (-2^M):(2^(M + 1) - 1)
    n = 2^M - 1
    out = Vector{Int}(undef, length(r))
    for (i, x) in enumerate(r)
        out[i] = mod(x, n)
    end
    return 2^M, Tuple(out)
end

# precompute the table in compilation stage using naive multiply
# so that other operations can be done very cheap in runtime
@inline function _lookup_multiply(a::GF, b::GF) where {M,GF<:GFNumber{M}}
    return __lookup_multiply(a, b, Val(M))
end
@inline function __lookup_multiply(a::GF, b::GF, ::Val{M}) where {M,GF<:GFNumber{M}}
    E2P, P2E = _generate_gf_table(typeof(a))
    a, b = Int(a.x), Int(b.x)
    @inbounds if iszero(a) | iszero(b)
        return zero(GF)
    else
        r = _unsafe_lookup_mod(P2E[a + 1] + P2E[b + 1], Val(M))
        return GF(E2P[r + 1])
    end
end

# This fast version eliminates the need of if-branch and permits SIMD optimization
@inline function __lookup_multiply(a::GF, b::GF, ::T) where {T<:SmallBits,M,GF<:GFNumber{M}}
    N, lookup = _generate_gf_mul_table_smallbits(Val(M))
    x, y = a.x, b.x
    idx = x * N + y + one(y) # the lookup is a Tuple object
    v = @inbounds lookup[idx]
    return GF(v)
end

@generated function _generate_gf_mul_table_smallbits(::Val{M}) where {M}
    out = Matrix{UInt8}(undef, 2^M, 2^M)
    R = CartesianIndices(out)
    for i in 1:length(out)
        x, y = R[i].I .- 1
        out[i] = Integer(_naive_multiply(GF{M}(x), GF{M}(y)))
    end
    return 2^M, Tuple(out)
end

@inline function _lookup_inv(x::GF) where {GF<:GFNumber}
    iszero(x) && throw(DivideError())
    E2P, P2E = _generate_gf_table(GF)
    return GF(E2P[length(P2E) - P2E[x.x + 1]])
end

@inline function _lookup_divide(a::GF, b::GF) where {M,GF<:GFNumber{M}}
    iszero(b) && throw(DivideError())
    E2P, P2E = _generate_gf_table(typeof(a))
    a, b = a.x, b.x
    @inbounds if iszero(a) | iszero(b)
        return zero(GF)
    else
        r = _unsafe_lookup_mod(P2E[a + 1] - P2E[b + 1], Val(M))
        return GF(E2P[r + 1])
    end
end

@generated function _generate_gf_table(::Type{GFNumber{M,P,T}}) where {M,P,T}
    g = GFNumber{M,P}(2) # 2 is always the generator for multiplication
    # P2E
    lookup_table = map(x -> Int(x.x), _equivset(_naive_multiply, g))
    # E2P
    reverse_lookup_table = _reverse_map(lookup_table)
    return Tuple(lookup_table), Tuple(reverse_lookup_table)
end

function _equivset(op::Function, g::GFNumber)
    out = [one(g), g]
    next = op(g, g)
    while next != g
        push!(out, next)
        next = op(next, g)
    end
    return out
end

function _reverse_map(X::AbstractVector)
    out = Vector{Int}(undef, length(X))
    out[1] = one(Int)
    for i in 2:length(X)
        idx = findfirst((i - 1 == x for x in X))
        out[i] = rem(idx, length(out)) - 1
    end
    return out
end

# This naive implementation is slow because it "really"
# do the polynomial divrem calculation. But it is needed
# to generate the lookup table in the bootstrap compilation
# stage.
function _naive_multiply(a::GF, b::GF) where {GF<:GFNumber}
    pa, pb = Polynomial(a), Polynomial(b)
    pp = Polynomial(_int2poly(ppoly(a))) # prime poly
    pc = Polynomial(_naive_conv(_patched_coeffs(pa), _patched_coeffs(pb)))
    r = Polynomial{Int}(_naive_divrem(pc, pp)[2])
    return GF(r)
end

# modified from Polynomials by replacing +, - to xor
function _naive_divrem(num::T, den::T) where {T<:Polynomial}
    n = degree(num)
    m = degree(den)

    m == -1 && throw(DivideError())
    if m == 0 && den[0] ≈ 0
        throw(DivideError())
    end

    R = Float64

    deg = n - m + 1

    if deg ≤ 0
        return zero(typeof(num)), num
    end

    q_coeff = zeros(R, deg)
    r_coeff = R[num[i - 1] for i in 1:(n + 1)]

    @inbounds for i in n:-1:m
        q = r_coeff[i + 1] / den[m]
        q_coeff[i - m + 1] = q
        @inbounds for j in 0:m
            elem = den[j] * q
            r_coeff[i - m + j + 1] = xor(Int(r_coeff[i - m + j + 1]), Int(elem))
        end
    end
    resize!(r_coeff, min(length(r_coeff), m))

    return q_coeff, r_coeff
end

# +,- is replaced by xor
function _naive_conv(A::AbstractVector, B::AbstractVector)
    C = Vector{Int}(undef, length(A) + length(B) - 1)
    for k in eachindex(C)
        tmp = zero(eltype(C))
        for j in eachindex(A)
            if !checkbounds(Bool, B, k - j + 1)
                continue
            end
            tmp = xor(tmp, A[j] * B[k - j + 1])
        end
        C[k] = tmp
    end
    return C
end

Base.convert(::Type{Polynomial}, x::GFNumber) = Polynomial(_int2poly(x.x))
function Base.convert(::Type{T}, p::Polynomial) where {T<:GFNumber}
    return T(_poly2int(_patched_coeffs(p)))
end

Polynomials.Polynomial(x::GFNumber) = convert(Polynomial, x)
GFNumber{M}(p::Polynomial) where {M} = convert(GFNumber{M}, p)
GFNumber{M,P}(p::Polynomial) where {M,P} = convert(GFNumber{M,P}, p)
function GFNumber{M,P,T}(p::Polynomial) where {M,P,T<:Unsigned}
    return convert(GFNumber{M,P,T}, p)
end

# TODO(chenjiuning): accelerate this
function _int2poly(x::Integer)
    return [Int(x == '1') for x in reverse(bitstring(UInt(x)))]
end
function _poly2int(coeffs::AbstractVector{<:Integer})
    return reduce((x, y) -> x * 2 + y, reverse(coeffs))
end

# Polynomials v3.2.9 changes the behavior of coeffs for zero polynomial
# https://github.com/JuliaMath/Polynomials.jl/issues/503
_patched_coeffs(x::Polynomial) = iszero(x) ? [zero(eltype(x))] : coeffs(x)
