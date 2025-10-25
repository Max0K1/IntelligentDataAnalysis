Year = [2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 ...
        2025 2025 2025 2025 2025 2025 2025 2025]';

Month = categorical({ ...
    'Січень'; 'Лютий'; 'Березень'; 'Квітень'; 'Травень'; 'Червень'; 'Липень'; 'Серпень'; ...
    'Вересень'; 'Жовтень'; 'Листопад'; 'Грудень'; ...
    'Січень'; 'Лютий'; 'Березень'; 'Квітень'; 'Травень'; 'Червень'; 'Липень'; 'Серпень' ...
});

Temperature = [-3 0 6 12 18 24 26 25 18 10 5 -1 -2 1 7 13 19 25 27 26]';
Rainfall    = [50 45 40 50 55 60 70 80 65 55 50 60 52 48 42 56 58 62 72 82]';
Sales       = [12 15 20 28 36 47 53 51 41 29 21 13 13 16 20 29 37 48 55 51]';

n = length(Sales);

threshold = median(Sales);
SalesClass = strings(n,1);

for i = 1:n
    if Sales(i) > threshold
        SalesClass(i) = "High";
    else
        SalesClass(i) = "Low";
    end
end

SalesClass = categorical(SalesClass);

T = table(Temperature, Rainfall, Year, Month, SalesClass);

treeModel = fitctree(T, "SalesClass");

view(treeModel, "Mode", "text");
view(treeModel, "Mode", "graph");

y_pred = resubPredict(treeModel);
confMat = confusionmat(SalesClass, y_pred)
trainingLoss = resubLoss(treeModel);
accuracy = 1 - trainingLoss;

fprintf('Точність моделі: %.2f%%\n', accuracy*100);