function [Chl_struct] = get_Chl(LONG,LAT,TIME,interp_option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% get_Chl.m
%
% Function that gets the interpolated Chl along a ship transect using the
% nearest pixels in space. Interpolated Chl are retrieved from data on the
% same date as input transect times (TIME).
%
% Script created 20/04/2021 by MPH, NSW-IMOS Sydney
% Last updated 22/04/2021 
% Email: m.hemming@unsw.edu.au
% This script was created using MATLAB version 9.8.0.1323502 (R2020a)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get Chl filenames
%=======================================================
%-------------------------------------------------------------------------
disp('Getting filenames....');
% determine year/s and month/s of transect
[yr,mn,dy] = datevec(TIME);
%-------------------------------------------------------------------------
%=======================================================
% get list of available filenames for download
for n_times = 1:numel(yr)
    % Add the '0' at the start if month < 10, convert to string
    if numel(num2str(mn(n_times))) < 2
        mn_str = ['0',num2str(mn(n_times))];
    else
        mn_str = num2str(mn(n_times));
    end
    % get available filenames
    thredds_url = ['http://thredds.aodn.org.au/thredds/catalog/IMOS/SRS/OC/gridded/aqua/P1D/',...
        num2str(yr(n_times)),'/',mn_str,'/catalog.html'];    
    sites_html = webread(thredds_url);    
    find_nc = strfind(sites_html,'.nc</tt></a></td>');
    for n_files = 1:numel(find_nc)
        fi(n_files).name = convertCharsToStrings(sites_html(find_nc(n_files)-35:find_nc(n_files)+2));
        % only include OC3 files
        if isempty(strfind(fi(n_files).name,'chl_oc3'))
            fi(n_files).name = [];
        end
    end
    files(n_times).files = vertcat(fi.name);
end
files = unique(vertcat(files.files));
%=======================================================
%-------------------------------------------------------------------------
% determine those files closest to each ship transect time
TIME_web_format = datestr(TIME,'yyyymmdd');
for n_times = 1:numel(TIME)
    t_check = TIME_web_format(n_times,:);
    % get files closest in time
    for n_files = 1:size(files,1)
        f_date = convertStringsToChars(files(n_files));
        f_date = f_date(7:14);
        if ~isempty(strmatch(t_check,f_date))
            f = n_files;
        end
    end
    chosen_files(n_times) = convertCharsToStrings(files(f,:));
end
%=======================================================
clear f n_times TIME_web_format n_files
disp('Getting filenames.... Done.');
%-------------------------------------------------------------------------
%% Determine data approximate area for reducing loading time
%=======================================================
% Using first filename to get approximate area of interest, to save time
% downloading large data sets in the next section
month = convertStringsToChars(chosen_files(1)); month = month(11:12);
filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/OC/gridded/aqua/P1D/',...
    num2str(unique(yr)),'/',month,'/',num2str(chosen_files(1))];
lat = ncread(filename,'latitude');
lon = ncread(filename,'longitude');
f_lat = [nanmin(find(abs(lat-nanmin(LAT)) == nanmin(abs(lat-nanmin(LAT)))))-80, ...
            nanmax(find(abs(lat-nanmax(LAT)) == nanmin(abs(lat-nanmax(LAT)))))+80];
f_long = [nanmin(find(abs(lon-nanmin(LONG)) == nanmin(abs(lon-nanmin(LONG)))))-80, ...
            nanmax(find(abs(lon-nanmax(LONG)) == nanmin(abs(lon-nanmax(LONG)))))+80];
%=======================================================
clear filename lat lon
%% get Chl data
%=======================================================
disp('Getting data....');
% download data sets
previous_filename = '';
%=======================================================
for n_load = 1:numel(chosen_files)
    if exist('filename','var')
        previous_filename = filename;
    end
    month = convertStringsToChars(chosen_files(n_load)); month = month(11:12);
    filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/OC/gridded/aqua/P1D/',...
        num2str(unique(yr)),'/',month,'/',num2str(chosen_files(n_load))];
    % get data
    if isempty(strmatch(filename,previous_filename))
        disp(filename)    
        Chl_struct(n_load).attributes = ncinfo(filename);
        Chl_struct(n_load).lat = ncread(filename,'latitude',f_lat(1),f_lat(2)-f_lat(1));
        Chl_struct(n_load).lon = ncread(filename,'longitude',f_long(1),f_long(2)-f_long(1));
        Chl_struct(n_load).time = ncread(filename,'time');
        Chl_struct(n_load).time = Chl_struct(n_load).time + datenum(1990,01,01);
        Chl_struct(n_load).Chl = ncread(filename,'chl_oc3', ...
                                                      [f_long(1) f_lat(1) 1],[f_long(2)-f_long(1) f_lat(2)-f_lat(1) 1]);
    else
        disp('------------------------------------------');
        Chl_struct(n_load).lat = Chl_struct(n_load-1).lat;
        Chl_struct(n_load).lon = Chl_struct(n_load-1).lon;
        Chl_struct(n_load).time = Chl_struct(n_load-1).time;
        Chl_struct(n_load).Chl = Chl_struct(n_load-1).Chl;    
    end
    [Chl_struct(n_load).X, Chl_struct(n_load).Y] = meshgrid(Chl_struct(n_load).lon,Chl_struct(n_load).lat);
end
%=======================================================
disp('Getting data.... Done.');
%% get closest Chl_struct in space to transect
%=======================================================
for n_times = 1:numel(TIME)
    lo = LONG(n_times); la = LAT(n_times);
    % If user wants to inteprolate around ship long/lat point if few missing data
    if interp_option == 1    
        % if most of the surrounding area is covered, interpolate to fill the gaps
        f_lon = find(Chl_struct(n_times).lon >= round(lo,1)-0.1 & Chl_struct(n_times).lon <= round(lo,1)+0.1);
        f_lat = find(Chl_struct(n_times).lat >= round(la,1)-0.1 & Chl_struct(n_times).lat <= round(la,1)+0.1);
        patch = Chl_struct(n_times).Chl(f_lon,f_lat);
        % if < 20% NaNs in patch area, gap fill using linear interpolation
        if sum(isnan(patch(:)))/numel(patch(:))*100 < 20 & sum(isnan(patch(:)))/numel(patch(:))*100 ~= 0
            patch = inpaint_nans(patch,0);
            Chl_struct(n_times).Chl(f_lon,f_lat) = patch;
        end
    end
    % interpolate to get value at ship LONG and LAT
    Chl_struct(n_times).ship_Chl = interp2(Chl_struct(n_times).X,Chl_struct(n_times).Y,Chl_struct(n_times).Chl',lo,la);
end
%=======================================================
end