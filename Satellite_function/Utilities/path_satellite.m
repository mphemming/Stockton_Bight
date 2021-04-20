function [close_LONG, close_LAT, close_DATA] = path_satellite(LONG,LAT,SAT_LONG,SAT_LAT,SAT_DATA,R)

%% for each LONG and LAT find closest satellite pixel

for n = 1:numel(LONG)
    lo = LONG(n); la = LAT(n);
    % get closest pixels
    c = (SAT_LONG > lo-R & SAT_LONG <= lo+R) & ...
            (SAT_LAT > la-R & SAT_LAT <= la+R);
    % get median vals
    close_LONG(n) = nanmedian(SAT_LONG(c));
    close_LAT(n) = nanmedian(SAT_LAT(c));
    close_DATA(n) = nanmedian(SAT_DATA(c));  
end

end