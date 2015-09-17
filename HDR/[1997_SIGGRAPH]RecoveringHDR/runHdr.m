inputDir = './input_img';
delta_t = [-4.72, -1.82, 1.51, 4.09];

imgList = dir(['./input_img/', '*.jpg']);
imgNum = length(imgList);

% read input image
imgCell = cell(imgNum, 1);
for i = 1 : imgNum
    imgCell{i} = imread(fullfile(inputDir, imgList(i).name));
end

[h, w, channels] = size(imgCell{1});
g = cell(channels, 1);
lE = cell(channels, 1);

% define weights
weight = zeros(256, 1);
weight(1:129) = 0:128;
weight(130:256) = 126:-1:0;

lambda = 500;

for i = 1 : channels
    fprintf('processing channel %d...\n', i);
    singleChannelImages = zeros(h, w, imgNum);
    for j = 1 : imgNum
        singleChannelImages(:,:,j) = imgCell{j}(:,:,i);
    end
    
    fprintf('sampling data from images...');
    Z = sampling(singleChannelImages);
    fprintf('done.\n');
    
    fprintf('solving linear equations...');
    [g{i}, lE{i}] = gsolve(Z, delta_t, lambda, weight);
    fprintf('done.\n');
end

fprintf('recovering radiance map...');
radiance = recoverRadiance(imgCell, delta_t, g, weight);
fprintf('done.\n..');