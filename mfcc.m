function[maxMFCC2,minMFCC2,maxMFCC3,minMFCC3,maxMFCC4,minMFCC4,maxMFCC2D,minMFCC2D,maxMFCC3D,minMFCC3D,maxMFCC4D,minMFCC4D] = mfcc(x,fs)

nC=12; %number of Mel filters
nM=12; %dimension of MFCC,MFCC
nfft=256;
bank=melbankm(nC,nfft,fs,0,0.5,'m');

bank=full(bank);
bank=bank/max(bank(:));

% DCT??,a nM*nC matrix
for k=1:nM
  n=0:nC-1;
  dctcoef(k,:)=cos((2*n+1)*k*pi/(2*nC));
end

w = 1 + (nM/2) * sin(pi * [1:nM] ./ nM);
w = w/max(w);

xx=double(x);
xx=filter([1 -0.9375],1,xx);

W=hamming(nfft);
xx=enframe(xx,W,nfft/2);

for i=1:size(xx,1) 
  y = xx(i,:);
  s = y' ; %For matrices, the FFT operation is applied to each column,so we first find the transpose of each frame.
  t = abs(fft(s));
  t = t.^2;
  c1=dctcoef * log(bank * t(1:nfft/2+1));
  c2 = c1.*w'; 
  m(i,:)=c2';
end

%plot MFCC2, MFCC3, MFCC4
M=[m(:,2) m(:,3) m(:,4)];

dtm = zeros(size(m));
for i=3:size(m,1)-2
  dtm(i,:) = -2*m(i-2,:) - m(i-1,:) + m(i+1,:) + 2*m(i+2,:);
end
dtm = dtm / 3;
DTM=[dtm(:,2) dtm(:,3) dtm(:,4)];

ccc = [M DTM];

ccc = ccc(3:size(M,1)-2,:);

%?MFCC2, MFCC3, MFCC4 
maxccc=max(ccc);
maxMFCC2=maxccc(1);
maxMFCC3=maxccc(2);
maxMFCC4=maxccc(3);
maxMFCC2D=maxccc(4);
maxMFCC3D=maxccc(5);
maxMFCC4D=maxccc(6);

%?MFCC2, MFCC3, MFCC4 
minccc=min(ccc);
minMFCC2=minccc(1);
minMFCC3=minccc(2);
minMFCC4=minccc(3);
minMFCC2D=minccc(4);
minMFCC3D=minccc(5);
minMFCC4D=minccc(6);

