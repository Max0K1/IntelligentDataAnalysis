load fisheriris
X = meas;
Y = species;

cv = cvpartition(Y,'HoldOut',0.3);
Xtrain = X(training(cv),:); Ytrain = Y(training(cv));
Xtest = X(test(cv),:); Ytest = Y(test(cv));

tree = fitctree(Xtrain, Ytrain, 'PredictorNames', {'SL','SW','PL','PW'}, ...
    'MinLeafSize',5);

view(tree,'Mode','graph')

YPred = predict(tree, Xtest);
confMat = confusionmat(Ytest, YPred);
disp('Confusion matrix (rows: true, cols: pred):');
disp(confMat);

acc = sum(strcmp(YPred, Ytest))/numel(Ytest);
fprintf('Accuracy on test set: %.3f\n', acc);

imp = predictorImportance(tree);
fprintf('Predictor importance:\n');
for i=1:numel(imp)
    fprintf('  %s: %.3f\n', tree.PredictorNames{i}, imp(i));
end

[~,~,~,bestLevel] = cvloss(tree,'SubTrees','All','KFold',5);