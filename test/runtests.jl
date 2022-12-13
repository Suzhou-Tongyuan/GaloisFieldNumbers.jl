using Test
using GaloisFieldNumbers
using Suppressor
using SparseArrays

@testset "GaloisFieldNumbers" begin
    @testset "constructors" begin
        @test GF === GFNumber

        x = @inferred GF{3}(3)
        @test x isa GF{3,11,UInt8}
        x = @inferred GF{3,13}(3)
        @test x isa GF{3,13,UInt8}
        x = @inferred GF{3,13,UInt}(3)
        @test x isa GF{3,13,UInt}

        # These are invalid, but delibrately allowed for maximal performance
        x = @inferred GF{3}(100)
        @test x.x == 100
        x = @inferred GF{3,3}(100)
        @test x.x == 100

        @test GF3 === GF{3,11,UInt8}
        x = @inferred GF3(3)
        @test x isa GF{3,11,UInt8}

        msg = "GF with M=1000 is not supported yet"
        @test_throws ArgumentError(msg) GF{1000}(3)

        # but the lowercase version will do the check
        msg = "x should be in range [0, 11], instead it is: 100"
        @test_throws ArgumentError(msg) gf{3}(100)
    end

    @testset "basic properties" begin
        x = GF3(3)
        @test capacity(x) == 3
        @test ppoly(x) == 11
        @test eltype(x) == UInt8
        @test x.x == 3
        @test typemin(x) == GF3(0)
        @test typemax(x) == GF3(7)

        x = GF{7}(3)
        @test capacity(x) == 7
        @test ppoly(x) == 137
        @test eltype(x) == UInt8
        @test x.x == 3
        @test typemin(x) == GF7(0)
        @test typemax(x) == GF7(127)
    end

    @testset "conversions" begin
        @test GF3(GF3(3)) === GF3(3)
        @test GF{3,11,UInt16}(GF{3,11,UInt8}(1)) === GF{3,11,UInt16}(1)
    end

    @testset "random" begin
        x = rand(GF3)
        @test x isa GF3
        x = rand(GF3, 64, 64)
        @test x isa Matrix{GF3}
        @test all(GF3(0) .<= x .<= GF3(7))
        # ensure that this is a normal distribution
        @test all(unique(x)) do v
            r = count(isequal(v), x) / length(x)
            isapprox(r, 1 / 8; atol=0.2)
        end
    end

    @testset "promote" begin
        x, y = GF{3}(UInt8(1)), GF{3}(UInt16(1))
        @test eltype(x) == UInt8
        @test eltype(y) == UInt16
        x, y = promote(x, y)
        @test eltype(x) == eltype(y) == promote_type(UInt8, UInt16)

        # promotion between GFNumber and normal numbers (Int, Float64) are not allowed
        # because they will cause confusions
        msg = "promotion between GFNumber and $Int is not allowed"
        @test_throws ArgumentError(msg) begin
            promote(GF{3}(1), 1)
        end
        msg = "promotion between GFNumber and Float64 is not allowed"
        @test_throws ArgumentError(msg) begin
            promote(GF{3}(1), 1.0)
        end

        # promotion are only allowed when both M and P are the same
        msg = "GFNumber in different fields are not allowed to promote automatically, get: GF7 and GF3"
        @test_throws ArgumentError(msg) begin
            promote(GF{7}(1), GF{3}(1))
        end
        msg = "GFNumber in different fields are not allowed to promote automatically, get: GF3 and GFNumber{3, 13, UInt8}"
        @test_throws ArgumentError(msg) begin
            promote(GF{3,11}(1), GF{3,13}(1))
        end
    end

    @testset "range" begin
        r = GF{3}(0):GF{3}(7)
        @test r isa GFRange{3,11,UInt8,UnitRange{UInt8}}
        @test length(r) == 8
        @test collect(r) == GF{3,11,UInt8}[0, 1, 2, 3, 4, 5, 6, 7]

        r = GF{3}(8):GF{3}(7)
        @test r isa GFRange{3,11,UInt8,UnitRange{UInt8}}
        @test length(r) == 0
        @test collect(r) == GF{3,11,UInt8}[]

        r = GF{3}(0):GF{3}(7)
        @test length(r) == 8
        @test first(r) == GF{3}(0)
        @test last(r) == GF{3}(7)
        @test step(r) == 1

        @test "GF3(0):2:GF3(6)" == @capture_out show(GF3(0):2:GF3(6))
        @test "GF3(0):GF3(6)" == @capture_out show(GF3(0):GF3(6))

        function get_iterated_values(r)
            out = eltype(r)[]
            for x in r
                push!(out, x)
            end
            return out
        end
        @test get_iterated_values(GF3(0):GF3(7)) == GF3[0, 1, 2, 3, 4, 5, 6, 7]
        @test get_iterated_values(GF3(0):2:GF3(7)) == GF3[0, 2, 4, 6]

        msg = "Step must be an integer, instead it is GF3(2)"
        @test_throws ArgumentError(msg) GF3(0):GF3(2):GF3(7)
        @test_throws ArgumentError(msg) GFRange(GF3(0), GF3(2), GF3(7))
    end

    @testset "show" begin
        X = GF{3}.(collect(reshape(0:7, 2, 4)))
        msg = @capture_out show(X[1])
        @test msg == "GF3(0)"
        msg = @capture_out show(X)
        @test msg == "GF3[0 2 4 6; 1 3 5 7]"

        X = GF{3,13,UInt8}.(collect(reshape(0:7, 2, 4)))
        msg = @capture_out show(X[1])
        @test msg == "GFNumber{3, 13, UInt8}(0)"
        msg = @capture_out show(X)
        @test msg == "GFNumber{3, 13, UInt8}[0 2 4 6; 1 3 5 7]"
    end

    @testset "arithmetic" begin
        x, y = GF3(3), GF3(5)
        @test one(x) === oneunit(x) === GF3(1)
        @test zero(x) === GF3(0)
        @test iszero(GF3(0)) && !iszero(GF3(1))

        @test x < y
        @test x <= y
        @test y > x
        @test y >= x
        @test !isapprox(x, y)

        @test sort(unique(GF3[1, 2, 1])) == GF3[1, 2]

        @test_throws DivideError() GF3(3) / GF3(0)
        @test_throws DivideError() div(GF3(3), GF3(0))
        @test_throws DivideError() rem(GF3(3), GF3(0))
        @test_throws DomainError(GF3(0), "log2 is not defined for zero") log2(GF3(0))
        err = DomainError(GF3(3), "^ for non-integer 0.3 is not defined for Galois field.")
        @test_throws err GF3(3)^0.3
        err = DomainError(GF3(3), "^ for non-integer 1//2 is not defined for Galois field.")
        @test_throws err GF3(3)^(1//2)

        @testset "numerical" begin
            include("numerical/gf3.jl")
            include("numerical/gf8.jl")
            include("numerical/gf16.jl")
        end

        # ensure the generated Tuple is inferrable; otherwise the performance will be terrible
        N, lookup = @inferred GaloisFieldNumbers._generate_gf_mul_table_smallbits(Val(8))
        @test length(lookup) == 65536
    end

    include("sparse.jl")
end
