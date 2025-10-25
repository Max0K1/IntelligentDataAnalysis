clc; clear; close all;

Year = [2024 2024 2024 2024 2024 2024 2024 2024 2024 2024 ...
        2025 2025 2025 2025 2025 2025 2025 2025 2025 2025]';
Month = {'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; ...
         'Nov'; 'Dec'; 'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'};
Temperature = [-3 0 2 7 10 15 20 23 25 18 10 5 -2 1 5 9 14 19 22 27]';
Rainfall    = [60 58 50 48 55 70 75 80 82 60 50 40 45 47 49 52 60 65 68 72]';
Sales       = [12 15 17 20 22 28 30 35 38 32 25 20 18 21 25 29 35 40 45 53]';

T = table(Year, Month, Temperature, Rainfall, Sales);

x = Temperature;
z = Rainfall;
y = Sales;

calcMetrics = @(y, yhat, p) struct( ...
    'RMSE',  sqrt(mean((y - yhat).^2)), ...
    'R2',    1 - sum((y - yhat).^2)/sum((y - mean(y)).^2), ...
    'adjR2', 1 - ( (numel(y)-1)/(numel(y)-p) ) * ( sum((y - yhat).^2)/sum((y - mean(y)).^2) ) ...
);

mdl_poly2 = fitlm(x, y, 'poly2');
yhat_poly2 = predict(mdl_poly2, x);
m_poly2 = calcMetrics(y, yhat_poly2, 3);

x_inv = 1./(x - min(x) + 1);
mdl_inv = fitlm(x_inv, y);
yhat_inv = predict(mdl_inv, x_inv);
m_inv = calcMetrics(y, yhat_inv, 2);

mask_pos = x > 0;
x_pos = x(mask_pos); y_pos = y(mask_pos);

powerFun = @(b, x) b(1) * x.^b(2);
start_power = [1, 0.5];
mdl_power = fitnlm(x_pos, y_pos, powerFun, start_power);
yhat_power_full = NaN(size(y));
yhat_power_full(mask_pos) = predict(mdl_power, x_pos);
m_power = calcMetrics(y_pos, yhat_power_full(mask_pos), 2);

expFun = @(b, x) b(1) * exp(b(2) * x);
start_exp = [10, 0.05];
mdl_exp = fitnlm(x, y, expFun, start_exp);
yhat_exp = predict(mdl_exp, x);
m_exp = calcMetrics(y, yhat_exp, 2);

useLogistic = true;
if useLogistic
    logisticFun = @(b, x) b(1) ./ (1 + exp(-(b(2) + b(3)*x)));
    start_log = [max(y), 0, 0.1];
    mdl_log = fitnlm(x, y, logisticFun, start_log);
    yhat_log = predict(mdl_log, x);
    m_log = calcMetrics(y, yhat_log, 3);
end

fprintf('\n=== Якість нелінійних моделей (по Temperature) ===\n');
fprintf('Поліном 2-го ступеня:   R2=%.3f, adjR2=%.3f, RMSE=%.3f\n', m_poly2.R2, m_poly2.adjR2, m_poly2.RMSE);
fprintf('Обернена (a + b/x):     R2=%.3f, adjR2=%.3f, RMSE=%.3f\n', m_inv.R2,   m_inv.adjR2,   m_inv.RMSE);
fprintf('Степенева (a*x^b)*:     R2=%.3f, adjR2=%.3f, RMSE=%.3f   (*оцінка на x>0)\n', m_power.R2, m_power.adjR2, m_power.RMSE);
fprintf('Експоненціальна:         R2=%.3f, adjR2=%.3f, RMSE=%.3f\n', m_exp.R2,   m_exp.adjR2,   m_exp.RMSE);
if useLogistic
    fprintf('Логістична (опц.):       R2=%.3f, adjR2=%.3f, RMSE=%.3f\n', m_log.R2, m_log.adjR2, m_log.RMSE);
end

metricsAll = [m_poly2.adjR2, m_inv.adjR2, m_exp.adjR2];
if useLogistic, metricsAll = [metricsAll, m_log.adjR2]; end
[~, bestIdx] = max(metricsAll);

modelNames = {'poly2','inverse','exponential'};
yhatAll = {yhat_poly2, yhat_inv, yhat_exp};
if useLogistic, modelNames{end+1}='logistic'; yhatAll{end+1}=yhat_log; end
bestName = modelNames{bestIdx};
yhat_best = yhatAll{bestIdx};

fprintf('\nНайкраща (за adjR2) модель: %s\n', bestName);

res = y - yhat_best;

figure('Name','Найкраща модель — графіки');
tiledlayout(1,3);
nexttile;
scatter(x,y,'filled'); hold on;
xx = linspace(min(x), max(x), 200)';
switch bestName
    case 'poly2'
        plot(xx, predict(mdl_poly2, xx), 'LineWidth',1.8);
    case 'inverse'
        xx_inv = 1./(xx - min(x) + 1);
        plot(xx, predict(mdl_inv, xx_inv), 'LineWidth',1.8);
    case 'exponential'
        plot(xx, predict(mdl_exp, xx), 'LineWidth',1.8);
    case 'logistic'
        plot(xx, predict(mdl_log, xx), 'LineWidth',1.8);
end
grid on; xlabel('Temperature'); ylabel('Sales');
title(sprintf('Data + %s fit', bestName));

nexttile;
stem(res,'filled'); grid on; title('Залишки'); xlabel('Спостереження'); ylabel('y - \ityhat');

nexttile;
qqplot(res); title('QQ-plot залишків');

tbl = table(x, z, y, ...
    x.^2, z.^2, x.*z, ...
    'VariableNames', {'Temp','Rain','Sales','Temp2','Rain2','TempRain'});

mdl_poly2_2D = fitlm(tbl, 'Sales ~ Temp + Temp2 + Rain + Rain2 + TempRain');

yhat_poly2_2D = predict(mdl_poly2_2D, tbl);
m_poly2_2D = calcMetrics(y, yhat_poly2_2D, 6);

fprintf('\nКвадратична 2D (Temp,Rain): R2=%.3f, adjR2=%.3f, RMSE=%.3f\n', ...
    m_poly2_2D.R2, m_poly2_2D.adjR2, m_poly2_2D.RMSE);

figure('Name','Квадратична 2D поверхня');
[Xg, Zg] = meshgrid(linspace(min(x),max(x),30), linspace(min(z),max(z),30));
Tgrid = table(Xg(:), Zg(:), Xg(:).^2, Zg(:).^2, Xg(:).*Zg(:), ...
    'VariableNames', {'Temp','Rain','Temp2','Rain2','TempRain'});
Yg = predict(mdl_poly2_2D, Tgrid);
surf(Xg, Zg, reshape(Yg, size(Xg)));
xlabel('Temperature'); ylabel('Rainfall'); zlabel('Sales');
title('poly2 по Temperature і Rainfall'); grid on; shading interp;