function [ R ] = rehaze( I, haze_color,  haze_multiplier, window_size, haze_removal_percentage )
%REHAZE Modify the Color/Intensity of the Haze. For Fun.
%   
%   Params:
%   @haze_color: target haze color.
%   @haze_multiplier: haze intensity enhancement coefficient
%
%   created by: Zhou Chao
%   at: 2014.Nov.28

    % set default parameters
    if ~exist('haze_multiplier', 'var'), haze_multiplier = 1; end
    if ~exist('window_size','var'), window_size=5; end
    if ~exist('haze_removal_percentage','var'), haze_removal_percentage=0.95; end

    [h, w, ~] = size(I);

    % get the haze layer and scene radiance layer
    [J, transmission] = dehaze(I, window_size, haze_removal_percentage);
    scene = repmat(transmission, [1,1,3]) .* J;
    
    % manipulate the haze layer and merge
    atmosphere_light =  repmat(reshape(haze_color, [1,1,3]), [h, w, 1]);
    R = scene / haze_multiplier + ...
        atmosphere_light .* repmat((1 - transmission / haze_multiplier), [1,1,3]);

end

