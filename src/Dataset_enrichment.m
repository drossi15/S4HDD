clc;
clearvars;

% load data

files = dir(fullfile('DATASET', '*.csv'));
nFiles = numel(files);
assert(nFiles > 0, 'Nessun file trovato nella cartella DATASET');


% Coordinates taken from papers
% https://www.mdpi.com/2071-1050/14/9/5104?utm_source=researchgate.net&utm_medium=article
% Altitudine taken from Google Earth

Longitude = [116.397, 116.23, 116.22, 116.417, 116.339, 116.184, ...
             116.628, 116.461, 116.655, 116.407, 116.287, 116.352];

Latitude  = [39.982, 40.217, 40.292, 39.929, 39.929, 39.914, ...
             40.328, 39.937, 40.127, 39.886, 39.987, 39.878];

Altitude  = [47, 67, 126, 49, 51, 76, 59, 40, 41, 45, 47, 47];

% Urban or SubUrban  
% Urban = 1 SubUrban = 0
%https://pmc.ncbi.nlm.nih.gov/articles/PMC4626967/
Zone      = [1,0,0,1,1,1,0,1,0,1,1,1];


data = cell(nFiles,1);

for i = 1:nFiles

    % Lettura file
    T = readtable(fullfile(files(i).folder, files(i).name));

    % Datetime
    T.Date = datetime(T.year, T.month, T.day, T.hour, 0, 0);
    T = sortrows(T, 'Date');
    T = T(9400*2: height(T), :);

    nMissing_NO2 = sum(isnan(T.NO2));
    nMissing_CO  = sum(isnan(T.CO));

    fprintf('Stazione %d: %s\n', i, files(i).name);
    fprintf('  - NO2 missing: %d / %d (%.2f%%)\n', ...
        nMissing_NO2, height(T), 100*nMissing_NO2/height(T));
    fprintf('  - CO  missing: %d / %d (%.2f%%)\n\n', ...
        nMissing_CO, height(T), 100*nMissing_CO/height(T));


    % fillmissing linear
    T.TEMP = fillmissing(T.TEMP, 'linear');
    T.DEWP = fillmissing(T.DEWP, 'linear');
    T.PRES = fillmissing(T.PRES, 'linear');
    T.WSPM = fillmissing(T.WSPM, 'linear');
    T.RAIN = fillmissing(T.RAIN, 'linear');

    % Temporal Variables
    T.day_of_week = weekday(T.Date);
    T.is_weekend  = double(T.day_of_week == 1 | T.day_of_week == 7);
    T.is_working_hour = double(T.hour >= 8 & T.hour <= 18);

    % Spatial Coordinate
    T.Longitude = repmat(Longitude(i), height(T), 1);
    T.Latitude  = repmat(Latitude(i),  height(T), 1);
    T.Altitude  = repmat(Altitude(i),  height(T), 1);
    
    T.Zone = repmat(Zone(i), height(T), 1);

    % station_id
    T.station_id = repmat(i, height(T), 1);


    % 24 hour lag variable
    T.RAIN_24h = movsum(T.RAIN, [23 0]); 
    
    %Seasonality
    T.sin_sea = sin(2*pi .* (T.month - 1) ./ 12);
    T.cos_sea = cos(2*pi .* (T.month - 1) ./ 12);

    %Formula di Magnus..
    T.relative_humidity = 100 * exp( ...
        (17.625 .* T.DEWP) ./ (T.DEWP + 243.04) - ...
        (17.625 .* T.TEMP) ./ (T.TEMP + 243.04) );

    % Salvataggio
    data{i} = T;
end



% Unisco tutto in un unico dataset
combinedData = vertcat(data{:});
combinedData = sortrows(combinedData, {'station_id','Date'});

fprintf('\nDataset finale creato:\n');
fprintf(' - Stazioni: %d\n', numel(unique(combinedData.station_id)));
fprintf(' - Osservazioni: %d\n', height(combinedData));
fprintf(' - Periodo: %s → %s\n', ...
    datestr(min(combinedData.Date)), ...
    datestr(max(combinedData.Date)));

save('src/data/combinedData.mat','combinedData');

summary(combinedData)





