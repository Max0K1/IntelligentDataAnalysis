Lipo = [3.1 3.3 3.4 3.7 3.8 4.0 4.2 4.5 4.8 5.0]';
Hemo = [120 122 125 128 130 133 135 139 142 145]';

R = corrcoef(Lipo, Hemo);
r = R(1,2);

n = length(Lipo);
t_stat = r * sqrt( (n-2) / (1 - r^2) );
p_value = 2 * (1 - tcdf(abs(t_stat), n-2));

fprintf("r = %.4f, p = %.6f\n", r, p_value);