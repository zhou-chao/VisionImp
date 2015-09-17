function flow = lucasKanade(imRef, imTar, maxIter)
%lucasKanade, an optical flow algorithm implementation based on
% [1] Lucas, Bruce D., and Takeo Kanade. "An iterative image registration
%     technique with an application to stereo vision."
% [2] Bouguet, Jean-Yves. "Pyramidal implementation of the affine lucas 
%     kanade feature tracker description of the algorithm."
%
% args:
%   @imRef, @imTar: the input images
%   @maxIter: max iteration for the gauss-seidel solver
%
% created by: zhou chao
% at: 2015.02.05
%
    addpath(genpath('../../core/'));

    if ~exist('maxIter', 'var'), maxIter = 5; end
    win_size = 7;

    % get gray scale input images
    if size(imRef, 3) == 3
        I = rgb2gray(im2double(imRef));
        J = rgb2gray(im2double(imTar));
    else
        I = imRef;
        J = imTar;
    end
    
    [h, w, ~]  = size(I);
    
    gradient_kernel = [-1 0 1]/2;
    
    % compute first order gradient
    Ix = imfilter(I, gradient_kernel) ;
    Iy = imfilter(I, gradient_kernel') ;

    % squared gradient
    Ixx = Ix .^ 2;
    Ixy = Ix .* Iy;
    Iyy = Iy .^ 2;

    % summation over local window
    sum_Ixx = imfilter(Ixx, ones(win_size));
    sum_Ixy = imfilter(Ixy, ones(win_size));
    sum_Iyy = imfilter(Iyy, ones(win_size));

    flow = zeros(h, w, 2);

    for j = 1 : maxIter
        residual = I - imwarp_sxy(J, flow) ;
        b_x = imfilter(residual .* Ix, ones(win_size));
        b_y = imfilter(residual .* Iy, ones(win_size));

        flow_tmp = zeros(h, w, 2);
        
        % compute motion for each pixel
        for row = 1 : h
            for col = 1 : w
                flow_tmp(row, col, :) = pinv([sum_Ixx(row, col) sum_Ixy(row, col); ...
                    sum_Ixy(row, col) sum_Iyy(row, col)]) * [b_x(row, col) b_y(row, col)]';
            end
        end

        %  flow_tmp(abs(flow_tmp) > 1) = 0;
        flow = flow + flow_tmp;
    end
end
