%% Results Analysis
clc;
clearvars;

result = load("src/Results/M3_CO.mat");
r = result.results;

% RMSE e R2 per stazione
figure
subplot(1,2,1)
bar(r.rmse)
title('RMSE per stazione')
xlabel('Stazione')
ylabel('RMSE')

subplot(1,2,2)
bar(r.r2)
title('R^2 per stazione')
xlabel('Stazione')
ylabel('R^2')

% Metriche Global Metrics
mean_rmse = mean(r.rmse, 'omitnan');
mean_r2   = mean(r.r2,   'omitnan');
mean_bias = mean(r.bias, 'omitnan');
std_rmse  = std(r.rmse,  'omitnan');
%cvrmse = (mean_rmse/47.0345); % per NO2
cvrmse = (mean_rmse/1.2059e+03); % per CO

disp(['Mean RMSE: ', num2str(mean_rmse)]);
disp(['Mean R2:   ', num2str(mean_r2)]);
disp(['Mean Bias: ', num2str(mean_bias)]);
disp(['Std RMSE:  ', num2str(std_rmse)]);
disp(['CVRMSE:    ', num2str(cvrmse)]);

% Boxplot residui per stazione  
%residuals station x timestep
figure
boxplot(r.residuals')
title('Boxplot residui per stazione')
xlabel('Stazione')
ylabel('Residuo')

% Istogramma residui
figure
histogram(r.residuals(:), 50)
title('Distribuzione residui')
xlabel('Residuo')
ylabel('Frequenza')

% Residui medi nel tempo
res_mean = mean(r.residuals, 1, 'omitnan');


% Autocorrelazione residui medi
figure
autocorr(res_mean, 'NumLags', 48)
title('Autocorrelazione residui medi')

% Test di Ljung-Box
[h, pValue] = lbqtest(res_mean, 'Lags', 48);
disp(['Ljung-Box p-value: ', num2str(pValue)]);
disp(['Ljung-Box h:       ', num2str(h)]);

acf1 = zeros(size(r.residuals,1),1);

for i = 1:size(r.residuals,1)
    res = r.residuals(i,:);
    res = res(~isnan(res));
    
    if numel(res) > 10
        acf = autocorr(res,'NumLags',1);
        acf1(i) = acf(2);
    else
        acf1(i) = NaN;
    end
end

mean_acf1 = mean(acf1,'omitnan');

disp(['Mean residual autocorrelation lag1: ', num2str(mean_acf1)])

%%

beta = r.beta;   % cov x station

%mean
% Calculate the mean and standard deviation of beta
mean_beta = mean(beta, 2 , 'omitnan');
disp('Mean Beta per ogni covariata:');
disp(mean_beta);


%t-stat

varcov = r.varcov;   %cov x station
beta_cv = r.beta;  %cov x stations

t_stat = abs(beta_cv ./ sqrt(varcov));

t_stat_mean = mean(t_stat,2);
disp('t_stat per ogni covariata:');
disp(t_stat_mean);
