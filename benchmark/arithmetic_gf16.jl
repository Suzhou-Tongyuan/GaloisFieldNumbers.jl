using BenchmarkTools, GaloisFieldNumbers
using GaloisFieldNumbers: conv

# 标量计算

x, y = rand(GF16), rand(GF16)
y = iszero(y) ? GF16(7) : y

@btime $x + $y # 2.476 ns (0 allocations: 0 bytes)
@btime $x * $y # 2.492 ns (0 allocations: 0 bytes)
@btime $x / $y # 2.976 ns (0 allocations: 0 bytes)

# 矩阵运算
sz = (64, 64)
X = rand(GF16, sz...)
Y = rand(GF16, sz...)

@btime $X * $Y; # 1.046 ms (3 allocations: 29.25 KiB)
@btime $X / $Y; # 1.404 ms (4 allocations: 24.94 KiB)

sz = (128, 128)
X = rand(GF16, sz...)
Y = rand(GF16, sz...)

@btime $X * $Y; # 8.095 ms (5 allocations: 63.73 KiB)
@btime $X / $Y; # 11.248 ms (7 allocations: 97.20 KiB)

sz = (1024, 1024)
X = rand(GF16, sz...)
Y = rand(GF16, sz...)

@btime $X * $Y; # 4.830 s (5 allocations: 2.03 MiB)
@btime $X / $Y; # 6.575 s (7 allocations: 6.01 MiB)

# 逐点运算

sz = (64, 64)
X = rand(GF16, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF16, sz...))

@btime $X .+ $Y; # 682.226 ns (1 allocation: 8.12 KiB)
@btime $X .* $Y; # 19.476 μs (1 allocation: 8.12 KiB)
@btime $X ./ $Y; # 19.930 μs (1 allocation: 8.12 KiB)

sz = (128, 128)
X = rand(GF16, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF16, sz...))

@btime $X .+ $Y; # 2.268 μs (2 allocations: 32.05 KiB)
@btime $X .* $Y; # 74.766 μs (2 allocations: 32.05 KiB)
@btime $X ./ $Y; # 76.296 μs (2 allocations: 32.05 KiB)

sz = (1024, 1024)
X = rand(GF16, sz...)
Y = replace!(x -> iszero(x) ? one(x) : x, rand(GF16, sz...))

@btime $X .+ $Y; # 165.483 μs (2 allocations: 2.00 MiB)
@btime $X .* $Y; # 4.839 ms (2 allocations: 2.00 MiB)
@btime $X ./ $Y; # 4.694 ms (2 allocations: 2.00 MiB)

# 多项式乘法

X = rand(GF16, 64)
Y = rand(GF16, 64)

@btime conv($X, $Y) # 13.660 μs (6 allocations: 1.28 KiB)

X = rand(GF16, 128)
Y = rand(GF16, 128)

@btime conv($X, $Y) # 55.468 μs (6 allocations: 2.31 KiB)

X = rand(GF16, 1024)
Y = rand(GF16, 1024)

@btime conv($X, $Y) # 3.971 ms (6 allocations: 16.75 KiB)

# 稀疏矩阵

using SparseArrays

X = sprand(GF16, 64, 64, 0.3)
Y = sprand(GF16, 64, 64, 0.3)
@btime $X * $Y; # 129.484 μs (5 allocations: 40.86 KiB)

X = sprand(GF16, 128, 128, 0.3)
Y = sprand(GF16, 128, 128, 0.3)
@btime $X * $Y; # 934.223 μs (6 allocations: 161.34 KiB)

X = sprand(GF16, 1024, 1024, 0.3)
Y = sprand(GF16, 1024, 1024, 0.3)
@btime $X * $Y; # 525.150 ms (6 allocations: 10.01 MiB)
