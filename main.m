%% Main file for image preprocessing Project SYS800

clc;
clear variables;

% Load data
data = readtable('data.csv');
%%
% Create list of img ids
ids = data.('ImgID'); % use {} to access strings

%% Constants
new_z_dim = 128;
% Blurring window size and Padding value
win_blur = 5;
pad = 'replicate';
sigma = 0.5;
i = 1;
%% Cycle through each image and apply preprocessing

% for i = 1:length(ids)
    tic
    % Load image
    name = ids{i};
    name = strcat('images/', name, '.TIF');
    try
        img = Tiff(name);
    catch ME
        display ('Error opening' + name + 'image');
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
    
    %% Step 5: Apply labels to number connected regions
    [L_R, n_R] = bwlabeln(mask_R, 6);
    [L_G, n_G] = bwlabeln(mask_G, 6);% Creates many labels
    display(n_R)
    display(n_G)
    
    %% Step 6: Need to cluster these regions
    
    toc
% end
%%
new_img(:,:,:,1) = resized_img(:,:,:,1) .* uint8(mask_R);
new_img(:,:,:,2) = resized_img(:,:,:,2) .* uint8(mask_G);
new_img(:,:,:,3) = resized_img(:,:,:,3);