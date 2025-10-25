n = length(Sales);
X = [ones(n,1) Temperature Rainfall];
b = X \ Sales;

b0 = b(1);
b1 = b(2);
b2 = b(3);

Sales_hat = X * b;

SS_res = sum( (Sales - Sales_hat).^2 );
SS_tot = sum( (Sales - mean(Sales)).^2 );
R2 = 1 - SS_res/SS_tot;

fprintf('Sales ≈ %.4f + %.4f*Temperature + %.4f*Rainfall\n', b0, b1, b2);
fprintf('R^2 = %.4f\n', R2);