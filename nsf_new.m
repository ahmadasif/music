function [nsfMean, nsfVar] = nsf_new(timeSeries)
%[nsfMean, nsfVar] = nsf_new(timeSeries)
% Version 4.1 (SR)
% This function produces a measure of non-spectral flatness. Input is
% a vector of time series data. Output is nsf measure and uncertainty - variance.

MIN_LENGTH = 64; %minimum length for the psd estimator

% standardize data
stdTimeSeries = (timeSeries-mean(timeSeries))/std(timeSeries); %normalised affine xform

%nfft = 64;
nfft = ceil(2*length(timeSeries)^(1/3)); % use the Rice rule for number of histo bins

if (length(stdTimeSeries) < MIN_LENGTH)
  stdTimeSeries = [stdTimeSeries ; stdTimeSeries];
end;

Fs = 1; %arbitrary samp freq
S = psd(spectrum.welch,stdTimeSeries,'Fs',Fs,'NFFT',nfft,'ConfLevel',0.841,'SpectrumType','Onesided'); %0.841 is the 1sd quantile

%Nfft = 512;
% [P,F,Pul] = pwelch(stdTimeSeries,[],[],Nfft,Fs,'ConfidenceLevel',0.841);
% S.data=P;
% S.ConfInterval = Pul;
 

P = S.data;
lowP = S.ConfInterval(:,1);
uppP = S.ConfInterval(:,2);
sP = sum(P);
P = P/sP;
lowP = lowP/sP;
uppP = uppP/sP;
deltaP = abs(uppP-lowP)/2;

H = -sum(P .* log(P+eps));
%deltaH = -sum( (log(P+eps)+1) .* deltaP);
deltaH = sqrt(sum( ((log(P+eps)+1) .* deltaP).^2));

HN = log(nfft);

%nsfMean = HN - H;
%nsfVar = deltaH.^2;
nsfMean = H/HN;
deltaH = deltaH/HN;
nsfVar = deltaH.^2;
