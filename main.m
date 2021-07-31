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
compress = [224 224];
rf_size = [64 64 64];
% Blurring window size and Padding value
win_blur = 5;
pad = 'replicate';
sigma = 0.1;

% Create table to hold BWlabel predictions for number of NMJ junctions
NMJ_pred = zeros(length(ids),1);
cnn_database = zeros(224, 224, 3, 1027);
%% Cycle through each image and apply preprocessing
for i = 1:length(ids)
     tic
     display(i)
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
    imshow(generateur_images(img, i));
    %% Step 1: resize image
    % Resize to 512x512x128x3
    tic
    % Red: For counting NMJ we are only keeping the red part
    resized_img(:,:,:) = imresize3(img(:,:,:,1), new_size, 'linear');
    imshow(generateur_images(resized_img, i));
    %% Step 2: Apply blurring kernel
    % use function imgaussfilt3 included in Matlab
    % Send array to GPU
    gpuArray(resized_img);
    
    Blurred_img(:,:,:) = imgaussfilt3(resized_img(:,:,:), sigma, ...
        'Padding', pad, 'FilterSize', win_blur);
    
    % Adjust contrasts to increase light display.
    imshow(generateur_images(Blurred_img, i));
    Blurred_img = imadjustn(Blurred_img,[0.15 0.3], []);
         
    %% Step 3: Thresholding and binarization of image
    % We are going to use Otsu's thresholding using imbinarize()
    
    mask_R = imbinarize(Blurred_img);
    imshow(generateur_images(mask_R, i));
    %% Step 4: Fill in holes
    mask_R = imfill(mask_R,26, 'holes');
    imshow(generateur_images(mask_R, i));
    %% Step 5: Remove objects on border
    % CROPPING IMAGE RESULTED IN LOSS DATA
    %mask_R = imclearborder(mask_R);
    %mask_G = imclearborder(croppedImg_G);   
    
    %% Step 6: eliminate small artefacts
    % eliminate small artefacts from image
    %mask_R = bwareaopen(mask_R, 3750,26);
    
    %% Step 7: Compress and de compress mask to enlarge region covered
    %mask_R = imresize3(mask_R, rf_size, 'linear');
    %mask_R = imresize3(mask_R, new_size, 'linear');
    
    %% Step 8: Apply labels to number connected regions
    %[L_R, n_R] = bwlabeln(mask_R, 26);
    %NMJ_pred(i) = n_R;
    
    
    %% Step 9: Apply Mask to original resized img
    new_img(:,:,:) = resized_img(:,:,:) .* uint8(mask_R);
    gather(new_img);
    imshow(generateur_images(new_img, i));
    %% Step 10: Compress to 2D image by extracting max value in each z-col
    compress_img = max(new_img(:,:,:),[], 3);
    
    % Prep images for CNN
    cnn_img = imresize(compress_img, compress);
    cnn_img(:,:,2:3) = zeros(224,224,2);
    cnn_database(:,:,:,i) = cnn_img;
    
    %compress_img(:,:,:) = imresize3(new_img(:,:,:), compress, 'linear');
    
    % Adjust contrasts to increase light display.
    %compress_img = imadjustn(compress_img,[0.05 0.15], [0 1]);
    

    %% Step 10: Reshape image into vector to create feature vector
    %features(i,:) = extractProjZone(compress_img, compress, [4 4]);
    %features(i,:) = reshape(compress_img, 1, []);
    toc
    clear Blurred_img resized_img croppedImg_G croppedImg_R...
        L_G L_R mask_G mask_R;
end
% Save CNN Data
save('trimmed_data_cnn_database.mat', 'cnn_database', '-v7.3');
%%
gather(features);
% Add NMJ_pred to data table and save data to csv
x = array2table(NMJ_pred);
y = [data x];
writetable(y,'NMJ_label_predictions.csv');

save('trimmed_data_features.mat', 'features', '-v7.3');
%% Step 11: Devide features into training and test sets
load features.mat
% Load data
data = readtable('data.csv');

% Add labels and IDs to feature set
num_ids = uint8([1:1027])';
Num_NMJ = uint8(data.('Number_of_NMJ'));
denervation = uint8([data.('Denervation_Complete')...
    data.('Denervation_Non')...
    data.('Denervation_Partielle')]);
feature_w_labels_IDs = [num_ids Num_NMJ denervation features];
%%
% Visualize data distribution
numbers = feature_w_labels_IDs(:,2);
h1 = histogram(numbers);
title("Number of samples per classes")
ylabel("Number of samples")
xlabel("Classes")
title("Distribution of samples among classes in the database")

%%
% Remove classes with too low count (those with only 50 items or more)
threshold = 3;

while max(feature_w_labels_IDs(:,2)) > threshold
for i = 1:size(feature_w_labels_IDs,1)
    
    if feature_w_labels_IDs(i,2) > threshold
        feature_w_labels_IDs(i,:) = [];
        break;
    end
end 
end
%%
% extract 20% of data as test dataset
cv = cvpartition(size(feature_w_labels_IDs,1),'HoldOut', 0.1);
idx = cv.test;

% Seperate data into training and data set

dataTrain = feature_w_labels_IDs(~idx,:);
dataTest = feature_w_labels_IDs(idx,:);
%% Save training and test data
save('trimmed_data_testData2D_224x224.mat', 'dataTest', '-v7.3');
save('trimmed_data_trainingData2D_224x224.mat', 'dataTrain', '-v7.3');

%% PCA
load trimmed_data_trainingData2D_224x224.mat
load trimmed_data_testData2D_224x224.mat

Threshold = 80;

training_features = double(dataTrain(:,6:end));
[V,G] = acp(training_features, Threshold);

plot(1:1500,G(1:1500),'red')
hold on
index = find(floor(G)==Threshold,1);
plot(index,G(index),'-bo')
title('Cumulative variance explained by feature dimensions after 4x4 zone projection')
ylabel('Cumulative proportion of variance explained')
xlabel('Number of principal components retained')

% Reduce training data
reduced_training_features = projection_acp(training_features, V);
reduced_training_data = [dataTrain(:,1:5) reduced_training_features];

% Reduce Test data
test_features = double(dataTest(:,6:end));
reduced_test_features = projection_acp(test_features, V);
reduced_test_data = [dataTest(:,1:5) reduced_test_features];

save('reducedTrimmedDataTrainData2D_224x224.mat', 'reduced_training_data', '-v7.3')
save('reducedTrimmedDataTestData2D_224x224.mat', 'reduced_test_data', '-v7.3')







