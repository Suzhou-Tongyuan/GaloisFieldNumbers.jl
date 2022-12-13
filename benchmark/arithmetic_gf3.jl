using BenchmarkTools, GaloisFieldNumbers
using GaloisFieldNumbers: conv

# 标量计算

x, y = rand(GF3), rand(GF3)
y = iszero(y) ? GF3(7) : y

@btime $x + $y # 2.483 ns (0 allocations: 0 bytes)
@btime $x * $y # 2.483 ns (0 allocations: 0 bytes)
@btime $x / $y # 3.018 ns (0 allocations: 0 bytes)

# 矩阵运算
sz = (64, 64)
X = rand(GF3, sz...)
Y = rand(GF3, sz...)

@btime $X * $Y; # 110.003 μs (3 allocations: 25.19 KiB)
@btime $X / $Y; # 268.074 μs (4 allocations: 13.12 KiB)

sz = (128, 128)
X = rand(GF3, sz...)
Y = rand(GF3, sz...)

@btime $X * $Y; # 1.069 ms (5 allocations: 47.61 KiB)
@btime $X / $Y; # 1.842 ms (7 allocations: 49.39 KiB)

sz = (1024, 1024)
X = rand(GF3, sz...)
Y = rand(GF3, sz...)

@btime $X * $Y; # 612.393 ms (5 allocations: 1.03 MiB)
@btime $X / $Y; # 854.530 ms (7 allocations: 3.01 MiB)

# 逐点运算

sz = (64, 64)
X = rand(GF3, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF3, sz...))

@btime $X .+ $Y; # 544.129 ns (1 allocation: 4.19 KiB)
@btime $X .* $Y; # 2.381 μs (1 allocation: 4.19 KiB)
@btime $X ./ $Y; # 4.994 μs (1 allocation: 4.19 KiB)

sz = (128, 128)
X = rand(GF3, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF3, sz...))

@btime $X .+ $Y; # 1.283 μs (2 allocations: 16.11 KiB)
@btime $X .* $Y; # 8.935 μs (2 allocations: 16.11 KiB)
@btime $X ./ $Y; # 28.684 μs (2 allocations: 16.11 KiB)

sz = (1024, 1024)
X = rand(GF3, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF3, sz...))

@btime $X .+ $Y; # 83.613 μs (2 allocations: 1.00 MiB)
@btime $X .* $Y; # 507.269 μs (2 allocations: 1.00 MiB)
@btime $X ./ $Y; # 2.054 ms (2 allocations: 1.00 MiB)

# 多项式乘法

X = rand(GF3, 64)
Y = rand(GF3, 64)

@btime conv($X, $Y) # 2.889 μs (6 allocations: 864 bytes)

X = rand(GF3, 128)
Y = rand(GF3, 128)

@btime conv($X, $Y) # 10.657 μs (6 allocations: 1.34 KiB)

X = rand(GF3, 1024)
Y = rand(GF3, 1024)

@btime conv($X, $Y) # 602.277 μs (6 allocations: 8.50 KiB)

# 稀疏矩阵

using SparseArrays

X = sprand(GF3, 64, 64, 0.3)
Y = sprand(GF3, 64, 64, 0.3)
@btime $X * $Y; # 53.769 μs (5 allocations: 36.92 KiB)

X = sprand(GF3, 128, 128, 0.3)
Y = sprand(GF3, 128, 128, 0.3)
@btime $X * $Y; # 347.486 μs (6 allocations: 145.41 KiB)

X = sprand(GF3, 1024, 1024, 0.3)
Y = sprand(GF3, 1024, 1024, 0.3)
@btime $X * $Y; # 129.268 ms (6 allocations: 9.01 MiB)
