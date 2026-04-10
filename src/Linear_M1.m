
clc;
clearvars;

tmp = load("src/data/combinedData.mat");
dataset = tmp.combinedData;
T = unique(dataset.Date);
times = size(T,1);

% Rimozione variabili inutili
toRemove = {'No','year','month','day','hour','PM2_5','PM10','SO2','O3','wd',...
    'station','Date','isCalm','TEMP','DEWP','RAIN','Zone','day_of_week'};
toRemove = intersect(dataset.Properties.VariableNames, toRemove);
dataset  = removevars(dataset, toRemove);

%% Linear Regression NO2 
dataset_no2 = removevars(dataset, 'CO');  
stations    = unique(dataset_no2.station_id);
nStations   = numel(stations);


residuals = cell(nStations, 1);
rmse     = zeros(nStations, 1);
mse      = zeros(nStations, 1);
bias     = zeros(nStations, 1);
r2       = zeros(nStations, 1);
obs_all  = [];
pred_all = [];

for i = 1:nStations
    % Split train/test
    idx_test  = dataset_no2.station_id == stations(i);
    idx_train = ~idx_test;
    trainData = dataset_no2(idx_train, :);
    testData  = dataset_no2(idx_test,  :);

    % TRAIN - rimuovo target, station_id e NaN
    y_train = log(trainData.NO2);
    X_train = removevars(trainData, {'NO2', 'station_id'});
    valid_train = ~isnan(y_train) & all(~isnan(X_train{:,:}), 2);
    y_train = y_train(valid_train);
    X_train = X_train(valid_train, :);

    % Standardizzazione manuale di X
    mu = mean(X_train{:,:}, 1);
    sigma = std(X_train{:,:}, 0, 1);
    X_train_std = (X_train{:,:} - mu) ./ sigma;
    X_train_std = array2table(X_train_std, 'VariableNames', X_train.Properties.VariableNames);

    mdl = fitlm(X_train_std, y_train);

    % TEST - rimuovo target, station_id e NaN
    y_test = log(testData.NO2);
    X_test = removevars(testData, {'NO2', 'station_id'});
    valid_test = ~isnan(y_test) & all(~isnan(X_test{:,:}), 2);
    y_test = y_test(valid_test);
    X_test = X_test(valid_test, :);

    % Standardizzo test set usando media e std del training
    X_test_std = (X_test{:,:} - mu) ./ sigma;
    X_test_std = array2table(X_test_std, 'VariableNames', X_test.Properties.VariableNames);

    y_hat = predict(mdl, X_test_std);

    % Back-transform 
    y_test_orig = exp(y_test);
    y_hat_orig  = exp(y_hat);

    % Salvataggio 
    obs_all  = [obs_all;  y_test_orig];
    pred_all = [pred_all; y_hat_orig];

    % Metriche 
    residuals{i} = y_test_orig - y_hat_orig;
    rmse(i) = sqrt(mean((y_test_orig - y_hat_orig).^2, 'omitnan'));
    mse(i)  = mean((y_test_orig - y_hat_orig).^2, 'omitnan');
    bias(i) = mean(y_test_orig - y_hat_orig, 'omitnan');
    denom   = sum((y_test_orig - mean(y_test_orig, 'omitnan')).^2, 'omitnan');
    r2(i)   =  1 - sum((y_test_orig - y_hat_orig).^2, 'omitnan') / denom;
end

save('src/Results/Linear_M1_NO2.mat', 'rmse', 'mse', 'bias', 'r2', 'obs_all', 'pred_all', 'residuals');

%% Linear Regression CO 
dataset_co = removevars(dataset, 'NO2');  
stations   = unique(dataset_co.station_id);
nStations  = numel(stations);

residuals = cell(nStations, 1);
rmse     = zeros(nStations, 1);
mse      = zeros(nStations, 1);
bias     = zeros(nStations, 1);
r2       = zeros(nStations, 1);
obs_all  = [];
pred_all = [];

for i = 1:nStations
    % Split train/test
    idx_test  = dataset_co.station_id == stations(i);
    idx_train = ~idx_test;
    trainData = dataset_co(idx_train, :);
    testData  = dataset_co(idx_test,  :);

    % TRAIN - rimuovo target, station_id e NaN
    y_train = log(trainData.CO);
    X_train = removevars(trainData, {'CO', 'station_id'});
    valid_train = ~isnan(y_train) & all(~isnan(X_train{:,:}), 2);
    y_train = y_train(valid_train);
    X_train = X_train(valid_train, :);

    % Standardizzazione manuale di X
    mu = mean(X_train{:,:}, 1);
    sigma = std(X_train{:,:}, 0, 1);
    X_train_std = (X_train{:,:} - mu) ./ sigma;
    X_train_std = array2table(X_train_std, 'VariableNames', X_train.Properties.VariableNames);

    mdl = fitlm(X_train_std, y_train);

    % TEST - rimuovo target, station_id e NaN
    y_test = log(testData.CO);
    X_test = removevars(testData, {'CO', 'station_id'});
    valid_test = ~isnan(y_test) & all(~isnan(X_test{:,:}), 2);
    y_test = y_test(valid_test);
    X_test = X_test(valid_test, :);

    % Standardizzo test set usando media e std del training
    X_test_std = (X_test{:,:} - mu) ./ sigma;
    X_test_std = array2table(X_test_std, 'VariableNames', X_test.Properties.VariableNames);

    y_hat = predict(mdl, X_test_std);

    % Back-transform
    y_test_orig = exp(y_test);
    y_hat_orig  = exp(y_hat);

    % Salvataggio
    obs_all  = [obs_all;  y_test_orig];
    pred_all = [pred_all; y_hat_orig];

    % Metriche 
    residuals{i} = y_test_orig - y_hat_orig;
    rmse(i) = sqrt(mean((y_test_orig - y_hat_orig).^2, 'omitnan'));
    mse(i)  = mean((y_test_orig - y_hat_orig).^2, 'omitnan');
    bias(i) = mean(y_test_orig - y_hat_orig, 'omitnan');
    denom   = sum((y_test_orig - mean(y_test_orig, 'omitnan')).^2, 'omitnan');
    r2(i)   = 1 - sum((y_test_orig - y_hat_orig).^2, 'omitnan') / denom;
end

save('src/Results/Linear_M1_CO.mat', 'rmse', 'mse', 'bias', 'r2', 'obs_all', 'pred_all', 'residuals');




%% Result Analysis NO2


result_no2 = load("src/Results/Linear_M1_NO2.mat");
nStations=12;

rmse = result_no2.rmse;
r2   = result_no2.r2;
bias = result_no2.bias;
obs  = result_no2.obs_all;
pred = result_no2.pred_all;
residuals = result_no2.residuals; 

fprintf('\n=== Metrics per station ===\n')
for i = 1:length(rmse)
    fprintf('Station %d -> RMSE: %.3f | R2: %.3f | Bias: %.3f\n', ...
        i, rmse(i), r2(i), bias(i));
end

rmse_mean = mean(rmse,'omitnan');
r2_mean   = mean(r2,'omitnan');
bias_mean = mean(bias,'omitnan');

fprintf('\n=== Mean metrics ===\n')
fprintf('Mean RMSE: %.3f\n', rmse_mean);
fprintf('Mean R2  : %.3f\n', r2_mean);
fprintf('Mean Bias: %.3f\n', bias_mean);
fprintf('CV RMSE: %.3f\n', rmse_mean/47.0345);

acf1 = zeros(nStations, 1);
for i = 1:nStations
    res = residuals{i};              
    res = res(~isnan(res));
    if numel(res) > 10
        acf = autocorr(res, 'NumLags', 1);   
        acf1(i) = acf(2);
    else
        acf1(i) = NaN;
    end
end

mean_acf1 = mean(acf1, 'omitnan');
fprintf('\n=== Residual Autocorrelation ===\n')
fprintf('Mean ACF1: %.3f\n', mean_acf1);


%% Rsult Analysis CO



nStations=12;
result_co = load("src/Results/Linear_M1_CO.mat");

rmse = result_co.rmse;
r2   = result_co.r2;
bias = result_co.bias;
obs  = result_co.obs_all;
pred = result_co.pred_all;
residuals = result_co.residuals; 

fprintf('\n=== Metrics per station ===\n')
for i = 1:length(rmse)
    fprintf('Station %d -> RMSE: %.3f | R2: %.3f | Bias: %.3f\n', ...
        i, rmse(i), r2(i), bias(i));
end

rmse_mean = mean(rmse,'omitnan');
r2_mean   = mean(r2,'omitnan');
bias_mean = mean(bias,'omitnan');

fprintf('\n=== Mean metrics ===\n')
fprintf('Mean RMSE: %.3f\n', rmse_mean);
fprintf('Mean R2  : %.3f\n', r2_mean);
fprintf('Mean Bias: %.3f\n', bias_mean);
fprintf('CV RMSE: %.3f\n', rmse_mean/1.2059e+03);

acf1 = zeros(nStations, 1);
for i = 1:nStations
    res = residuals{i};              
    res = res(~isnan(res));
    if numel(res) > 10
        acf = autocorr(res, 'NumLags', 1);   
        acf1(i) = acf(2);
    else
        acf1(i) = NaN;
    end
end

mean_acf1 = mean(acf1, 'omitnan');
fprintf('\n=== Residual Autocorrelation ===\n')
fprintf('Mean ACF1: %.3f\n', mean_acf1);