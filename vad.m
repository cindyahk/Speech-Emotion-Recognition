function [speech, avgzcr, avgamp, maxamp , minamp] = vad(x,fs,W,FrameInc)

%Pre-emphasis, Hamming, Framing
y = filter([1 -0.9375], 1, x);
z = enframe(y, W, FrameInc);
maxsilence = 8;  % 8*10ms  = 80ms
minlen  = 15;    % 15*10ms = 150ms
status  = 0;
count   = 0;
silence = 0;
silentrate = 0;
%Calculate ZCR
tmp1  = enframe(x(1:end-1), W, FrameInc);
tmp2  = enframe(x(2:end)  , W, FrameInc);
signs = (tmp1.*tmp2)<0;
diffs = (tmp1 -tmp2)>0.02;
zcr   = sum(signs.*diffs, 2);
%Calculate ZCR Limits
zc = mean(zcr);
fzc = std(zcr);
ZT = min(15,zc+2*fzc);
ZTU=max(ZT,ZT*3);
ZTL=min(ZT,ZT*5);
%Calculate Short-Time Energy
amp = sum(abs(z), 2);
%Adjust Short-Time Energy Limits
EMAX = max(amp);

EMIN = min(amp);
amp1 = (0.03 * (EMAX - EMIN)) + EMIN;
amp2 = 4 * EMIN;
EL = min(amp1,amp2);
EU = 5 * EL;

%End-point detection started
x1 = 0; 
x2 = 0;
for n=1:length(zcr)
   switch status
   case {0,1}                  
      if amp(n) > EU   | ...        
         zcr(n) >ZTU
         x1 = max(n-count-1,1);
         status  = 2;
         silence = 0;
         count   = count + 1;
      elseif amp(n) > EL | ... 
             zcr(n) > ZTL
         status = 1;
         count  = count + 1;
      else                      
         status  = 0;
         count   = 0;
      end
   case 2,                      
      if amp(n) > EL | ...    
         zcr(n) > ZTL
         count = count + 1;
      else                       
         silence = silence+1;
         if silence < maxsilence
            count  = count + 1;
         elseif count < minlen   
            status  = 0;

                        silence = 0;
            count   = 0;
         else                    
            status  = 3;
         end
      end
   case 3,
      break;
   end
end   

count =floor(count-silence/2);
x2 = x1 + count -1;

%Retrive Voiced Part
speech = x(x1*FrameInc : x2*FrameInc);
y1 = filter([1 -0.9375], 1, speech);
z1 = enframe(y1, W, FrameInc);
%Calculate ZCR
tmp3  = enframe(speech(1:end-1), W, FrameInc);
tmp4  = enframe(speech(2:end)  , W, FrameInc);
signs1 = (tmp3.*tmp4)<0;
diffs1 = (tmp3 -tmp4)>0.02;
zcr1   = sum(signs1.*diffs1, 2);
avgzcr = mean(zcr1);

ampsquare = sum(z1.*z1, 2);
avgamp = mean(ampsquare);
maxamp=max(ampsquare);
minamp=min(ampsquare);

