function imin = classifier(wave, fs)

class = load('FMtrainfemale.txt');

feature = extraction(wave, fs);

dist = zeros(1,3);
for i = 1:3
    dist(i) = disteusq(feature, class(i,:));
end

[distmin, imin] = min(dist);
