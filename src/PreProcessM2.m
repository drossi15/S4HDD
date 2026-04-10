
clc;
clearvars;
combinedData = load("src/data/combinedData.mat").combinedData;


%% Parameters

stations = unique(combinedData.station_id);  % stations_id
dates = unique(combinedData.Date, 'sorted');  %dates        
nStations = numel(stations); %number of stations
nTimes = numel(dates); %number of Dates

%pollutant = 'NO2'; 
pollutant = 'CO'; 

%% Y 
% size: nStations × nTimes

Y_mat = NaN(nStations, nTimes);
for i = 1:nStations
    stationData = combinedData(combinedData.station_id == stations(i), :);
    [~, timeIdx] = ismember(stationData.Date, dates);
    Y_mat(i, timeIdx) = stationData.(pollutant);
end

%% Coordinates (lat, lon)
% size: nStations x 2

coords = NaN(nStations, 2); 
for i = 1:nStations
    stationData = combinedData(combinedData.station_id == stations(i), :);
    coords(i, :) = [stationData.Latitude(1), stationData.Longitude(1)];
end

%% X_beta (lat, lon, alt, zones)

% size: nStations × 4 × nTimes

altitudes = NaN(nStations, 1);
for i = 1:nStations
    idx = combinedData.station_id == stations(i);
    stationData = combinedData(idx, :);
    altitudes(i) = stationData.Altitude(1);
end

% lat + lon + alt
X_beta_base = [ coords, altitudes];
nCov = size(X_beta_base,2);
X_beta = repmat(X_beta_base, 1, 1, nTimes);

%% X_z (costante) 
% size: nStations x 1

X_z = ones(nStations, 1);

%% Names

Y_name = {pollutant};
X_beta_name = {'lat', 'lon', 'alt'};
X_z_name = {'constant'};

%% Cell 1x1

data.coordinates = {coords};
data.Y = {Y_mat};
data.Y_name = Y_name;
data.X_beta = {X_beta};
data.X_beta_name = {X_beta_name};
data.X_z = {X_z};
data.X_z_name = {X_z_name};
data.dates = {dates};

%% Save

save('src/data/data.mat', 'data');
