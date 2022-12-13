using BenchmarkTools, GaloisFieldNumbers
using GaloisFieldNumbers: conv

# 标量计算

x, y = rand(GF8), rand(GF8)
y = iszero(y) ? GF8(7) : y

@btime $x + $y # 2.752 ns (0 allocations: 0 bytes)
@btime $x * $y # 2.752 ns (0 allocations: 0 bytes)
@btime $x / $y # 2.734 ns (0 allocations: 0 bytes)

# 矩阵运算
sz = (64, 64)
X = rand(GF8, sz...)
Y = rand(GF8, sz...)

@btime $X * $Y; # 132.137 μs (3 allocations: 25.19 KiB)
@btime $X / $Y; # 301.819 μs (4 allocations: 13.12 KiB)

sz = (128, 128)
X = rand(GF8, sz...)
Y = rand(GF8, sz...)

@btime $X * $Y; # 1.129 ms (5 allocations: 47.61 KiB)
@btime $X / $Y; # 2.079 ms (7 allocations: 49.39 KiB)

sz = (1024, 1024)
X = rand(GF8, sz...)
Y = rand(GF8, sz...)

@btime $X * $Y; # 618.964 ms (5 allocations: 1.03 MiB)
@btime $X / $Y; # 999.044 ms (7 allocations: 3.01 MiB)

# 逐点运算

sz = (64, 64)
X = rand(GF8, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF8, sz...))

@btime $X .+ $Y; # 630.807 ns (1 allocation: 4.19 KiB)
@btime $X .* $Y; # 2.352 μs (1 allocation: 4.19 KiB)
@btime $X ./ $Y; # 4.544 μs (1 allocation: 4.19 KiB)

sz = (128, 128)
X = rand(GF8, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF8, sz...))

@btime $X .+ $Y; # 1.151 μs (2 allocations: 16.11 KiB)
@btime $X .* $Y; # 9.994 μs (2 allocations: 16.11 KiB)
@btime $X ./ $Y; # 23.792 μs (2 allocations: 16.11 KiB)

sz = (1024, 1024)
X = rand(GF8, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF8, sz...))

@btime $X .+ $Y; # 79.150 μs (2 allocations: 1.00 MiB)
@btime $X .* $Y; # 530.919 μs (2 allocations: 1.00 MiB)
@btime $X ./ $Y; # 1.469 ms (2 allocations: 1.00 MiB)

# 多项式乘法

X = rand(GF8, 64)
Y = rand(GF8, 64)

@btime conv($X, $Y) # 2.937 μs (6 allocations: 864 bytes)

X = rand(GF8, 128)
Y = rand(GF8, 128)

@btime conv($X, $Y) # 11.087 μs (6 allocations: 1.34 KiB)

X = rand(GF8, 1024)
Y = rand(GF8, 1024)

@btime conv($X, $Y) # 618.184 μs (6 allocations: 8.50 KiB)

# 稀疏矩阵

using SparseArrays

X = sprand(GF8, 64, 64, 0.3)
Y = sprand(GF8, 64, 64, 0.3)
@btime $X * $Y; # 48.538 μs (5 allocations: 36.92 KiB)

X = sprand(GF8, 128, 128, 0.3)
Y = sprand(GF8, 128, 128, 0.3)
@btime $X * $Y; # 349.373 μs (6 allocations: 145.41 KiB)

X = sprand(GF8, 1024, 1024, 0.3)
Y = sprand(GF8, 1024, 1024, 0.3)
@btime $X * $Y; # 127.212 ms (6 allocations: 9.01 MiB)
