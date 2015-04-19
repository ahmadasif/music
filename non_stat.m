function [pa,pb] = non_stat(x);

N = 100;
T = 100;

x = normalis(x,x);

P = randperm(length(x)-T);

glob_median = median(x);

for n=1:N
    y = x(P(n):P(n)+T);
    b1 = (y > glob_median);
    b2 = (y < glob_median);
    b1 = b1 & shift(b1,-1) & shift(b1,1);
    b2 = b2 & shift(b2,-1) & shift(b2,1);
    pa(n) = mean(b1);
    pb(n) = mean(b2);
end;

