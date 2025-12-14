% Etalon surface y = x1^2 * sin(x2 - 1)

n = 15;

x1 = -7:10/(n-1):3;
x2 = -4.4:6.1/(n-1):1.7;

y = zeros(n,n);

for j = 1:n
    y(j,:) = x1.^2 .* sin(x2(j)-1);
end

figure;
surf(x1, x2, y);
xlabel('x1');
ylabel('x2');
zlabel('y');
title('Target surface');