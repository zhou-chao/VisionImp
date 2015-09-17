function sampledData = sampling(singleChannelImages)
%sampling: sampling data with intensities normal distributed and low
%   standard deviation.
%
% created by: zhou chao
% at: 2015.01.08
%
    imgNum = size(singleChannelImages, 3);
    merged = sum(singleChannelImages, 3);

    % calculate standard deviation
    std_dev = stdfilt(merged);

    % sweep out pixels with large standard deviation
    mask = ones(size(merged));
    mask(std_dev > max(std_dev(:)) * 0.1) = 0;
    merged = int32(merged .* mask);

    dataLength = max(merged(:)) - min(merged(:));

    % decide sampling numbers by gaussian curve
    sampleNum = gaussmf(double(1:dataLength),[double(dataLength/3) double(dataLength/2)]);
    sampleNum = int32(floor(sampleNum * 3));
    sampledData = zeros(sum(sampleNum), imgNum);

    pointer = 1;
    for i = 1 : dataLength
        [x, y] = ind2sub(size(merged),find(merged == i));

        if isempty(x), continue; end

        % random sampling
        index = randi([1, length(x)], [sampleNum(i), 1]);
        for k = 1 : sampleNum(i)
            sampledData(pointer, :) = singleChannelImages(x(index(k)), y(index(k)), :);
            pointer = pointer + 1;
        end
    end

    sampledData = sampledData(1:pointer - 1,:);
end


