using SparseArrays

@testset "SparseArrays" begin
    x = GF3[
        5 0 0 6 3 6 0 0
        0 0 4 3 6 7 1 0
        7 2 5 7 6 0 0 0
        4 0 7 5 7 1 0 6
        3 7 7 5 0 0 3 0
        4 0 2 1 5 0 4 1
        0 0 5 7 0 0 3 0
        0 4 7 6 0 2 3 4
    ]
    y = GF3[
        1 2 2 7 7 2 2 0
        2 3 0 2 5 6 1 1
        7 5 7 7 0 2 4 0
        0 0 5 0 0 1 6 3
        1 0 4 3 7 0 1 1
        0 0 0 2 3 4 7 0
        6 6 5 0 4 3 6 4
        3 2 4 2 0 4 3 4
    ]
    sx, sy = sparse(x), sparse(y)

    @test sx .+ sy == x .+ y
    @test sx .- sy == x .- y
    @test sx .* sy == x .* y

    @test sx + sy == x + y
    @test sx * sy == x * y
    @test sx / sy == x / y
    @test sx \ sy == x \ y
end
