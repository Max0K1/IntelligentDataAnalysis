%% Task 1

clear; clc; close all;

y = [1.6, 0.8, 1.2, 0.5, 0.9, 1.1, 1.1, 0.6, 1.5, 0.8, 0.9, 1.2, 0.5, 1.3, 0.8, 1.2]';
n = numel(y);
t = (1:n)';

figure;
plot(t, y, '-o', 'LineWidth', 1.5);
grid on;
xlabel('t');
ylabel('y(t)');
title('Time series y(t)');

y_t   = y(1:end-1);
y_t1  = y(2:end);
r1_approx = corr(y_t, y_t1);

fprintf('Approx (corr(y(t), y(t+1))) understanding: r1 ≈ %.4f\n', r1_approx);

figure;
scatter(y_t, y_t1, 60, 'filled');
grid on;
xlabel('y(t)');
ylabel('y(t+1)');
title('Scatter: y(t+1) vs y(t)');

p = polyfit(y_t, y_t1, 1);
xLine = linspace(min(y_t), max(y_t), 100);
yLine = polyval(p, xLine);
hold on;
plot(xLine, yLine, 'LineWidth', 1.5);
legend('Points', sprintf('Fit: y_{t+1}=%.3f y_t + %.3f', p(1), p(2)), 'Location', 'best');

ybar = mean(y);

num = sum( (y(1:end-1) - ybar) .* (y(2:end) - ybar) );
den = sum( (y - ybar).^2 );
r1_exact = num / den;

fprintf('Exact r1 by formula: r1 = %.6f\n', r1_exact);

try
    figure;
    autocorr(y, 'NumLags', 10);
    title('Autocorrelation (autocorr)');
catch
    disp('autocorr() not available (Econometrics Toolbox missing). Skipping.');
end

y_centered = y - mean(y);
[acf, lags] = xcorr(y_centered, 1, 'coeff');
r1_xcorr = acf(lags == 1);
fprintf('r1 from xcorr (coeff): r1 = %.6f\n', r1_xcorr);