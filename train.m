function [FMtrain]=train()
%Read wav file
funcpathname = 'D:\emotion recogntion0';
disp('Reading files for joy');
[joy,fs,num1] = readwave('D:\emotion recogntion0\joy\malefemale', funcpathname);
disp('Reading files for angry');
[angry,fs,num2] = readwave('D:\emotion recogntion0\angry\malefemale', funcpathname);
disp('Reading files for grief');
[grief,fs,num3] = readwave('D:\emotion recogntion0\grief\malefemale', funcpathname);

FMtrain = zeros(3, 19);

disp('Features for joy');
FMtrain(1,:) = extractionavg(joy,fs,num1);

disp('Features for angry');
FMtrain(2,:) = extractionavg(angry,fs,num2);

disp('Features for grief');
FMtrain(3,:) = extractionavg(grief,fs,num3);

% Store the emotion vectors in ‘FMtrain.txt’
dlmwrite('FMtrain.txt', FMtrain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input
% waves: frame
% fs:    Sampling Frequency
% num:   Speech Signal in each Frame
% 
% Output
% features: Average value for each emotion in all the sentences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function features = extractionavg(waves, fs, num)

features = zeros(num, 19);
for i=1:num
features(i, :) = extraction(waves(i).x, fs);
end
features = mean(features);

