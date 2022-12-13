# Because GF isn't a normal integer type, we can't directly reuse the AbstractUnitRange
# interface. Instead, we introduce a thin wrapper type here.
struct GFRange{M,P,T<:Unsigned,RT<:AbstractRange{T}} <: AbstractUnitRange{GF{M,P,T}}
    r::RT
end

@inline function GFRange{M,P,T}(r::AbstractRange{T}) where {M,P,T<:Unsigned}
    return GFRange{M,P,T,typeof(r)}(r)
end
@inline function GFRange(start::GF, stop::GF) where {M,P,T,GF<:GFNumber{M,P,T}}
    return GFRange{M,P,T}(UnitRange(start.x, stop.x))
end
@inline function GFRange(start::GF, step::Int, stop::GF) where {M,P,T,GF<:GFNumber{M,P,T}}
    return GFRange{M,P,T}((start.x):T(step):(stop.x))
end

@inline Base.:(:)(start::GF, stop::GF) where {GF<:GFNumber} = GFRange(start, stop)
@inline function Base.:(:)(start::GF, step::Int, stop::GF) where {GF<:GFNumber}
    return GFRange(start, step, stop)
end
function Base.:(:)(start::GF, step::GF, stop::GF) where {GF<:GFNumber}
    throw(ArgumentError("Step must be an integer, instead it is $step"))
end

function GFRange(start::GF, step::GF, stop::GF) where {GF<:GFNumber}
    throw(ArgumentError("Step must be an integer, instead it is $step"))
end

@inline Base.first(r::GFRange) = convert(eltype(r), first(r.r))
@inline Base.last(r::GFRange) = convert(eltype(r), last(r.r))
@inline Base.step(r::GFRange) = step(r.r)
@inline Base.length(r::GFRange) = length(r.r)

@inline Base.collect(r::GFRange) = eltype(r).(r.r)

Base.@propagate_inbounds function Base.iterate(r::GFRange)
    next = iterate(r.r)
    isnothing(next) && return nothing
    return (convert(eltype(r), next[1]), next[2])
end
Base.@propagate_inbounds function Base.iterate(r::GFRange, state)
    next = iterate(r.r, state)
    isnothing(next) && return nothing
    return (convert(eltype(r), next[1]), next[2])
end

function Base.show(io::IO, r::GFRange)
    if r.r isa UnitRange
        print(io, first(r), ':', last(r))
    else
        print(io, first(r), ':', step(r), ':', last(r))
    end
    return nothing
end
