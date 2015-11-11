function [waves,fs,num] = readwave(wavpathname, funcpathname)

cd(wavpathname);

files=dir('*.wav');

num = size(files,1);

 for i=1:num
   [Y,fs]=wavread(files(i).name);
   waves(i).x=Y;
 end

 cd(funcpathname);
