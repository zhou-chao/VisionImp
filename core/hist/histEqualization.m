function output_img = histEqualization(input_img, alpha)
%histEqualization, only for single channel images
%
% created by: zhou chao
% at: 2015.01.27

if ~exist('alpha', 'var'), alpha = 1; end

[h, w, ~] = size(input_img);
input_hist = imhist(input_img);
input_chist = zeros(length(input_hist), 1);

% compute cumulative histogram
for i = 1 : 256
    if i ~= 1
        input_chist(i) = input_chist(i - 1) + input_hist(i);
    else
        input_chist(i) = input_hist(i);
    end
end

output_img = uint8(input_chist(input_img + 1) / (h * w) * 255 * alpha + ...
            double(input_img) * (1 - alpha));
end