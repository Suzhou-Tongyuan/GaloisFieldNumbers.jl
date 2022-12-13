function Random.rand(r::AbstractRNG, ::SamplerType{X}) where {X<:GFNumber}
    return X(rand(r, (typemin(X).x):(typemax(X).x)))
end

function rand!(r::AbstractRNG, A::Array{X}, ::SamplerType{X}) where {X<:GFNumber}
    T = eltype(X)
    At = unsafe_wrap(Array, reinterpret(Ptr{T}, pointer(A)), size(A))
    Random.rand!(r, At, SamplerType{T}())
    return A
end
