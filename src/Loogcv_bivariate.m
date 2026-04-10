% utilizzo di D-STEM software

load('src/data/data.mat')

coords = data.coordinates{1};

Y = data.Y;   %Y
X_beta = data.X_beta;     %X_beta  
X_beta_names = data.X_beta_name{1};  %X_beta_names
X_z = data.X_z;  %X_z

T = size(Y{1},2);  %number of times
nStations = size(Y{1},1);  %number of stations
nCov = size(X_beta{1},2); % numbero of covariates

%% Validation LOGOCV

%Metricis Inizialization
residuals = zeros(nStations, T);
rmse = zeros(1,nStations);
mse = zeros(1,nStations);
bias = zeros(1, nStations);
r2 = zeros(1,nStations);

beta_a = cell(1,nStations);
theta_z_a = zeros(1,nStations);
sigma_eps_a = cell(1,nStations);
sigma_eta_a = cell(1,nStations);
G_a = cell(1,nStations);
v_z_a = cell(1,nStations);
logL_a = zeros(1,nStations);
varcov_a = cell(1,nStations);

obs_all = [];
pred_all = [] ;

%Loop Logocv

for i= 1:nStations
    
    %test and training indexes
    idx_test = i;
    idx_train = setdiff(1:nStations, i);

    %Training Dataset
    Y_train{1} = Y{1}(idx_train,:);
    Y_train{2} = Y{2}(idx_train,:);         %training CO all the stations
    X_beta_train{1} = X_beta{1}(idx_train,:,:);
    X_beta_train{2} = X_beta{2}(idx_train,:,:); % CO all training

    % Test Dataset
    Y_test = Y{1}(idx_test,:); %test only on NO2

    %X_z and coordinates
    X_z_train{1} = X_z{1}(idx_train,:);
    X_z_train{2} = X_z{2}(idx_train,:);
    coords_train = coords(idx_train,:);   
    coords_test  = coords(idx_test,:);

    %stem varset and datestamp
    obj_stem_varset_p = stem_varset( ...
        Y_train, data.Y_name, ...
        [], [], ...
        X_beta_train, data.X_beta_name, ...
        X_z_train, data.X_z_name);

    obj_stem_datestamp = stem_datestamp('23-04-2015 07:00','28-02-2017 23:00', T);

    %gridlist (2 for bivariate model)
    obj_stem_gridlist_p=stem_gridlist();
    obj_stem_grid1 = stem_grid(coords_train, 'deg', 'sparse', 'point');
    obj_stem_gridlist_p.add(obj_stem_grid1);
    obj_stem_grid2 = stem_grid(coords_train, 'deg', 'sparse', 'point');
    obj_stem_gridlist_p.add(obj_stem_grid2);

    % Model
    shape = [];
    obj_stem_modeltype = stem_modeltype('HDGM');
    obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
                              [], [], obj_stem_datestamp, [], obj_stem_modeltype, shape);

    % Parameters
    obj_stem_par_constraints = stem_par_constraints();
    obj_stem_par_constraints.time_diagonal = 0;
    obj_stem_par = stem_par(obj_stem_data, 'exponential', obj_stem_par_constraints);
    obj_stem_model = stem_model(obj_stem_data, obj_stem_par);


    % Data Transformation
    obj_stem_model.stem_data.log_transform();
    obj_stem_model.stem_data.standardize;

    %Initial Values
    if i == 1 || ~exist('beta_prev','var')

        obj_stem_par.beta = obj_stem_model.get_beta0();
        obj_stem_par.theta_z = 1; %deg
        obj_stem_par.v_z = [1 0.6;0.6 1];
        obj_stem_par.sigma_eta = diag([0.2 0.2]);
        obj_stem_par.G = diag([0.8 0.8]);
        obj_stem_par.sigma_eps = diag([0.3 0.3]);
        obj_stem_model.set_initial_values(obj_stem_par);

    else
        %warm start to reduce computational cost
        obj_stem_par.beta = beta_prev;
        obj_stem_par.theta_z = theta_z_prev;
        obj_stem_par.v_z = v_z_prev;
        obj_stem_par.sigma_eta = sigma_eta_prev;
        obj_stem_par.G = G_prev;
        obj_stem_par.sigma_eps = sigma_eps_prev;
        obj_stem_model.set_initial_values(obj_stem_par);

    end

    % Model Estimation

    exit_toll = 0.001;
    max_iterations = 20;
    obj_stem_EM_options = stem_EM_options();
    obj_stem_EM_options.exit_tol_par = exit_toll;
    obj_stem_EM_options.max_iterations = max_iterations;
    obj_stem_model.EM_estimate(obj_stem_EM_options);
    obj_stem_model.set_varcov;
    obj_stem_model.set_logL;

    %Kriging
    X_beta_test = X_beta{1}(idx_test,:,:);
    nTest = size(X_beta_test,1);
    X_beta_test_krig = zeros(nTest, nCov+1, T);

    for t = 1:T
        temp = squeeze(X_beta_test(:,:,t));
        X_beta_test_krig(:,:,t) = [ temp, ones(nTest,1) ];
    end

    X_beta_names_krig = [X_beta_names, {'constant'}];
    obj_stem_krig_grid = stem_grid(coords_test, 'deg', 'sparse', 'point');
    obj_stem_krig_data = stem_krig_data( ...
        obj_stem_krig_grid, ...
        X_beta_test_krig, ...
        X_beta_names_krig, ...
        []);
    obj_stem_krig = stem_krig(obj_stem_model, obj_stem_krig_data);
    obj_stem_krig_options = stem_krig_options();
    obj_stem_krig_options.block_size = 1000;
    obj_stem_krig_result = obj_stem_krig.kriging(obj_stem_krig_options);

    %Prediction
    y_hat = obj_stem_krig_result{1}.y_hat;  % solo NO2
    obs_all = [obs_all; Y_test(:)];
    pred_all = [pred_all; y_hat(:)];

    beta_a{i} = obj_stem_model.stem_EM_result.stem_par.beta;
    theta_z_a(i) = obj_stem_model.stem_EM_result.stem_par.theta_z;
    sigma_eps_a{i} = obj_stem_model.stem_EM_result.stem_par.sigma_eps;
    sigma_eta_a{i} = obj_stem_model.stem_EM_result.stem_par.sigma_eta;
    G_a{i} = obj_stem_model.stem_EM_result.stem_par.G;
    v_z_a{i} = obj_stem_model.stem_EM_result.stem_par.v_z;
    logL_a(i) = obj_stem_model.stem_EM_result.logL;
    varcov_a{i} = diag(obj_stem_model.stem_EM_result.stem_par.varcov(1:nCov*2,1:nCov*2));

    
    beta_prev = obj_stem_model.stem_EM_result.stem_par.beta;
    theta_z_prev = obj_stem_model.stem_EM_result.stem_par.theta_z;
    v_z_prev = obj_stem_model.stem_EM_result.stem_par.v_z;
    sigma_eta_prev = obj_stem_model.stem_EM_result.stem_par.sigma_eta;
    G_prev = obj_stem_model.stem_EM_result.stem_par.G;
    sigma_eps_prev = obj_stem_model.stem_EM_result.stem_par.sigma_eps;

    %Metrics Compute
    residuals(i, :) = Y_test - y_hat;
    rmse(i) = sqrt(mean((Y_test - y_hat).^2,'all','omitnan'));
    mse(i) = mean((Y_test - y_hat).^2,'all','omitnan');
    bias(i) = mean(Y_test - y_hat,'all','omitnan');

    r2(i) = 1 - sum((Y_test - y_hat).^2,'all','omitnan') / ...
             sum((Y_test - mean(Y_test,'all','omitnan')).^2,'all','omitnan');

end



% Save results of the logocv

results.rmse = rmse;
results.mse = mse;
results.bias = bias;
results.r2 = r2;
results.residuals = residuals;
results.obs = obs_all;
results.pred = pred_all;
results.beta = beta_a;
results.theta_z = theta_z_a;
results.sigma_eps = sigma_eps_a;
results.G = G_a;
results.v_z = v_z_a;
results.logL = logL_a;
results.varcov = varcov_a;

%save('src/Results/M4_NO2.mat','results')
save('src/Results/M4_CO.mat','results')

