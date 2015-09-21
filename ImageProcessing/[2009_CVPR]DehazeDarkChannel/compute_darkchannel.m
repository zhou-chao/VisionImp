function [ D ] = compute_darkchannel( I, window_size )
%COMPUTE_DARKCHANNEL Compute the Dark Channel of the Input Image
%   I: input image
%   window_size: the local patch size 
%
%   created by: Zhou Chao
%   at: 2014.Nov.27

%     D = min(I,[],3);
%     D = ordfilt2(D, 1, ones(window_size));

    tmp = imerode(I, strel('square', window_size));
    D = min(tmp, [], 3);
end

