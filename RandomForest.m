function [model, results] = RandomForest(database, labels)
% Classification using Random Forest algorithm using TreeBagger
%
% Parameters :
%               Method: string declaring which database to use. Either
%               'LBP' or 'ZoneProject'.


NumTrees = [1000];
MinLeafSize = [10];
% NumPredictorsToSample = [5:floor(size(database,2)/10):size(database,2)];
NumPredictorsToSample = [77];

data = zeros(   length(NumTrees)*...
                length(NumPredictorsToSample)*...
                length(MinLeafSize), ...
                5);
row = 1;

for x = 1:length(NumTrees)
    for i = 1:1:length(MinLeafSize)
        for j = 1:length(NumPredictorsToSample)
            tic
            model = TreeBagger(NumTrees(x),database, labels, ...
                'MinLeafSize', MinLeafSize(i), ...
                'NumPredictorsToSample', NumPredictorsToSample(j), ...
                'OOBPrediction', 'on', ...
                'Options', statset('UseParallel',true));
            time = toc;
            
            % Which error do we keep? All of them or only last?
            error = oobError(model);
            
            data(row,:) = [NumTrees(x) NumPredictorsToSample(j) ...
                MinLeafSize(i) time error(end)];
            display([NumTrees(x) NumPredictorsToSample(j) ...
                MinLeafSize(i) time error(end)])
            row = row + 1;
        end
    end
end

headers = {'NumTrees', 'NumPredictors', 'MinLeafSize', 'Time', 'ErrorRate'};
results = [headers;num2cell(data)];

end