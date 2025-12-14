%% Task 2

clear; clc;

Yt = 10;
mu = 0.2;
sigma2 = 0.5;
tau = 5;

Y_forecast = Yt + tau*mu;

MSE = tau * sigma2;

fprintf('Forecast Y(t+tau) = Y(t) + tau*mu = %.4f\n', Y_forecast);
fprintf('MSE(tau) = tau*sigma^2 = %.4f\n', MSE);

rng(1);
eps = sqrt(sigma2)*randn(tau,1);
e_real = sum(eps);
Y_real = Yt + tau*mu + e_real;

fprintf('One simulated real Y(t+tau) = %.4f\n', Y_real);
fprintf('One simulated forecast error e = %.4f\n', Y_real - Y_forecast);