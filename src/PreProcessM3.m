

clc;
clearvars;
combinedData = load("src/data/combinedData.mat").combinedData;



%% Parameters

stations = unique(combinedData.station_id);  % stations id
dates = unique(combinedData.Date, 'sorted'); %dates         
nStations = numel(stations); %number of stations
nTimes = numel(dates);  %Number of Dates

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

%% Coordinates (lat, lon, alt)
% size: nStations x 2

coords = NaN(nStations, 2);   
for i = 1:nStations
    stationData = combinedData(combinedData.station_id == stations(i), :);
    coords(i, :) = [stationData.Latitude(1), stationData.Longitude(1)];
end



%% X_beta
%size: nStations × 10 × nTimes

nCov = 10;
X_beta = NaN(nStations, nCov, nTimes);
for i = 1:nStations
    stationData = combinedData(combinedData.station_id == stations(i), :);
    [~, timeIdx] = ismember(stationData.Date, dates);

    X_beta(i,1,timeIdx)  = stationData.relative_humidity; %meteo
    X_beta(i,2,timeIdx)  = stationData.RAIN_24h; %meteo
    X_beta(i,3,timeIdx)  = stationData.WSPM; %meteo
    X_beta(i,4,timeIdx)  = stationData.sin_sea; %temporal
    X_beta(i,5,timeIdx)  = stationData.cos_sea; %temporal
    X_beta(i,6,timeIdx) = stationData.Latitude; %spatial
    X_beta(i,7,timeIdx) = stationData.Longitude; %spatial  
    X_beta(i,8,timeIdx) = stationData.Altitude; %spatial  
    X_beta(i,9,timeIdx) = stationData.is_weekend;  %temporal
    X_beta(i,10,timeIdx) = stationData.is_working_hour; %temporal

end
%% X_z (costante) replicato per tutti i tempi
% size: nStations x 1

X_z = ones(nStations, 1);

%% Names

Y_name = {pollutant};
X_beta_name = {'rh', 'rain', 'wspm','sin_sea','cos_sea','latitude','longitude','altitude','weekend','hour'};
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
