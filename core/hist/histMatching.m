function output_img = histMatching(input_img, model_img, alpha)
%histMatching, only for single channel images
%
% created by: zhou chao
% at: 2015.01.28

if ~exist('alpha', 'var'), alpha = 1; end

[ih, iw, ~] = size(input_img);
[mh, mw, ~] = size(model_img);

input_hist = imhist(input_img);
input_chist = zeros(length(input_hist), 1);

model_hist = imhist(model_img);
model_chist = zeros(length(model_hist), 1);

% compute cumulative histograms
for i = 1 : 256
    if i ~= 1
        input_chist(i) = input_chist(i - 1) + input_hist(i);
        model_chist(i) = model_chist(i - 1) + model_hist(i);
    else
        input_chist(i) = input_hist(i);
        model_chist(i) = model_hist(i);
    end
end

% normalize cumulative histograms
input_chist = input_chist / (ih * iw) * 255;
model_chist = model_chist / (mh * mw) * 255;

% build lookup table
lookup_table = zeros(256, 1);
for i = 1 : 256
    % find nearest bin
    [~,I] = min(abs(model_chist-input_chist(i)));
    lookup_table(i) = I(1);
end

output_img = uint8(lookup_table(input_img + 1)) * alpha + ...
	(1 - alpha) * input_img;
end
