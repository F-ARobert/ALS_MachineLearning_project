%% Main file for image preprocessing Project SYS800

clc;
clear;

% Load data
data = readtable('data.csv');
%%
% Create list of img ids
ids = data.('ImgID'); % use {} to access strings
%extra_ids = {};
%%
% Test open each image to find descrepancies
% for i = 1:length(ids)
%     name = ids{i};
%     name = strcat('images/', name, '.TIF');
%     try
%         img = Tiff(name);
%     catch ME
%         extra_ids{end+1} = ids{i};
%     end
% end
% save extra_data_in_csv.mat extra_ids;

%%
% Find max z size
% z_dims = zeros(1,length(ids));
% 
% for i = 1:length(ids)
%     name = ids{i};
%     name = strcat('images/', name, '.TIF');
%     
%     try
%         img = Tiff(name);
%     catch ME
%         extra_ids{end+1} = ids{i};
%     end
%     
%     img = create_3d_image(img);
%     z_dims(i) = size(img,3);
%     
% end
%% Resize Image
% Resize all images to max z found
load mean_z_dims.mat
max_z = max(z_dims);

% Load image
name = ids{1};
name = strcat('images/', name, '.TIF');
img = Tiff(name);

img = create_3d_image(img);
% Resize to 512x512x128x3
new_img(:,:,:,1) = imresize3(img(:,:,:,1), [512 512 128], 'linear');
new_img(:,:,:,2) = imresize3(img(:,:,:,2), [512 512 128], 'linear');
new_img(:,:,:,3) = imresize3(img(:,:,:,3), [512 512 128], 'linear');
