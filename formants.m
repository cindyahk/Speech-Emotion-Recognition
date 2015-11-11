function [F1,F2] = formants(y,fs,W,FrameInc)
frame = enframe(filter([1 -0.9375], 1, y), W, FrameInc);

frame1=frame';

[len,nframes]=size(frame1);

ncoeff=round(2+fs/1000);
A1=zeros(nframes,ncoeff+1);
for i=1:nframes
    A=lpc(frame1(:,i),ncoeff);
    A1(i,:)=A(1:end);
end

F=zeros(nframes,5);
for i=1:nframes

    r=roots(A1(i,:));

    r=r(imag(r)>0.01);       

    ffreq=sort(atan2(imag(r),real(r))*fs/(2*pi));  
    ffreq=ffreq'; 
    

    for j=1:length(ffreq)
        F(i,j)=ffreq(j);
    end 
end

formant = mean(F);

F1 = formant(1);
F2 = formant(2);

