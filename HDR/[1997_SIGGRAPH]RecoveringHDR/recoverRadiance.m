function radiance = recoverRadiance(imgCell,delta_t, g, weight)
%recoverRadiance: recover radiance map from known log exposure
%   
% Arguments:
%   imgCell{i}: i'th image of the image list
%   delta_t{i}: log exposure time of the i'th image
%   g{i}:       log exposure of the i'th image
%   weight(Z):  weight of pixel value Z
% Returns:
%   radiance:   the recovered radiance map
%
% created by: zhou chao
% at: 2015.01.08
%
    numer = 0;
    denom = 0;
    lE = zeros(size(imgCell{1}));

    for i = 1 : size(imgCell{1}, 3)
        for j = 1 : size(imgCell, 1)
            numer = numer + weight(imgCell{j}(:,:,i) + 1) .* (g{i}(imgCell{j}(:,:,i) + 1) - delta_t(j));
            denom = denom + weight(imgCell{j}(:,:,i) + 1);
        end
        lE(:,:,i) = numer./denom;
    end
    
    radiance = exp(lE);
end