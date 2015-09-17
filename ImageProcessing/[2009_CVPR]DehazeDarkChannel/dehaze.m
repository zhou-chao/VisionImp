function [J, Depth] = dehaze(I, window_size, haze_removal_percentage)
%DEHAZE - Single Image Haze Removal using Dark Channel Prior, CVPR 2009
%   J = dehaze(I, window_size, haze_removal_percentage) removes haze for
%   image I.
%   
%   Paras: 
%   @I: Input DOUBLE image, should be a 3-channel color image.
%   @window_size: Window size to balance haze removal of detailed
%          structures and tolerance of high intensity local patches size,
%          5 by default.
%   @haze_removal_percentage: The percentage of haze to be removed, 0.95 
%          by default.
%
%   Example
%   ==========
%   I  = imread('img/forest.jpg');
%   J  = dehaze(im2double(I)); 
%   figure, imshow(I), figure, imshow(J);
%
%   ==========
%   The Code is created based on the method described in the following paper 
%   [1] Single Image Haze Removal using Dark Channel Prior, by Kaiming He, Jian Sun, and Xiaoou Tang, in CVPR 2009.
%   The code and the algorithm are for non-comercial use only.
%  
%   created by: Zhou Chao
%   at  : 2014.Nov.27
%   version: 1.0

    % constant parameters
    if ~exist('window_size','var'), window_size=5; end
    if ~exist('haze_removal_percentage','var'), haze_removal_percentage=0.95; end
    atmosphere_light_percentage = 0.001;
    transmission_threshold = 0.1;

    % get the dimension of the input image
    [h, w, ~] = size(I);

    % compute the dark channel of the input image
    D = compute_darkchannel(I,window_size);

    % find the intensity of atmosphere light:
    %   A = highest value of pixels in I with top 0.1% dark channel values 
    vect_d = reshape(D, [h * w, 1]);
    vect_d = sort(vect_d, 'descend');
    pivot = vect_d(int32(h * w * atmosphere_light_percentage));

    mask = ones(h, w);
    mask(D < pivot) = 0;
    mask = repmat(mask, [1,1,3]);

    candidate_A = max(I .* mask, [], 1);
    A = max(candidate_A, [], 2);

    % find the transmission map
    %   t = 1 - w * dark_channel_of(I ./ A)
    normalized_I = bsxfun(@rdivide, I, A);
    atmosphere_transmission = 1 - haze_removal_percentage * ...
        compute_darkchannel(normalized_I, window_size);

    % refine the transmission map
    atmosphere_transmission = joint_wls_filter(atmosphere_transmission, I, 0.7);
    
    
    % recover the scene radiance
    %   J = (I - A) ./ t + A
    atmosphere_transmission(atmosphere_transmission < transmission_threshold) ...
        = transmission_threshold;
    
    Depth = atmosphere_transmission;
    
    tmp = bsxfun(@rdivide, bsxfun(@minus, I, A), atmosphere_transmission);
    J = bsxfun(@plus, tmp, A);
end