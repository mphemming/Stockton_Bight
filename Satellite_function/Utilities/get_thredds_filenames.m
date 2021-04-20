function [latest_file files] = get_thredds_filenames(thredds_url,data_type)

%% get filenames 

sites_html = webread(thredds_url);    
% satellite SSH data / HF radar / glider
if ~isempty(strmatch(data_type,'satellite')) | ~isempty(strmatch(data_type,'HF')) | ~isempty(strmatch(data_type,'glider'))
    find_nc = strfind(sites_html,'.nc</tt></a></td>');
    for n_files = 1:numel(find_nc)
        if ~isempty(strmatch(data_type,'satellite'))
            files(n_files).name = sites_html(find_nc(n_files)-55:find_nc(n_files)+2);
        end
        if ~isempty(strmatch(data_type,'HF')) 
            files(n_files).name = sites_html(find_nc(n_files)-50:find_nc(n_files)+2);            
        end
        if ~isempty(strmatch(data_type,'glider')) 
            files(n_files).name = sites_html(find_nc(n_files)-79:find_nc(n_files)+2);        
        end        
    end
end
% satellite altimetry
if ~isempty(strmatch(data_type,'SSH'))
    find_nc = strfind(sites_html,'.nc.gz</tt></a></td>');
    for n_files = 1:numel(find_nc)
        files(n_files).name = sites_html(find_nc(n_files)-72:find_nc(n_files)+5);
    end    
end

%% get latest file

latest_file = files(numel(find_nc)).name;

end