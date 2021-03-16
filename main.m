%% Main file for image preprocessing Project SYS800

clc;
clear variables;

% Load data
data = readtable('data.csv');
% data = datastore('data.csv');
% data = tall(data);
%%
% Create list of img ids
ids = data.('ImgID'); % use {} to access strings

%% Constants
new_z_dim = 128;
new_size = [512 512 new_z_dim];
% Blurring window size and Padding value
win_blur = 5;
pad = 'replicate';
sigma = 0.5;
i = 1;
%% Cycle through each image and apply preprocessing

for i = 1:length(ids)
     tic
    % Load image
    name = ids{i};
    name = strcat('images/', name, '.TIF');
    try
        img = Tiff(name);
    catch ME
        display ('Error opening' + name + 'image');
        continue;
    end
    
    % Create imag array
    img = create_3d_image(img);
    
    %% Step 1: resize image
    % Resize to 512x512x128x3
    % Red
    tic
    resized_img(:,:,:,1) = imresize3(img(:,:,:,1), [512 512 128], 'linear');
    %Green
    resized_img(:,:,:,2) = imresize3(img(:,:,:,2), [512 512 128], 'linear');
    %Blue
    resized_img(:,:,:,3) = imresize3(img(:,:,:,3), [512 512 128], 'linear');
   
    % Blue layer is empty. Can be ignore from now on.
    
    %% Step 2: Apply blurring kernel
    % use function imgaussfilt3 included in Matlab
    % Send array to GPU
    gpuArray(resized_img);
    
    Blurred_img(:,:,:,1) = imgaussfilt3(resized_img(:,:,:,1), sigma, ...
        'Padding', pad, 'FilterSize', win_blur);
    Blurred_img(:,:,:,2) = imgaussfilt3(resized_img(:,:,:,2), sigma,...
        'Padding', pad, 'FilterSize', win_blur);
    Blurred_img(:,:,:,3) = resized_img(:,:,:,3);
    
    % Retreive image from GPU
    % gather(Blurred_img);    
    
    %% Step 3: Normalization of the image
    
    % We are going to use Otsu's thresholding using graythresh()
    [thresh_R, eff_R] = graythresh(Blurred_img(:,:,:,1));
    [thresh_G, eff_G] = graythresh(Blurred_img(:,:,:,2));
    
    % Binarize images to create mask
    mask_R = imbinarize(Blurred_img(:,:,:,1), thresh_R);
    mask_G = imbinarize(Blurred_img(:,:,:,2), thresh_G);
    
    %% Step 4: Fill in holes
    mask_R = imfill(mask_R,6, 'holes');
    mask_G = imfill(mask_G,6, 'holes');
    
    %% Step 5: Remove objects on border
    margin = 10; % Represents roughly 10% of image
    croppedImg_R = imcrop3(mask_R, [margin margin margin...
        new_size(1)-1-2*margin...
        new_size(2)-1-2*margin...
        new_size(3)-1-2*margin]);
    croppedImg_G = imcrop3(mask_G, [margin margin margin...
        new_size(1)-1-2*margin...
        new_size(2)-1-2*margin...
        new_size(3)-1-2*margin]);
    
    mask_R = imclearborder(croppedImg_R);
    mask_G = imclearborder(croppedImg_G);
    mask_R = logical(padarray(mask_R, [margin margin margin], 'both'));
    mask_G = logical(padarray(mask_G, [margin margin margin], 'both'));
    
    %% Step 6: Apply labels to number connected regions
    [L_R, n_R] = bwlabeln(mask_R, 6);
    [L_G, n_G] = bwlabeln(mask_G, 6);% Creates many labels
%     display(n_R)
%     display(n_G)
    
    %% Step 7: Apply mask over original image
    new_img(:,:,:,1) = resized_img(:,:,:,1) .* uint8(mask_R);
    new_img(:,:,:,2) = resized_img(:,:,:,2) .* uint8(mask_G);
    new_img(:,:,:,3) = resized_img(:,:,:,3);
    
    %% Clear unnecessary variables
    clear Blurred_img resized_img croppedImg_G croppedImg_R...
        L_G L_R mask_G mask_R;
    toc
    %% Step 8: Linearize image
    tic
    vector_image = [];
    vector_image = tall(vector_image)
    vector_image = reshape(new_img, 1, []);
    
    toc
end
%%
