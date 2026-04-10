
    % Carico il dataset creato con Dataset enrichment
    clc, clearvars
    load("src/data/combinedData.mat")
    
    
    %%

    % Ricavo i nomi delle stazioni
    stationIds = unique(combinedData.station);
    disp('Unique Station IDs:');
    disp(stationIds);
    
    
    %% Plot della posizione delle stazioni (lat,lon,alt)
    
    lat = combinedData.Latitude;
    lon = combinedData.Longitude;
    alt = combinedData.Altitude;
    
    sizes = rescale(alt, 40, 200); 
    
    figure('Color','w')
    
    geoscatter(lat, lon, sizes, alt, 'filled', ...
        'MarkerEdgeColor','k', ...
        'LineWidth',0.5, ...
        'MarkerFaceAlpha',0.9)
    
    geobasemap streets
   
    geolimits([min(lat)-0.1 max(lat)+0.1], ...
              [min(lon)-0.1 max(lon)+0.1])
    
    colormap(turbo)
    cb = colorbar;
    cb.Label.String = 'Altitude (m)';
    cb.FontSize = 11;
    
    title('Stations Beijing Area', 'FontSize', 14, 'FontWeight','bold')


    
    
    
    
%% Heatmap Plot: NO2 Urban vs Suburban

month_names = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
hours = string(0:23);

no2_urban = zeros(24, 12);
no2_suburban = zeros(24, 12);

% Calculate means all hour and month
for h = 0:23
    for m = 1:12
        % Urban 
        idx_u = combinedData.hour == h & combinedData.month == m & combinedData.Zone == 1;
        no2_urban(h+1, m) = mean(combinedData.NO2(idx_u), 'omitnan');
        
        % Suburban
        idx_s = combinedData.hour == h & combinedData.month == m & combinedData.Zone == 0;
        no2_suburban(h+1, m) = mean(combinedData.NO2(idx_s), 'omitnan');
    end
end

max_val = max([max(no2_urban(:)), max(no2_suburban(:))]);

figure('Position', [100, 100, 1200, 500]); % Wider figure to fit both
t = tiledlayout(1,2, 'TileSpacing', 'Compact');

%  Urban
nexttile
h1 = heatmap(month_names, hours, no2_urban, 'Colormap', hot);
h1.Title = 'Urban NO2 Mean';
h1.XLabel = 'Month'; h1.YLabel = 'Hour';
h1.ColorLimits = [0 max_val]; % Same scale

% Suburban
nexttile
h2 = heatmap(month_names, hours, no2_suburban, 'Colormap', hot);
h2.Title = 'Suburban NO2 Mean';
h2.XLabel = 'Month'; h2.YLabel = 'Hour (0-23)';
h2.ColorLimits = [0 max_val]; % Same scale

title(t, 'Spatiotemporal Distribution of NO2 Concentrations', 'FontSize', 14, 'FontWeight', 'Bold');

    
    
%% Heatmap Plot: CO Urban vs Suburban

month_names = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
hours = string(0:23);

co_urban = zeros(24, 12);
co_suburban = zeros(24, 12);

% Calculate means for all hours and month
for h = 0:23
    for m = 1:12
        % Urban 
        idx_u = combinedData.hour == h & combinedData.month == m & combinedData.Zone == 1;
        co_urban(h+1, m) = mean(combinedData.CO(idx_u), 'omitnan');
        
        % Suburban
        idx_s = combinedData.hour == h & combinedData.month == m & combinedData.Zone == 0;
        co_suburban(h+1, m) = mean(combinedData.CO(idx_s), 'omitnan');
    end
end


max_val_co = max([max(co_urban(:)), max(co_suburban(:))]);

figure('Name', 'CO Spatiotemporal Heatmap', 'Position', [100, 100, 1000, 500]);
t_co = tiledlayout(1,2, 'TileSpacing', 'Compact');

%Urban CO
nexttile
h1_co = heatmap(month_names, hours, co_urban, 'Colormap', hot);
h1_co.Title = 'Urban CO Mean ';
h1_co.XLabel = 'Month'; h1_co.YLabel = 'Hour';
h1_co.ColorLimits = [0 max_val_co];

% Suburban CO
nexttile
h2_co = heatmap(month_names, hours, co_suburban, 'Colormap', hot);
h2_co.Title = 'Suburban CO Mean ';
h2_co.XLabel = 'Month'; h2_co.YLabel = 'Hour (0-23)';
h2_co.ColorLimits = [0 max_val_co];

title(t_co, 'Spatiotemporal Distribution of CO Concentrations', 'FontSize', 14, 'FontWeight', 'Bold');

       
%%  Seasonal Comparison: NO2 and CO

% 1. Setup indices and seasonal groups
idx_urban    = combinedData.Zone == 1;
idx_suburban = combinedData.Zone == 0;
seasons = {[12,1,2], [3,4,5], [6,7,8], [9,10,11]};
season_names = {'Winter','Spring','Summer','Autumn'};

% 2. Preallocate arrays
no2_means = zeros(4, 2); % Column 1: Urban, Column 2: Suburban
co_means  = zeros(4, 2);

% 3. Calculate seasonal means
for s = 1:4
    idx_s = ismember(combinedData.month, seasons{s});
    
    % NO2 Means
    no2_means(s, 1) = mean(combinedData.NO2(idx_s & idx_urban),    'omitnan');
    no2_means(s, 2) = mean(combinedData.NO2(idx_s & idx_suburban), 'omitnan');
    
    % CO Means
    co_means(s, 1)  = mean(combinedData.CO(idx_s & idx_urban),     'omitnan');
    co_means(s, 2)  = mean(combinedData.CO(idx_s & idx_suburban),  'omitnan');
end

% 4. Create the combined plot
figure('Name', 'Seasonal Pollutant Comparison', 'Position', [100, 100, 1000, 450]);
t = tiledlayout(1, 2, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% --- Tile 1: NO2 ---
nexttile
b1 = bar(no2_means);
b1(1).FaceColor = [0.2 0.4 0.6]; % Blu scuro per Urban
b1(2).FaceColor = [0.6 0.8 1.0]; % Blu chiaro per Suburban
xticklabels(season_names);
ylabel('Mean NO_2 concentration (\mu g/m^3)');
title('Seasonal NO_2 Comparison');
grid on;
legend({'Urban', 'Suburban'}, 'Location', 'northeast');

% --- Tile 2: CO ---
nexttile
b2 = bar(co_means);
b2(1).FaceColor = [0.6 0.2 0.2]; % Rosso scuro per Urban
b2(2).FaceColor = [1.0 0.6 0.6]; % Rosso chiaro per Suburban
xticklabels(season_names);
ylabel('Mean CO concentration (\mu g/m^3)');
title('Seasonal CO Comparison');
grid on;
legend({'Urban', 'Suburban'}, 'Location', 'northeast');

% Final shared title
title(t, 'Pollutant Concentration Comparison by Season and Zone', 'FontSize', 14, 'FontWeight', 'bold');

       
    
%% Plot Correlazione tra le variabili numeriche

    numericVars = varfun(@isnumeric, combinedData, 'OutputFormat','uniform');
    
    % Escludo ID e altre variabili
    exclude = ismember(combinedData.Properties.VariableNames, ...
        {'No','year','month','day','hour','PM2_5','PM10','SO2','O3','wd',...
            'station','Date','isCalm','Zone',...
            'day_of_week', 'station_id', 'TEMP','PRES','DEWP','RAIN'});
    
    numericVars = numericVars & ~exclude;
    
    X = combinedData{:, numericVars};
    varNames = combinedData.Properties.VariableNames(numericVars);
    
    % Correlazione
    C = corrcoef(X,'Rows','pairwise');
    
    % Heatmap
    figure;
    heatmap(varNames, varNames, C, ...
        'Colormap', parula, ...
        'ColorLimits',[-1 1]);
    
    title('Correlation Heatmap');


%% VIF



vifVars = varfun(@isnumeric, combinedData, 'OutputFormat','uniform');
    
% Escludo ID e altre variabili
exclude = ismember(combinedData.Properties.VariableNames, ...
        {'No','year','month','day','hour','PM2_5','PM10','SO2','O3','wd',...
            'station','Date','isCalm','Zone',...
            'day_of_week', 'station_id', 'TEMP','PRES','DEWP','RAIN'});
    
vifVars = vifVars & ~exclude;

X = combinedData{:, vifVars};
varNames = combinedData.Properties.VariableNames(vifVars);

% Calcolo del Variance Inflation Factor (VIF)

vifValues = zeros(1, sum(vifVars));
for j = 1:length(vifValues)
    model = fitlm(X(:, [1:j-1, j+1:end]), X(:, j)); % Fit linear model escludendo la variabile j-esima
    vifValues(j) = 1 / (1 - model.Rsquared.Ordinary); % Calculate VIF
end

% Visualizzazione
figure;
bar(vifValues);
xticks(1:length(vifValues));
xticklabels(varNames);
xtickangle(45);
set(gca, 'XTickLabel', varNames, 'XTickLabelRotation', 45);
ylabel('Variance Inflation Factor (VIF)');
title('VIF for Numeric Variables');
grid on;



%% Plot di NO2 per tutte le 12 stazioni in una sola figura (12 subplot)

stationIds = unique(combinedData.station_id);

figure('Name', 'NO2 Concentration - All 12 Stations', ...
    'Position', [100, 100, 1600, 1200], ...
    'Color', 'w');

for i = 1:length(stationIds)
   
    currentStation = stationIds(i);  
    idx = combinedData.station_id == currentStation;
    data_station = combinedData(idx, :);
    
    subplot(4, 3, i);
    plot(data_station.Date, data_station.NO2, 'b-', 'LineWidth', 1.2);
    grid on;
    
    title(string(currentStation), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Date', 'FontSize', 10);
    ylabel('NO_2 (\mug/m^3)', 'FontSize', 10);
    
    ax = gca;
    ax.FontSize = 9;
    ax.LineWidth = 1;
    ax.XTickLabelRotation = 45;
end

sgtitle('NO2 Concentration Time Series', ...
    'FontSize', 16, 'FontWeight', 'bold');


%% PLot di CO per tutte le 12 stazioni in una sola figura 

stationIds = unique(combinedData.station_id);

figure('Name', 'CO Concentration - All 12 Stations', ...
    'Position', [100, 100, 1600, 1200], ...
    'Color', 'w');

for i = 1:length(stationIds)
    
    currentStation = stationIds(i);  
    idx = combinedData.station_id == currentStation;
    data_station = combinedData(idx, :);
    
    subplot(4, 3, i);
    plot(data_station.Date, data_station.CO, 'b-', 'LineWidth', 1.2);
    grid on;
    
    title(string(currentStation), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Date', 'FontSize', 10);
    ylabel('NO_2 (\mug/m^3)', 'FontSize', 10);
    
    ax = gca;
    ax.FontSize = 9;
    ax.LineWidth = 1;
    ax.XTickLabelRotation = 45;
end

sgtitle('NO2 Concentration Time Series', ...
    'FontSize', 16, 'FontWeight', 'bold');

