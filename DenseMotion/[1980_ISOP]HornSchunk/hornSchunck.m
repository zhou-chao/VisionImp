function flow = hornSchunck(imRef, imTar, alpha, maxIter, factor)
%hornSchunck, an optical flow algorithm implementation based on
% [1] Horn, Berthold K., and Brian G. Schunck. "Determining optical flow." 
% 
% args:
%   @imRef, @imTar: the input images
%   @alpha: smooth term weight
%   @maxIter: max iteration for the gauss-seidel solver
%   @factor: the downsampling factor between levels in gaussian pyramid
%
% created by: zhou chao
% at: 2015.02.04 
%
    addpath(genpath('../../core/'));
   
    if ~exist('alpha', 'var'), alpha = 0.1; end
    if ~exist('maxIter', 'var'), maxIter = 50; end
    if ~exist('factor', 'var'), factor = 1.25; end
    
    % get gray scale input images
    if size(imRef, 3) == 3
        grayRef = rgb2gray(im2double(imRef));
        grayTar = rgb2gray(im2double(imTar));
    else
        grayRef = imRef;
        grayTar = imTar;
    end
    
    % build gaussian pyramid
    refPyr = flip(gaussPyramid(grayRef, factor));
    tarPyr = flip(gaussPyramid(grayTar, factor));

    gradient_kernel = [-1 1; -1 1] / 4;

    for i = 1 : length(refPyr)
        % gradients
        Ex = imfilter(refPyr{i}, gradient_kernel) + imfilter(tarPyr{i}, gradient_kernel);
        Ey = imfilter(refPyr{i}, gradient_kernel') + imfilter(tarPyr{i}, gradient_kernel');

        % intensity change
        Et = tarPyr{i} - refPyr{i};

        % flow from previous level
        [h, w, ~]  = size(refPyr{i});
        if i == 1
            flow = zeros(h, w, 2);
        else
            flow = imresize(flow, [h, w]) * factor;
        end

        for j = 1 : maxIter
            avg_flow = imfilter(flow, [1 2 1; 2 0 2; 1 2 1] / 12);

            tmp = (Ex.* avg_flow(:,:,1) + Ey .* avg_flow(:,:,2) + Et) ./ ...
                (alpha^2  + Ex .^ 2 + Ey .^ 2);

            flow(:,:,1) = avg_flow(:,:,1) - Ex .* tmp;
            flow(:,:,2) = avg_flow(:,:,2) - Ey .* tmp;
        end
    end
end
