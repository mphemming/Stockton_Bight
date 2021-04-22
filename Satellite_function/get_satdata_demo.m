%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get_sat_demo.m

% This is a demo script demonstrating how to use functions get_SST,
% get_Chl, check_SST, and check_Chl. Satellite data is obtained from IMOS
% thredds - see file attributes for information about these data 
% (contained in structure variables below). 

% Script created 20/04/2021 by MPH, NSW-IMOS Sydney
% Last updated 22/04/2021 
% Email: m.hemming@unsw.edu.au
% This script was created using MATLAB version 9.8.0.1323502 (R2020a)

clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% An example month long cruise
%=====================================================
transect_times = datenum(2020,09,14):0.2:datenum(2020,10,07);
transect_lat = interp1(linspace(datenum(2020,09,14),datenum(2020,10,07),89),...
                                [-33.05:0.01:-32.97,-32.97:-0.01:-33.4,-33.4:0.01:-33.05],...
                                    transect_times,'Linear');
transect_long =  interp1(linspace(datenum(2020,09,14),datenum(2020,10,07),123),...
                                    [152:0.01:152.4,152.4:-0.01:152,152:0.01:152.4], ...
                                        transect_times,'Linear');             
%=====================================================                                   
%-------------------------------------------------------------------------------
% Replace this with your long, lat, and times (MATLAB format)
%-------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get satellite SST and Chl along transect path
%=====================================================
% IMOS products
% add the utilities folder containing important functions
addpath(genpath('Utilities'));
%=====================================================
% get satellite SST and Chl along transect
[SST_data] = get_SST(transect_long, transect_lat,transect_times,1);
[Chl_data] = get_Chl(transect_long, transect_lat,transect_times,1);
%=====================================================
%-------------------------------------------------------------------------------
% These functions use the nearest pixels to interpolate a value at the input LONG and LAT.
% It chooses satellite data available on the same day as the ship data. If
% NaN is returned there are no satellite data available at that time and space.
%
% In the data structure files created above you can find:
%
% file attributes: SST_data(n).attributes
% satellite matrix long, lat, Chl/SST
% SST closes to ship transect coordinates: SST_data(n).ship_SST/Chl
%
% Concatenate to get the along-transect satellite values (e.g. alongSST = [SST_data.ship_SST])
%
% QC flags >= 4 used only for SST data (>= 4km away from clouds)
% No QC for Chlorophyll available in netCDF file
%
%-------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check the functions to see if they work
%=====================================================
check_SST(SST_data,datenum(2020,10,03),transect_long,transect_lat)
check_Chl(Chl_data,datenum(2020,09,16),transect_long,transect_lat)
%=====================================================
%-------------------------------------------------------------------------------
% Change the dates above to double-check that the function
% works, data in the right plot should be similar to the left plot.
%-------------------------------------------------------------------------------
%=====================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot SST and Chl along transect
%=====================================================
%---------------------------------
% SST and Chl in time
%---------------------------------
figure('units','normalized','position',[0 0.05 .8 .55]);
% Chl
yyaxis left
scatter(transect_times,[Chl_data.ship_Chl],'filled');
ylabel('Chlorophyll [mg m^{-3}]')
% SST
yyaxis right
scatter(transect_times,[SST_data.ship_SST],'filled');
ylabel('SST [^\circC]');
set(gca,'LineWidth',2,'FontSize',16,'Box','On','XLim',[nanmin(transect_times)-2, nanmax(transect_times)+2]);
datetick('x','dd/mm','KeepLimits')
%=====================================================
%---------------------------------
% SST and Chl in space
%---------------------------------
% Longitude
figure('units','normalized','position',[0 0.05 .8 .55]);
% Chl
yyaxis left
scatter(transect_long,[Chl_data.ship_Chl],'filled');
ylabel('Chlorophyll [mg m^{-3}]')
% SST
yyaxis right
scatter(transect_long,[SST_data.ship_SST],'filled');
ylabel('SST [^\circC]');
set(gca,'LineWidth',2,'FontSize',16,'Box','On');
xlabel('Longitude [^\circ E]');
%=====================================================
% Latitude
figure('units','normalized','position',[0 0.05 .8 .55]);
% Chl
yyaxis left
scatter(transect_lat,[Chl_data.ship_Chl],'filled');
ylabel('Chlorophyll [mg m^{-3}]')
% SST
yyaxis right
scatter(transect_lat,[SST_data.ship_SST],'filled');
ylabel('SST [^\circC]');
set(gca,'LineWidth',2,'FontSize',16,'Box','On');
xlabel('Latitude [^\circ S]');
%=====================================================
% Chl Long and Lat
figure('units','normalized','position',[0 0.05 .4 .55]);
scatter(transect_long,transect_lat,20,'k'); hold on;
scatter(transect_long,transect_lat,20,[Chl_data.ship_Chl],'filled');
set(gca,'LineWidth',2,'FontSize',16,'Box','On');
xlabel('Latitude [^\circ E]'); ylabel('Latitude [^\circ S]');
title('Chlorophyll'); colorbar
%=====================================================
% SST Long and Lat
figure('units','normalized','position',[0.45 0.05 .4 .55]);
scatter(transect_long,transect_lat,20,'k'); hold on;
scatter(transect_long,transect_lat,20,[SST_data.ship_SST],'filled');
set(gca,'LineWidth',2,'FontSize',16,'Box','On');
xlabel('Latitude [^\circ E]'); ylabel('Latitude [^\circ S]');
title('SST'); colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%