%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get_sat_demo.m

% This script demonstrates how to grab satellite data along the path of a
% transect using functions .............................................

% Script created 20/04/2021 by MPH, NSW-IMOS Sydney
% Email: m.hemming@unsw.edu.au
% This script was created using MATLAB version 9.8.0.1323502 (R2020a)

%% An example month long cruise

transect_times = datenum(2020,09,14):0.2:datenum(2020,10,07)
transect_lat = interp1(1:89,[-33.05:0.01:-32.97,-32.97:-0.01:-33.4,-33.4:0.01:-33.05],1:numel(transect_times),'Linear');
transect_long =  interp1(1:123,[152:0.01:152.4,152.4:-0.01:152,152:0.01:152.4],1:numel(transect_times),'Linear');

%% Get satellite SST and Chl along transect path
% IMOS products

addpath(genpath('Utilities'));

[SST_data] = get_SST(transect_long, transect_lat,transect_times);
[Chl_data] = get_Chl(transect_long, transect_lat,transect_times);




