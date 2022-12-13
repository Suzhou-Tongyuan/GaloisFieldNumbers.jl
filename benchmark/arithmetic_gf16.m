% 标量计算

x = gf(randi(65535), 16);
y = gf(randi(65535), 16);
if y == 0
    y = gf(65535, 16);
end
f = @() x + y; timeit(f)
% 6.1182 μs
f = @() x * y; timeit(f)
% 34.375 μs1
f = @() x / y; timeit(f)
% 145.43 μs

% 矩阵运算

sz = [64, 64];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);

f = @() X * Y; timeit(f)
% 36.3 ms
f = @() X / Y; timeit(f)
% 447.8 ms

sz = [128, 128];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);

f = @() X * Y; timeit(f)
% 166.2 ms
f = @() X / Y; timeit(f)
% 3.1615 s

sz = [1024, 1024];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);

f = @() X * Y; tic; f(); toc
% 39.301166 s
f = @() X / Y; tic; f(); toc
% 1503.227894 s

% 逐点运算

sz = [64, 64];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 7.8428 μs

f = @() X .* Y; timeit(f)
% 161.11 μs

f = @() X ./ Y; timeit(f)
% 1200 μs

sz = [128, 128];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 14.953 μs

f = @() X .* Y; timeit(f)
% 421.48 μs

f = @() X ./ Y; timeit(f)
% 4000 μs

sz = [1024, 1024];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 2000 μs

f = @() X .* Y; timeit(f)
% 29.93 ms

f = @() X ./ Y; timeit(f)
% 268.4 ms

% 多项式乘法

sz = [64, 1];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
f = @() conv(X, Y); timeit(f)
% 3.0 ms

sz = [128, 1];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
f = @() conv(X, Y); timeit(f)
% 10.3 ms

sz = [1024, 1];
X = gf(randi(65535, sz), 16);
Y = gf(randi(65535, sz), 16);
f = @() conv(X, Y); timeit(f)
% 667.4 ms
