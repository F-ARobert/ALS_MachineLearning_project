%% Main file for image preprocessing Project SYS800

clc;
clear;

% Load data
data = readtable('data.csv');
%%
% Create list of img ids
ids = data.('ImgID'); % use {} to access strings
extra_ids = {};
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
z_dims = zeros(1,length(ids));

for i = 1:length(ids)
    name = ids{i};
    name = strcat('images/', name, '.TIF');
    
    try
        img = Tiff(name);
    catch ME
        extra_ids{end+1} = ids{i};
    end
    
    img = create_3d_image(img);
    z_dims(i) = size(img,3);
    
end