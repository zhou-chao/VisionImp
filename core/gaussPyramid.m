function pyr = gaussPyramid(input_img, scale_factor, min_size)
%gaussPyramid: create a gaussian pyramid for a given image
%
% input arguments:
%   @input_img: the target image
%   @scale_factor: the scaling factor between neighbouring levels
%       (default: 2)
%   @min_size: image size of the highest level 
%       (default: 24) 
%
% output arguments:
%   @pyr: the output pyramid
%
% created by: zhou chao
% at: 2015.01.20
%
    if ~exist('scale_factor', 'var'), scale_factor = 2; end
    if ~exist('min_size', 'var'), min_size = 24; end

    [h, w, ~] = size(input_img);

    % compute the pyramid level
    rough_level = log(min(h, w) / min_size) / log(scale_factor);
    pyr_level = ceil(rough_level) + (mod(rough_level, 1) == 0);


    pyr = cell(pyr_level, 1);
    pyr{1} = input_img;

    for i = 2 : pyr_level
       pyr{i} = imresize(pyr{i - 1}, 1 / scale_factor); 
    end
end
