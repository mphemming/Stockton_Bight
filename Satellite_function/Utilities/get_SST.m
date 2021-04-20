function [SST_struct] = get_SST(LONG,LAT,TIME)

%% get SST filenames
%=======================================================
%-------------------------------------------------------------------------
disp('Getting filenames....');
% determine year of transect
[yr,mn,dy] = datevec(TIME); yr = unique(yr);
%-------------------------------------------------------------------------
% get list of available filenames for download
thredds_url = ['http://thredds.aodn.org.au/thredds/catalog/IMOS/SRS/SST/ghrsst/L3S-1d/ngt/',num2str(yr),'/catalog.html'];
sites_html = webread(thredds_url);    
find_nc = strfind(sites_html,'.nc</tt></a></td>');
for n_files = 1:numel(find_nc)
    files(n_files).name = sites_html(find_nc(n_files)-55:find_nc(n_files)+2);
end
files = vertcat(files.name);
%-------------------------------------------------------------------------
% determine those files closest to each ship transect time
TIME_web_format = datestr(TIME,'yyyymmdd');
for n_times = 1:numel(TIME)
    t_check = TIME_web_format(n_times,:);
    % get files closest in time
    for n_files = 1:size(files,1)
        if ~isempty(strmatch(t_check,files(n_files,:)))
            f = n_files;
        end
    end
    chosen_files(n_times) = convertCharsToStrings(files(f,:));
end

clear f n_times TIME_web_format n_files
disp('Getting filenames.... Done.');
%-------------------------------------------------------------------------
%% Determine data approximate area for reducing loading time
%=======================================================
% Using first filename
filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/SST/ghrsst/L3S-1d/ngt/2020/',num2str(chosen_files(1))];
lat = ncread(filename,'lat');
lon = ncread(filename,'lon');
f_lat = [nanmin(find(abs(lat-nanmin(LAT)) == nanmin(abs(lat-nanmin(LAT)))))-40, ...
            nanmax(find(abs(lat-nanmax(LAT)) == nanmin(abs(lat-nanmax(LAT)))))+40];
f_long = [nanmin(find(abs(lon-nanmin(LONG)) == nanmin(abs(lon-nanmin(LONG)))))-40, ...
            nanmax(find(abs(lon-nanmax(LONG)) == nanmin(abs(lon-nanmax(LONG)))))+40];
        
clear filename lat lon
%% get SST data
%=======================================================
disp('Getting data....');
% download data sets
previous_filename = '';
for n_load = 1:numel(chosen_files)
    if exist('filename','var')
        previous_filename = filename;
    end
    filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/SST/ghrsst/L3S-1d/ngt/2020/',num2str(chosen_files(n_load))];
    % get data
    if isempty(strmatch(filename,previous_filename))
        disp(filename)    
        SST_struct(n_load).lat = ncread(filename,'lat',f_lat(1),f_lat(2)-f_lat(1));
        SST_struct(n_load).lon = ncread(filename,'lon',f_long(1),f_long(2)-f_long(1));
        SST_struct(n_load).time = ncread(filename,'time');
        SST_struct(n_load).time = SST_struct(n_load).time/60/60/24 + datenum(1981,01,01);
        SST_struct(n_load).sea_surface_temperature = ncread(filename,'sea_surface_temperature', ...
                                                                    [f_long(1) f_lat(1) 1],[f_long(2)-f_long(1) f_lat(2)-f_lat(1) 1]);
        SST_struct(n_load).QC = ncread(filename,'quality_level', ...
                                                                    [f_long(1) f_lat(1) 1],[f_long(2)-f_long(1) f_lat(2)-f_lat(1) 1]);
        SST_struct(n_load).sses_bias = ncread(filename,'sses_bias', ...
                                                                    [f_long(1) f_lat(1) 1],[f_long(2)-f_long(1) f_lat(2)-f_lat(1) 1]);  
        % remove sses_bias and convert to degrees C
        SST_struct(n_load).sea_surface_temperature = SST_struct(n_load).sea_surface_temperature - 273.15 - SST_struct(n_load).sses_bias;  
    else
        disp('------------------------------------------');
        SST_struct(n_load).lat = SST_struct(n_load-1).lat;
        SST_struct(n_load).lon = SST_struct(n_load-1).lon;
        SST_struct(n_load).time = SST_struct(n_load-1).time;
        SST_struct(n_load).sea_surface_temperature = SST_struct(n_load-1).sea_surface_temperature;
        SST_struct(n_load).QC = SST_struct(n_load-1).QC;
        SST_struct(n_load).sses_bias = SST_struct(n_load-1).sses_bias;       
    end
    [SST_struct(n_load).X, SST_struct(n_load).Y] = meshgrid(SST_struct(n_load).lon,SST_struct(n_load).lat);
end
disp('Getting data.... Done.');
%% get closest SST_struct in space to transect
%=======================================================

for n_times = 1:numel(TIME)
    lo = LONG(n_times); la = LAT(n_times);
    % interpolate to get value at ship LONG and LAT
    SST_struct(n_times).ship_SST = interp2(SST_struct(n_times).X,SST_struct(n_times).Y,SST_struct(n_times).sea_surface_temperature',lo,la)
end

end