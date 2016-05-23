function [awt,time,freq] = BAWT2(sig,fmin,fmax,fs,nvoice,dw)
% 
% nvoice: nombre de cycle
% dw: précision de la frequence
% initialisation

n       = length(sig);
time    = (1:n)*1000/fs;
freq    = (fmin:dw:fmax); % We can do here Spline filter
Nfreq   = length(freq);
sigmaf  = freq/nvoice;
df      = fs/n;
fftx    = fft(sig(:));

% difinition of Gabor Wavelet
Psi     = zeros(n,Nfreq);
awt     = zeros(n,Nfreq);

for ifreq=1:Nfreq
    for i=1:(n/2)
        freqwave     = ((i-1)*df - freq(ifreq)) ./ sigmaf(ifreq);
        Psi(i,ifreq) = realpow(4.*pi,1/4)*exp(-(freqwave .* freqwave)/2);
    end
    awt(1:n,ifreq)  = sqrt(n)*ifft(fftx .* Psi(1:n,ifreq));% Or We can do here Spline filter
end;





