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
% Tests for right shape
assert(isa(z_dim(1),'uint16'), 'z_dim(1) is not an unsigned integer');
assert(isa(z_dim(2),'uint16'), 'z_dim(2) is not an unsigned integer');
assert(isa(z_dim(3),'uint16'), 'z_dim(3) is not an unsigned integer');

emtpy_zone_array = zeros(z_dim,'uint16');
end
