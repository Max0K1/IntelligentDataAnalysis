G  = [4.5 4.8 5.0 5.4 5.9 6.2 6.8 7.1 7.5 8.0]';
Hb = [150 148 147 144 140 138 134 132 130 128]';

p = polyfit(G, Hb, 2);
a = p(1); b = p(2); c = p(3);

Hb_hat = polyval(p, G);

SS_res = sum( (Hb - Hb_hat).^2 );
SS_tot = sum( (Hb - mean(Hb)).^2 );
R2 = 1 - SS_res/SS_tot;

fprintf('Hb ≈ %.4f*G^2 + %.4f*G + %.4f\n', a, b, c);
fprintf('R^2 = %.4f\n', R2);

figure;
scatter(G, Hb, 'filled'); hold on; grid on;
G_fine  = linspace(min(G), max(G), 100)';
Hb_fine = polyval(p, G_fine);
plot(G_fine, Hb_fine, 'LineWidth', 2);
xlabel('Стабілізована глюкоза');
ylabel('Гемоглобін');
title('Нелінійна апроксимація Hb(G)');