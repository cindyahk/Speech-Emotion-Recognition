function [avgF0] = getpitch(y, fs)
% get the number of samples
ns = length(y);
% error checking on the signal level, remove the DC bias
mu = mean(y);
y = y - mu;

% use a 20msec segment, choose a segment every 10msec Frame Length: 20ms, Frame Shift: 10ms
fRate = floor(20*fs/1000);
updRate = floor(10*fs/1000);

nFrames=fix((length(y)-fRate+updRate)/updRate);

% the pitch contour is then a 1 x nFrames vector 1*nFrames
f0 = zeros(1, nFrames);
f01 = zeros(1, nFrames);

% get the pitch from each segmented frame 
k = 1;
avgF0 = 0;
m = 1;
for i=1:nFrames
    xseg = y(k:k+fRate-1);
    f01(i) = pitchacorr(fRate, fs, xseg);
    
    % do some median filtering, less affected by noise 
    if i>2 & nFrames>3
        z = f01(i-2:i);
        md = median(z);
        f0(i-2) = md;
        if md > 0
            avgF0 = avgF0 + md;
            m = m + 1;
        end
    elseif nFrames<=3
        f0(i) = a;
        avgF0 = avgF0 + a;
        m = m + 1;
end
    k = k + updRate;
end

t = 1:nFrames;
t = 20 * t;
if m==1
avgF0 = 0;
else
avgF0 = avgF0/(m-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pitch estimation using the autocorrelation method
% 
% 
% Input
% len:   Frame Length
% fs:    Sampling Frequency
% xseg:  Speech Signal in each frame
% 
% Output
% f0:    Base Frequency in each frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f0] = pitchacorr(len, fs, xseg)

[bf0, af0] = butter(4, 900/(fs/2));
xseg = filter(bf0, af0, xseg);

% find the clipping level, CL clipping level, CL
i13 = floor(len/3);
maxi1 = max(abs(xseg(1:i13)));
i23 = floor(2 * (len/3)) ;
maxi2 = max(abs(xseg(i23:len)));
if maxi1>maxi2
    CL=0.68*maxi2;
else
    CL= 0.68*maxi1;
end

% Center clip waveform, and compute the autocorrelation ????
clip = zeros(len,1);
ind1 = find(xseg>=CL);
clip(ind1) = xseg(ind1) - CL;
ind2 = find(xseg <= -CL);
clip(ind2) = xseg(ind2)+CL;
engy = norm(clip,2)^2;
 
clip1=zeros(len,1);
ind3=find(xseg>CL);
clip1(ind3)=1;
ind4=find(xseg<-CL);
clip1(ind4)=-1;
engy1=norm(clip1,2)^2;

[RR,lags] = xcorr(clip,clip1);
m = len;

% Find the max autocorrelation in the range 60 <= f <= 500 Hz
LF = floor(fs/500);
HF = floor(fs/60);
Rxx = abs(RR(m+LF:m+HF));
[rmax, imax] = max(Rxx);
imax = imax + LF;
f0 = fs/imax;

% Check max RR against V/UV threshold ????/?????????RR
silence = 0.4*engy;
if (rmax > silence) & (f0 > 60) & (f0 <= 500)
    f0 = fs/imax;
else % -- its unvoiced segment ??? ---------
    f0 = 0;
end

