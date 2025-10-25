clc; clear; close all;

Year = [2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 ...
        2025 2025 2025 2025 2025 2025 2025 2025]';
Month = {'Січень','Лютий','Березень','Квітень','Травень','Червень',...
         'Липень','Серпень','Вересень','Жовтень','Листопад','Грудень',...
         'Січень','Лютий','Березень','Квітень','Травень','Червень',...
         'Липень','Серпень'}';

Temperature = [-3 0 6 12 18 24 26 25 18 10 5 -1 ...
               -2 1 7 13 19 25 27 26]';
Rainfall = [50 45 40 50 55 60 70 80 65 55 50 60 ...
            52 48 42 56 58 62 72 82]';
Sales = [12 15 20 28 36 47 53 51 40 29 21 16 ...
         13 16 21 29 37 48 52 51]';

T = table(Year, Month, Temperature, Rainfall, Sales);

disp('=== Описова статистика ===');
summary(T)

figure;
subplot(1,2,1)
scatter(Temperature, Sales, 'filled')
xlabel('Температура (°C)')
ylabel('Продажі (тис. шт)')
title('Залежність продажів від температури')

subplot(1,2,2)
scatter(Rainfall, Sales, 'filled')
xlabel('Опади (мм)')
ylabel('Продажі (тис. шт)')
title('Залежність продажів від опадів')

X = [Temperature Rainfall];
Y = Sales;

mdl = fitlm(X, Y, 'Intercept', true);

disp('=== Результати лінійної регресії ===');
disp(mdl)

fprintf('\nРівняння регресії:\n');
fprintf('Sales = %.3f + %.3f * Temperature + %.3f * Rainfall\n', ...
    mdl.Coefficients.Estimate(1), mdl.Coefficients.Estimate(2), mdl.Coefficients.Estimate(3));

[TempGrid, RainGrid] = meshgrid(linspace(min(Temperature), max(Temperature), 20), ...
                                linspace(min(Rainfall), max(Rainfall), 20));
SalesPred = mdl.Coefficients.Estimate(1) + ...
            mdl.Coefficients.Estimate(2)*TempGrid + ...
            mdl.Coefficients.Estimate(3)*RainGrid;

figure;
surf(TempGrid, RainGrid, SalesPred)
xlabel('Температура (°C)')
ylabel('Опади (мм)')
zlabel('Прогноз продажів (тис. шт)')
title('Регресійна поверхня продажів')
shading interp
colorbar

figure;
subplot(1,2,1)
plotResiduals(mdl,'histogram')
title('Гістограма залишків')

subplot(1,2,2)
plotResiduals(mdl,'fitted')
title('Залежність залишків від передбачених значень')