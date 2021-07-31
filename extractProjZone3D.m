function [database] = extractProjZone(img,shape_image,shape_zones )
% Feature extraction using ZONE projection method
% Inputs are:
%       img         : Image 
%       shape_image : Shape of images as vector
%       shape_zones : Shape of zones as vector
%
% Ouputs:
%       database: Image caracteristics vector

%%
% First: Need to reshape image to specified dimensions
%img = round(imresize3(img, shape_image, 'linear'));
% Uncomment below to visualize img
% colormap( gray );
% imagesc( img );
%%
% Get empty Zone array (to hole compressed image)
img_zoned = get_zone_array(shape_image, shape_zones);

%%
% Process each zone in the image

% Split image into sub arrays
img_split = mat2cell(img, repelem(shape_zones(1), size(img_zoned,1)), ...
        repelem(shape_zones(2), size(img_zoned,2)), ...
        repelem(shape_zones(3), size(img_zoned,3)));

for z = 1:size(img_split,3)
    for i = 1:size(img_split,1)
        for j = 1:size(img_split,2)
            h = sum(img_split{i,j,z}, 'all');
            h = uint16(h);
            img_zoned(i,j,z) = mean(h, 'all');
        end
    end
end

% Uncomment below to visualize img_zoned
% colormap( gray );
% imagesc( img_zoned );
%%
% Vectorize img_zoned
database = reshape(img_zoned,1, []);

% Append means of rows and columns
% m_rows = uint16(round(mean(img_zoned,[])));
% m_rows = reshape(m_rows,1,[]);
% m_cols = uint16(round(mean(img_zoned)));
% m_cols = reshape(m_cols,1,[]);
% m_z = uint16(round(mean(img_zoned, [1 2])));
% m_z = reshape(m_z,1,[]);

% database = [database m_rows m_cols m_z];

end