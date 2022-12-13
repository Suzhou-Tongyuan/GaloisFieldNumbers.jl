@testset "GF3" begin
    T = GF{3,11,UInt8}
    r = collect(typemin(T):typemax(T))
    x, y = copy(r), collect(r')

    @test x .+ y == T[
        0 1 2 3 4 5 6 7
        1 0 3 2 5 4 7 6
        2 3 0 1 6 7 4 5
        3 2 1 0 7 6 5 4
        4 5 6 7 0 1 2 3
        5 4 7 6 1 0 3 2
        6 7 4 5 2 3 0 1
        7 6 5 4 3 2 1 0
    ]
    @test x .- y == x .+ y
    @test x .* y == T[
        0 0 0 0 0 0 0 0
        0 1 2 3 4 5 6 7
        0 2 4 6 3 1 7 5
        0 3 6 5 7 4 1 2
        0 4 3 7 6 2 5 1
        0 5 1 4 2 7 3 6
        0 6 7 1 5 3 2 4
        0 7 5 2 1 6 4 3
    ]
    @test x ./ y[:, 2:end] == T[
        0 0 0 0 0 0 0
        1 5 6 7 2 3 4
        2 1 7 5 4 6 3
        3 4 1 2 6 5 7
        4 2 5 1 3 7 6
        5 7 3 6 1 4 2
        6 3 2 4 7 1 5
        7 6 4 3 5 2 1
    ]
    @test x .÷ y[:, 2:end] == T[
        0 0 0 0 0 0 0
        1 5 6 7 2 3 4
        2 1 7 5 4 6 3
        3 4 1 2 6 5 7
        4 2 5 1 3 7 6
        5 7 3 6 1 4 2
        6 3 2 4 7 1 5
        7 6 4 3 5 2 1
    ]
    @test all(iszero, rem.(x, y[:, 2:end]))
    @test x[2:end] .\ y == T[
        0 1 2 3 4 5 6 7
        0 5 1 4 2 7 3 6
        0 6 7 1 5 3 2 4
        0 7 5 2 1 6 4 3
        0 2 4 6 3 1 7 5
        0 3 6 5 7 4 1 2
        0 4 3 7 6 2 5 1
    ]
    @test (.-x) == x
    @test 2 .* x == x .* 2 == zeros(eltype(x), size(x))
    @test 3 .* x == x .* 3 == x
    @test inv.(x[2:end]) == T[1, 5, 6, 7, 2, 3, 4]

    @test log2.(x[2:end]) == [0, 1, 3, 2, 6, 4, 5]
    @test [0, 1, 3, 2, 6, 4, 5] == @suppress_err(log.(x[2:end]))

    # matrix operation
    A = GF3[
        3 3 7 2
        4 3 2 3
        5 1 4 2
        6 2 1 6
    ]
    B = GF3[
        0 1 4 6
        0 7 2 7
        6 4 1 3
        2 1 5 3
    ]
    @test inv(A) == GF3[
        0 6 2 4
        4 6 0 6
        7 3 2 7
        7 1 4 7
    ]
    @test A * B == GF3[
        0 2 7 7
        1 6 6 4
        1 6 5 5
        1 1 3 5
    ]
    @test A / B == GF3[
        5 7 4 3
        7 2 7 0
        3 6 4 0
        2 0 7 1
    ]
    @test A \ B == GF3[
        4 3 7 5
        7 6 2 0
        2 1 3 2
        0 1 1 6
    ]

    X = GF3[3, 5, 2, 4, 1, 0, 6, 0]
    Y = GF3[2, 1, 2, 1, 2, 5, 6, 3]
    convref = GF3[6, 2, 7, 3, 1, 5, 3, 3, 4, 0, 6, 0, 2, 1, 0]
    @test GaloisFieldNumbers.conv(X, Y) == convref
end
