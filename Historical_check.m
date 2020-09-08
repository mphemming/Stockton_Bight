

%% Load in data

 addpath(genpath('C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight'))
 addpath(genpath('C:\Users\mphem\Documents\Work\UNSW\climatology\Revamped_scripts\Climatology\'))
 files = dir('C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Data\*.nc');
 
 if exist('Data\SB_data.mat','file') == 0
 
 for n_file = 1:numel(files)
     disp(files(n_file).name);
     d = get_mooring(files(n_file).name,1);
     data(n_file).LONG = d.LONGITUDE;
     data(n_file).LONG_QC = d.LONGITUDE_quality_control;
     data(n_file).LAT = d.LATITUDE;
     data(n_file).LAT_QC = d.LATITUDE_quality_control;     
     data(n_file).TIME = d.TIME;
     data(n_file).TIME_QC = d.TIME_quality_control;          
 end
    save('Data\SB_data.mat','data')
 else
    load('Data\SB_data.mat','data')
 end
 % concatenate data
 QC = vertcat(data.LONG_QC);
 LONG = vertcat(data.LONG);
 LONG(QC == 9 | QC == 0 | isnan(LONG)) = NaN;
 QC = vertcat(data.LAT_QC);
 LAT = vertcat(data.LAT); 
 LAT(QC == 9 | QC == 0 | isnan(LAT)) = NaN;
 QC = vertcat(data.TIME_QC);
 TIME = vertcat(data.TIME); 
 TIME(QC == 4 | isnan(TIME)) = NaN;
 
 % bathymetry data
 
 bathymetry = load('C:\Users\mphem\Documents\Work\UNSW\BATHYMETRY\bathy_eac_etopo1');
 
 bathy = double(bathymetry.bathy);
 bathy = bathy(700:860,360:520);
 lon = bathymetry.lon(360:520);
 lat = bathymetry.lat(700:860);
 [X Y] = meshgrid(lon,lat);

 % get latest SST
 
%  filename = ['http://thredds.aodn.org.au/thredds/dodsC/IMOS/SRS/SST/ghrsst/L3SM-1d/ngt/2020/', ...
%      '20200903152000-ABOM-L3S_GHRSST-SSTskin-MultiSensor-1d_night.nc'];
%  SST.lat = ncread(filename,'lat');
%  SST.lon = ncread(filename,'lon'); 
%  SST.SST = ncread(filename,'sea_surface_temperature');  
 
SST = get_mooring('C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Data\SST.nc',0);
[SST.X,SST.Y] = meshgrid(SST.lon,SST.lat);
 
 % radar data
 radar = get_mooring('C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Data\radar.nc',1);
 VCUR = nanmean(radar.VCUR,3);
 LONGr = radar.LONGITUDE;
 LATr = radar.LATITUDE; 
 LONGr(isnan(VCUR)) = [];
 LATr(isnan(VCUR)) = [];
 
 %% get checks
 [yrs,mns,dys,~,~,~] = datevec(TIME);
 check_Nov = mns == 11 & LONG >= 151 & LONG <= 153.5 & LAT >= -34.5 & LAT <= -31.5;
 check_week = datenum(0,mns,dys) >= 306 & datenum(0,mns,dys) <=313 & LONG >= 151 & LONG <= 153.5 & LAT >= -34.5 & LAT <= -31.5;
 
 %% create plots
 
 %% November glider missions
 un_years = unique(yrs(check_Nov));
 
  figure('units','normalized','position',[0 0.05 .55 .8]);
  
  cm = colormap(cbrewer('div','RdYlBu', numel(un_years)));
  xlim([151 153.4]);
  ylim([-34.4 -31.6]);
  plot_google_map('MapType','satellite');
  hold on;
  contourf(SST.X,SST.Y,nanmean(SST.sea_surface_temperature-273.15,3)',1000,'LineStyle','None');
  caxis([20 23]);
  cmocean('thermal');
  cb = colorbar;
  ylabel(cb,'SST recent 7 day Average');

  scatter(LONGr,LATr,'o','k')
  s1 = scatter(LONGr,LATr,'*','w')  
  [C,h] = contour(X,Y,bathy*-1,[50 125 200 1000],'k');
  clabel(C,h)
  xlim([151 153.4]);
  ylim([-34.3 -31.7]); 
  title('Glider Missions in November')
  beautify_axes
  xlabel('Longitude [^\circ E]');
  ylabel('Latitude [^\circ S]');
  leg1 = legend(s1,'Radar');
  set(leg1,'Location','SouthEast','Box','Off');
  
  pos_ax = get(gca,'Position');
  axes('position',pos_ax);
  
  clear s s_yrs
  for n = 1:numel(un_years)
      check_yrs = yrs == un_years(n);
      scatter(LONG(check_Nov & check_yrs),LAT(check_Nov & check_yrs),15,'k','filled');
      hold on
      s(n) = scatter(LONG(check_Nov & check_yrs),LAT(check_Nov & check_yrs),5,'MarkerFaceColor',cm(n,:),'MarkerEdgeColor',cm(n,:));
      xlim([nanmin(lon) nanmax(lon)]); ylim([nanmin(lat) nanmax(lat)]);
      s_yrs(n).str = num2str(un_years(n));
  end
 
  set(gca,'Visible','Off','Position',pos_ax);  
  xlim([151 153.4]);
  ylim([-34.3 -31.7]);  
  
  leg = legend(s,vertcat(s_yrs.str))
  set(leg,'Location','NorthWest','Box','On');

  
  print(gcf,'-dpng','-r400',['C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Plots\Glider_missions_Nov_SB.png']);
%   saveas(gcf,'C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Plots\Glider_missions_Nov_SB.fig');

 
 %% November first week glider missions
 un_years = unique(yrs(check_week));
 
  figure('units','normalized','position',[0 0.05 .55 .8]);
  
  xlim([151 153.4]);
  ylim([-34.4 -31.6]);
  plot_google_map('MapType','satellite');
  hold on;
  contourf(SST.X,SST.Y,nanmean(SST.sea_surface_temperature-273.15,3)',1000,'LineStyle','None');
  caxis([20 23]);
  cmocean('thermal');
  cb = colorbar;
  ylabel(cb,'SST recent 7 day Average');

  scatter(LONGr,LATr,'o','k')
  s1 = scatter(LONGr,LATr,'*','w')  
  [C,h] = contour(X,Y,bathy*-1,[50 125 200 1000],'k');
  clabel(C,h)
  xlim([151 153.4]);
  ylim([-34.3 -31.7]); 
  title('Glider Missions: First week in November')
  beautify_axes
  xlabel('Longitude [^\circ E]');
  ylabel('Latitude [^\circ S]');
  leg1 = legend(s1,'Radar');
  set(leg1,'Location','SouthEast','Box','Off');
  
  pos_ax = get(gca,'Position');
  axes('position',pos_ax);
  
  clear s s_yrs
  for n = 1:numel(un_years)
      check_yrs = yrs == un_years(n);
      scatter(LONG(check_week & check_yrs),LAT(check_week & check_yrs),15,'k','filled');
      hold on
      s(n) = scatter(LONG(check_week & check_yrs),LAT(check_week & check_yrs),5,'MarkerFaceColor',cm(n,:),'MarkerEdgeColor',cm(n,:));
      xlim([nanmin(lon) nanmax(lon)]); ylim([nanmin(lat) nanmax(lat)]);
      s_yrs(n).str = num2str(un_years(n));
  end
 
  set(gca,'Visible','Off','Position',pos_ax);  
  xlim([151 153.4]);
  ylim([-34.3 -31.7]);  
  
  leg = legend(s,vertcat(s_yrs.str))
  set(leg,'Location','NorthWest','Box','On');

  
  print(gcf,'-dpng','-r400',['C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Plots\Glider_missions_Nov_first_week_SB.png']);
%   saveas(gcf,'C:\Users\mphem\Documents\Work\UNSW\glider\Stockton_Bight\Plots\Glider_missions_Nov_SB.fig');

 
 
