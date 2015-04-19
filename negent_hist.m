function [ne, neVar] = negent_hist(y);
%[ne, neVar] = negent_hist(y);
% Version 2.1 (SR)
% This function produces a measure of entropy. Input is
% a vector of time series data. Output is entropy measure and uncertainty -
% variance in H

%Nbins = 50;  %number of bins for pdf estimation
Nbins = ceil(2*length(y)^(1/3)); % use the Rice rule for number of histo bins

[p,a] = pdf(y,Nbins);
p=p/sum(p);
H = -sum(p .* log(p+eps));
H = H / log(Nbins); %as a fraction of the maximum entropy possible

ne = H;

% now compute the variance of the H measure using chained delta rule
N0 = length(y);
alpha_i = p*N0;
deltaP = sqrt( (alpha_i .* (N0-alpha_i)) ./ (N0^2 * (N0 + 1)) );
%deltaH = -sum( (log(p+eps)+1) .* deltaP);
deltaH = sqrt(sum( ( (log(p+eps)+1) .* deltaP).^2 ));
deltaH = deltaH / log(Nbins);
neVar = deltaH.^2;


%%%%%%%%%%%%%%%%%%%%
%[p,a] = pdf(x,N);
%
%estimates the pdf of x using N rectangular bins
%
function [p,a] = pdf(x,N);

[h,a] = hist(x,N);

dx = (max(x)-min(x))/N;
p = (h/sum(h))/(dx+eps);
