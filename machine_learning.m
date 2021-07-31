%% Main file for machine learning algorithms Project SYS800

clc;
clear variables;

load reducedTrimmedDataTrainData2D_224x224.mat
%%
features = double(reduced_training_data(:,6:end));
labels = double(reduced_training_data(:,2));

%% Launch Random forest hyperparameter testing
% Send database to GPU
gpuArray(features);
gpuArray(labels);

% Start hyperparameter testing
[model, results] = RandomForest(features, labels);

%% Test Model
load reducedTrimmedDataTestData2D_224x224.mat
%%
labels = double(reduced_test_data(:,2));
features = double(reduced_test_data(:,6:end));
ZP_fit = model.predict(features);
ZP_fit = str2num(cell2mat(ZP_fit));

c_zp = confusionmat(labels,ZP_fit);


