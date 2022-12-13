% 标量计算

x = gf(randi(7), 3);
y = gf(randi(7), 3);
if y == 0
    y = gf(7, 3);
end
f = @() x + y; timeit(f)
% 6.85 μs
f = @() x * y; timeit(f)
% 35.9 μs
f = @() x / y; timeit(f)
% 122 μs

% 矩阵运算

sz = [64, 64];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);

f = @() X * Y; timeit(f)
% 34.1 ms
f = @() X / Y; timeit(f)
% 558.7 ms

sz = [128, 128];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);

f = @() X * Y; timeit(f)
% 184 ms
f = @() X / Y; timeit(f)
% 3.901 s

sz = [1024, 1024];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);

f = @() X * Y; tic; f(); toc
% 39.3899 s
f = @() X / Y; tic; f(); toc
% 1693.245978 s

% 逐点运算

sz = [64, 64];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 12.8 μs

f = @() X .* Y; timeit(f)
% 172.7 μs

f = @() X ./ Y; timeit(f)
% 1500 μs

sz = [128, 128];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 17.6 μs

f = @() X .* Y; timeit(f)
% 545.7 μs

f = @() X ./ Y; timeit(f)
% 4400 μs

sz = [1024, 1024];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 503.8 μs

f = @() X .* Y; timeit(f)
% 28.44 ms

f = @() X ./ Y; timeit(f)
% 257.8 ms

% 多项式乘法

sz = [64, 1];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
f = @() conv(X, Y); timeit(f)
% 3.2 ms

sz = [128, 1];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
f = @() conv(X, Y); timeit(f)
% 10.1 ms

sz = [1024, 1];
X = gf(randi(7, sz), 3);
Y = gf(randi(7, sz), 3);
f = @() conv(X, Y); timeit(f)
% 642.9 ms
