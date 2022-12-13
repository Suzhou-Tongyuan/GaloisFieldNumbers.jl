% 标量计算

x = gf(randi(255), 8);
y = gf(randi(255), 8);
if y == 0
    y = gf(255, 8);
end
f = @() x + y; timeit(f)
% 15.114 μs
f = @() x * y; timeit(f)
% 45.816 μs
f = @() x / y; timeit(f)
% 142.35 μs

% 矩阵运算

sz = [64, 64];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);

f = @() X * Y; timeit(f)
% 37.6 ms
f = @() X / Y; timeit(f)
% 484.7 ms

sz = [128, 128];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);

f = @() X * Y; timeit(f)
% 182.8 ms
f = @() X / Y; timeit(f)
% 3.2274 s

sz = [1024, 1024];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);

f = @() X * Y; tic; f(); toc
% 37.327235 s
f = @() X / Y; tic; f(); toc
% 1501.003467 s

% 逐点运算

sz = [64, 64];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 10.014 μs

f = @() X .* Y; timeit(f)
% 190.55 μs

f = @() X ./ Y; timeit(f)
% 1300 μs

sz = [128, 128];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 15.67 μs

f = @() X .* Y; timeit(f)
% 374.06 μs

f = @() X ./ Y; timeit(f)
% 4200 μs

sz = [1024, 1024];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
Y(Y == 0) = 1;

f = @() X + Y; timeit(f)
% 431.47 μs

f = @() X .* Y; timeit(f)
% 30.4 ms

f = @() X ./ Y; timeit(f)
% 260.7 ms

% 多项式乘法

sz = [64, 1];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
f = @() conv(X, Y); timeit(f)
% 3.0 ms

sz = [128, 1];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
f = @() conv(X, Y); timeit(f)
% 11.0 ms

sz = [1024, 1];
X = gf(randi(255, sz), 8);
Y = gf(randi(255, sz), 8);
f = @() conv(X, Y); timeit(f)
% 720.3 ms
