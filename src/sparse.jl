# compat for SparseArrays
using SparseArrays: AbstractSparseMatrixCSC

# float is not defined
function Base.:(/)(
    A::AbstractSparseMatrixCSC{GF}, B::AbstractSparseMatrixCSC{GF}
) where {GF<:GFNumber}
    return Matrix(A) / Matrix(B)
end

function Base.:(\)(A::AbstractSparseMatrixCSC{GF}, B::AbstractVecOrMat) where {GF<:GFNumber}
    return Matrix(A) \ Matrix(B)
end
