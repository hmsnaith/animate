% function process_nrt()
% Script to process NRT data from NOC moorings

%% Set Up for current deployment - consider moving to seperate config file
global webdir x_lab

%% Deployment Info
%webdir = '/noc/users/animate/img/pap_2017_apr/';
webdir='/noc/itg/www/apps/pap/pap_2017_apr/';
% webdir2='/data/ncs/www/eurosites/pap/pap_2017_apr/';

deploy='201704';
db_table=['PAP' deploy];
% site='PAP';
dep_name='April 2017'; % Used for graph title
x_lab='Date (2017-2018)'; % graph x axis label

start_date='2017-04-20 12:30:00';
pro_o_start_date=start_date;
% pro_o_K_start_date='2017-04-20 12:30:00';
% startdt=datenum(start_date,'yyyy-mm-dd HH:MM:SS');
end_date='2024-12-29 03:00:00';
 
% position from Paul to within 50m 48.99320 N, 16.36947 W.
% from guessing when ship is in close proximity  49.01285 -16.3749
anchor_lon = -16.31896;
anchor_lat = 49.02946;

% to exclude NOC and 0,0 when sent in error by gps
site_lat_lims = [45 50];
site_lon_lims = [-20 -10];

%% Instrument and calibration Data 
% %from pre-deployment readings
% P_corr(1)=0;
% P_corr(2)=0;
% P_corr(3)=0;
% P_corr(4)=0;

% Parameters needed for SBO processing
sbo_nv=3;
sbo=[1,9030; 30,10535; 30,13397];     % amended to be serial numbers for current deployment
sbo_press_corr=[0, 0, 0];
sboYlim=[5 7]; % Used to set Y Limits on sbo graphs
  
% sbe=[30, 6915]; % amended to be serial numbers for current deployment

% Parameters needed for FET processing
fet_nv=2;
fet=[1, 257;30, 63];			% amended to be serial numbers for current deployment
fetYlim=[7.5 8.5];			% used to set Y limits on fet graphs

% Parameters for OC processing
oc_var = 2;

% Parameters for Aanderaa 4430H Seaguard Oxygen processing
Aa_ox_slope=0.9662; %201407 from Jon email 14:29
Aa_ox_offset=-24.992;
% 
% chlYlim=[0.0, 2.0];
% 
% % from regression  against CTD in calibration dip
% %cyclops_slope=0.1795; % 201407
% %cyclops_intercept=0.0663;
% cyclops_slope=0.1737; % 201507
% cyclops_intercept=0.0115;
% 
% %Wetlabs
% cwo=48;
% Fl_scale=0.0071;  % sn 3050 2015 but already applied to data in db table
% cwo=0;
% Fl_scale=1;  % sn 3050 2015
% 
% cwo=0;
% Fl_scale=1;
% 
% % from regression  against CTD in calibration dip
% chl_slope=0.3425;
% chl_intercept=0.0911;  %wetlabs 20150815
% 
% Fl_ref_constant=690;
% 
% wetlabs FLNTUSB-270 calibration factors
%cwo=55;
%Fl_scale=0.0121;
%therm_intercept=71.7890;
%therm_slope=-0.0056;
%press_intercept=-21.35;
%press_slope=0.0059;
%ntu_intercept=-21.35;
%ntu_slope=0.0059;

% wetlabs FLNTUSB-269 calibration factors
%cwo=51;
%Fl_scale=0.0125;
%therm_intercept=72.1069;
%therm_slope=-0.0056;
%press_intercept=-18.00;
%press_slope=0.059;
%ntu_cwo=-72;
%ntu_scale=0.0063;

% wetlabs FLNTUSB-238 calibration factors
%cwo=53;
%Fl_scale=0.0123;
%therm_offset=73.4101;
%therm_scale=-0.00579;
%press_offset=-18.00;
%press_scale=0.06;
%ntu_cwo=-101;
%ntu_scale=0.0064;

%% Derived parameters needed for processing 
% for monthly averages
start_date_vec=datevec(start_date);
% start_mon=start_date_vec(2);
start_year=start_date_vec(1);
end_year=start_year+1;

%% Read, QC and plot data
% % Add paths for necessary functions
%addpath('/noc/packages/satprogs/satmat/mysql');
addpath('/noc/users/animate/animate/matlab/mysql');
addpath '/noc/users/animate/animate/matlab/animate';
% addpath '/noc/users/animate/matlab/seawater';

% Plot position info first - from gps and met sources
animate_lat_lon(db_table, '_gps', '', {start_date end_date}, {'Latitude','Longitude'},...
  [site_lat_lims site_lon_lims], [anchor_lat anchor_lon]);

animate_lat_lon(db_table, '_met', '_met', {start_date end_date}, {'Lat','Lon'},...
  [site_lat_lims site_lon_lims], [anchor_lat anchor_lon]);

% Met data 
animate_met_iridium;

% SeaBird microcat data
animate_sbo;
% animate_data; % (_sbe files) microcats - Not 2017
% animate_iss; % (_iss files) Not 2017

% SeaFET pH data
animate_fet;
animate_fetcorr;
% SP101 Melchor Gonzalez pH
% animate_ph1; % No data post deployment 2017

% Aanderaa 4430H Seaguard Oxygen
animate_sea;
 
% ProcOceanus CO2
animate_gas; 
animate_co2;

% Pro-Oceanus Gas Tension sensor
animate_gtd;

% Satlantic SUNA V2
animate_sun;

% WETLabs Cycle Phosphate sensor
% animate_po4; % No data post deployment 2017

% Nitrate - Not 2017
%animate_nax; % _nax database tables
%NO3_offset=0.25;  % to remove negative values 20110919%
%file_in_NO3='/noc/ote/autonomous/REMOTETEL/ascdata/buoy8/concat/PAP_Apr_2013.NO3'
%animate_NO3; % _nax database tables - functionality now included in nax???? reverted 30sep2010 until rewrite read

% WETLabs FLNTUSB Fluorometer
animate_wetlabs;

% Todaynum=datenum(now);
% Depths=    [30 30 30];
% 
% nvar=1;
% nvar2=nvar+2;
% 
% animate_ncep;
% comp_title='Sea Surface temperature from UK Met.Office';
% comp_legend='Surface Temp';
% if (exist('metnumdate')>0)
% comp_date=metnumdate;
% end
% if (exist('sea_temp')>0)
% comp_temp=sea_temp;
% end
% animate_ncep_temp_comp;

% Irradiance 
animate_oc;




% Engineering, Iridium and Hub Status info
% animate_engineering; (_mon files) Not 2017
animate_ST1; % Telemetry Motion Control
animate_ird;
animate_hub;

% Buoy attitude data
% animate_cmp; % Not 2017
% animate_ez3; % Not 2017
% Hub attitude data 
animate_att;
animate_btt;

% Housing power data
animate_pwr;

