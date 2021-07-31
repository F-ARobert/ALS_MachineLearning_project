function emtpy_zone_array = get_zone_array(shape_image, shape_zones)
% Function returns empty array representing the image diced into zones of
% specified shape
%
% Inputs:
%       shape_image: Shape of original image
%       shape_zones : Shape of eahc individual zones
%
% Output:
%       empty_zone_array: Array representing the original image diced into
%       zones of specified size

% Get dimensions
z_dim = uint16(shape_image)./uint16(shape_zones);
emtpy_zone_array = zeros(z_dim,'uint16');
assert(size(emtpy_zone_array, 1) == z_dim(1));
assert(size(emtpy_zone_array, 2) == z_dim(2));
end
