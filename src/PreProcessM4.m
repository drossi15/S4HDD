

clc;
clearvars;
combinedData = load("src/data/combinedData.mat").combinedData;



%% Parameters
stations = unique(combinedData.station_id);  % stations_id
dates = unique(combinedData.Date, 'sorted');  %dates       
nStations = numel(stations);  %number of stations
nTimes = numel(dates);

%pollutant = {'NO2', 'CO'};  % two pollutants
pollutant = {'CO', 'NO2'};  % two pollutants
nPollutant = numel(pollutant);  %numbero of pollutants

%% Y
% size cell Y -> Y{1}, Y{2}
% size Y{n} : nStations x nTimes

Y = cell(1,nPollutant);
for p = 1:nPollutant        %external cycle for different pollutants
    Y_mat = NaN(nStations, nTimes);
    for i = 1:nStations
        stationData = combinedData(combinedData.station_id == stations(i), :);
        [~, timeIdx] = ismember(stationData.Date, dates);
        Y_mat(i, timeIdx) = stationData.(pollutant{p});
    end
    Y{p} = Y_mat;
end

%% Coordinates (lat,lon)
% size cell : coordinates{1}, coordinates{2ÿ
% size coordinates{n} : nStations x 2

coords = NaN(nStations, 2); 
for i = 1:nStations
    stationData = combinedData(combinedData.station_id == stations(i), :);
    coords(i, :) = [stationData.Latitude(1), stationData.Longitude(1)];
end

coordinates = cell(1,nPollutant);
for p = 1:nPollutant
    coordinates{p} = coords;  
end


%% X_beta
% size cell X_beta: X_beta{1}, X_beta{2}
% size X_beta{n} : nStations × 10 × nTimes

nCov = 6;
X_beta = cell(1,nPollutant);

for p = 1:nPollutant       % external cycle for different pollutants
    
    X_beta_mat = NaN(nStations, nCov, nTimes);
    
    for i = 1:nStations
        
        stationData = combinedData(combinedData.station_id == stations(i), :);
        [~, timeIdx] = ismember(stationData.Date, dates);

        X_beta_mat(i,1,timeIdx)  = stationData.relative_humidity;
        X_beta_mat(i,2,timeIdx)  = stationData.RAIN_24h;
        X_beta_mat(i,3,timeIdx)  = stationData.cos_sea;
        X_beta_mat(i,4,timeIdx)  = stationData.Latitude;
        X_beta_mat(i,5,timeIdx)  = stationData.Longitude;
        X_beta_mat(i,6,timeIdx)  = stationData.Altitude;
      

    end
    
    X_beta{p} = X_beta_mat;

end

%% X_z 
% size cell: X_z{1}, X_z{2}
% size X_z{n}:  nStations x 1


X_z = cell(1,nPollutant);

for p = 1:nPollutant
    X_z{p} = ones(nStations,1);  % costante per ogni stazione
end

%% Names
Y_name = pollutant;
X_beta_name = repmat({{'rh', 'rain','cos_sea','latitude','longitude','altitude'}},1,nPollutant);
X_z_name = repmat({{'constant'}},1,nPollutant);

%% Cell
data.coordinates = coordinates;
data.Y = Y;
data.Y_name = Y_name;
data.X_beta = X_beta;
data.X_beta_name = X_beta_name;
data.X_z = X_z;
data.X_z_name = X_z_name;
data.dates = dates;

%% Salva
save('src/data/data.mat', 'data');