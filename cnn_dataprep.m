%% Add labels
clc;
clear variables;
%%
% Load data
data = readtable('data.csv');
labels = data.('Number_of_NMJ');
load trimmed_data_cnn_database.mat

cnn_database = uint8(cnn_database);
cnn_database(1,1,1,:) = labels;
%% Remove classes with too low count (those with only 50 items or more)
threshold = 4;

pruned_cnn_database = cnn_database;
while max(pruned_cnn_database(1,1,1,:)) > threshold
    for i = 1:size(pruned_cnn_database,4)

        if pruned_cnn_database(1,1,1,i) > threshold
            pruned_cnn_database(:,:,:,i) = [];
            break;
        end
    end 
end
%%
% extract 20% of data as test dataset
cv = cvpartition(size(pruned_cnn_database,4),'HoldOut', 0.1);
idx = cv.test;

% Seperate data into training and data set
%%
dataTrain = pruned_cnn_database(:,:,:,~idx);
dataTest = pruned_cnn_database(:,:,:,idx);
%%
for i = 1:size(dataTrain,4)
    img = dataTrain(:,:,:,i);
    %img = imresize(img,[227 227]);
    %img = imadjustn(img,[0.05 0.15], [0 1]);
    switch dataTrain(1,1,1,i)
        case 1
            str = ['CnnImg/1/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 2
            str = ['CnnImg/2/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 3
            str = ['CnnImg/3/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 4
            str = ['CnnImg/4/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        otherwise
            str = ['CnnImg/other/' string(i) '.jpg'];
            imwrite(img,join(str,''));
    end         
end

%%
for i = 1:size(dataTest,4)
    img = dataTest(:,:,:,i);
    %img = imresize(img,[227 227]);
    %img = imadjustn(img,[0.05 0.15], [0 1]);
    switch dataTest(1,1,1,i)
        case 1
            str = ['CnnImgTest/1/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 2
            str = ['CnnImgTest/2/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 3
            str = ['CnnImgTest/3/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        case 4
            str = ['CnnImgTest/4/' string(i) '.jpg'];
            imwrite(img,join(str,''));
        otherwise
            str = ['CnnImgTest/other/' string(i) '.jpg'];
            imwrite(img,join(str,''));
    end         
end





