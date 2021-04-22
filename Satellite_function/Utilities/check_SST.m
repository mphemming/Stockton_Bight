function check_SST(SST_data, date,LONG,LAT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_SST.m
%
% Function that compares the output of function 'get_SST'. The complete
% satellite image on the left is compared with the interpolated values
% along the ship transect for a chosen date. The values should closely
% match.
%
% Script created 20/04/2021 by MPH, NSW-IMOS Sydney
% Last updated 22/04/2021 
% Email: m.hemming@unsw.edu.au
% This script was created using MATLAB version 9.8.0.1323502 (R2020a)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get available closest satellite pixels for given date
[yr_date,mn_date,dy_date] = datevec(date);
times = [SST_data.time];
[yr_t,mn_t,dy_t] = datevec(times);
f = find(ismember(datenum(yr_t,mn_t,dy_t),datenum(yr_date, mn_date, dy_date)));
%% check if NaN in LONG/ LAT
if isnan(LONG(f)) | isnan(LAT(f))
    msg = 'Selected LONG, LAT, or both contain an NaN. Check aborted for this date.';
    error(msg)
end
%% create figure comparison
figure('units','normalized','position',[0 0.05 .8 .85]);
%---------------------------------------------------------------------------------------------------
% complete satellite image
subplot(1,2,1)
imagesc(SST_data(f(1)).X(:),SST_data(f(1)).Y(:),SST_data(f(1)).sea_surface_temperature')
hold on
scatter(LONG,LAT,'k');
scatter(LONG(f),LAT(f),'r');
set(gca,'YDir','Normal','LineWidth',2,'FontSize',16);
xlabel('Longitude [^\circ E]')
ylabel('Latitude [^\circ S]')
colorbar; 
if sum(isfinite(SST_data(f(1)).sea_surface_temperature(:))) > 20
    caxis([round(nanmin(SST_data(f(1)).sea_surface_temperature(:)))+0.5, ...
        round(nanmax(SST_data(f(1)).sea_surface_temperature(:)))-0.5]);
end
xlim([round(nanmin(LONG),2)-0.25, ...
    round(nanmax(LONG),2)+0.25]);
ylim([round(nanmin(LAT),2)-0.25, ...
    round(nanmax(LAT),2)+0.25]);
title('SST [^\circC]')
%---------------------------------------------------------------------------------------------------
% grabbed pixels
subplot(1,2,2)
scatter(LONG,LAT,'k'); hold on;
scatter(LONG(f),LAT(f),20,[SST_data(f).ship_SST],'filled');
xlim([round(nanmin(LONG),2)-0.25, ...
    round(nanmax(LONG),2)+0.25]);
ylim([round(nanmin(LAT),2)-0.25, ...
    round(nanmax(LAT),2)+0.25]);
colorbar; 
if sum(isfinite(SST_data(f(1)).sea_surface_temperature(:))) > 20
    caxis([round(nanmin(SST_data(f(1)).sea_surface_temperature(:)))+0.5, ...
        round(nanmax(SST_data(f(1)).sea_surface_temperature(:)))-0.5]);
end
set(gca,'LineWidth',2,'FontSize',16,'Box','On');
title(datestr(date))
xlabel('Longitude [^\circ E]')
ylabel('Latitude [^\circ S]')
%---------------------------------------------------------------------------------------------------
end