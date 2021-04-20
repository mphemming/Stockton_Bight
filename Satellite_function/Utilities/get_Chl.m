function [Chl_struct] = get_Chl(LONG,LAT,TIME)

%% get Chl filenames
%=======================================================
%-------------------------------------------------------------------------
disp('Getting filenames....');
% determine year and month of transect
[yr,mn,dy] = datevec(TIME); yr = unique(yr); 
m = unique(mn);
if numel(num2str(m)) <= 2
    m = num2str(m);
end
if numel(m) < 2
    m = ['0',num2str(m)];
end
%-------------------------------------------------------------------------
% get list of available filenames for download
if numel(num2str(m)) == 2
    thredds_url = ['http://thredds.aodn.org.au/thredds/catalog/IMOS/SRS/OC/gridded/aqua/P1D/',num2str(yr),'/',m,'/catalog.html'];
    sites_html = webread(thredds_url);    
    find_nc = strfind(sites_html,'.nc</tt></a></td>');
    for n_files = 1:numel(find_nc)
        files(n_files).name = sites_html(find_nc(n_files)-35:find_nc(n_files)+2);
        % only include OC3 files
        if isempty(strfind(files(n_files).name,'chl_oc3'))
            files(n_files).name = [];
        end
    end
    files = vertcat(files.name);
else
    m_1 = m(1); m_2 = m(2);
    if numel(num2str(m_1)) < 2
        m_1 = ['0',num2str(m_1)];
    end
    if numel(num2str(m_2)) < 2
        m_2 = ['0',num2str(m_2)];
    else
        m_2 = num2str(m_2);
    end
    thredds_url.url_1 = ['http://thredds.aodn.org.au/thredds/catalog/IMOS/SRS/OC/gridded/aqua/P1D/', ...
                                num2str(yr),'/',m_1,'/catalog.html'];              
    thredds_url.url_2 = ['http://thredds.aodn.org.au/thredds/catalog/IMOS/SRS/OC/gridded/aqua/P1D/', ...
                                num2str(yr),'/',m_2,'/catalog.html'];               
    sites_html_1 = webread(thredds_url.url_1);      
    sites_html_2 = webread(thredds_url.url_2);     
    find_nc_1 = strfind(sites_html_1,'.nc</tt></a></td>');    
    find_nc_2 = strfind(sites_html_2,'.nc</tt></a></td>'); 
    for n_files = 1:numel(find_nc_1)
        files(n_files).name_1 = sites_html_1(find_nc_1(n_files)-35:find_nc_1(n_files)+2);
        % only include OC3 files
        if isempty(strfind(files(n_files).name_1,'chl_oc3'))
            files(n_files).name_1 = [];
        end
    end
    files_1 = vertcat(files.name_1);   
    for n_files = 1:numel(find_nc_2)
        files(n_files).name_2 = sites_html_2(find_nc_2(n_files)-35:find_nc_2(n_files)+2);
        % only include OC3 files
        if isempty(strfind(files(n_files).name_2,'chl_oc3'))
            files(n_files).name_2 = [];
        end
    end
    files_2 = vertcat(files.name_2);       
end
%-------------------------------------------------------------------------
% determine those files closest to each ship transect time
TIME_web_format = datestr(TIME,'yyyymmdd');
for n_times = 1:numel(TIME)
    t_check = TIME_web_format(n_times,:);
    % get files closest in time
    for n_files = 1:size(files,1)
        if ~isempty(strmatch(t_check,files(n_files,7:14)))
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

filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/OC/gridded/aqua/P1D/',num2str(yr),'/',m,'/',num2str(chosen_files(1))]
lat = ncread(filename,'latitude');
lon = ncread(filename,'longitude');
f_lat = [nanmin(find(abs(lat-nanmin(LAT)) == nanmin(abs(lat-nanmin(LAT)))))-40, ...
            nanmax(find(abs(lat-nanmax(LAT)) == nanmin(abs(lat-nanmax(LAT)))))+40];
f_long = [nanmin(find(abs(lon-nanmin(LONG)) == nanmin(abs(lon-nanmin(LONG)))))-40, ...
            nanmax(find(abs(lon-nanmax(LONG)) == nanmin(abs(lon-nanmax(LONG)))))+40];
        
clear filename lat lon
%% get Chl data
%=======================================================
disp('Getting data....');
% download data sets
previous_filename = '';
for n_load = 1:numel(chosen_files)
    if exist('filename','var')
        previous_filename = filename;
    end
    filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/OC/gridded/aqua/P1D/',num2str(yr),'/',m,'/',num2str(chosen_files(n_load))];
    % get data
    if isempty(strmatch(filename,previous_filename))
        disp(filename)    
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
disp('Getting data.... Done.');
%% get closest Chl_struct in space to transect
%=======================================================

for n_times = 1:numel(TIME)
    lo = LONG(n_times); la = LAT(n_times);
    % interpolate to get value at ship LONG and LAT
    Chl_struct(n_times).ship_Chl = interp2(Chl_struct(n_times).X,Chl_struct(n_times).Y,Chl_struct(n_times).Chl',lo,la)
end

end