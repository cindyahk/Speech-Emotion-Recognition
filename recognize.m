clear;clc;
funcpathname = 'D:\emotion recogntion0';
[waves,fs,num] = readwave('D:\emotion recogntion0\recognize\joy\female', funcpathname);

count = zeros(1,3);

for i = 1:num
    emotion = classifier(waves(i).x, fs);
    %joy, angry, grief 1,2,3
    switch emotion
        case 1,
            count(1) = count(1) + 1;
        case 2,
            count(2) = count(2) + 1;
        case 3,
            count(3) = count(3) + 1;
       
    end
end
disp('   ??JOY   ??ANGRY   ??GRIEF ');
disp(count);

