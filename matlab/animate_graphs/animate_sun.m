% Script to plot SUNA Nitrate sensor data from MySQL table

%% Setup variables
sundat = struct('Date_Time',[],'n_mM',[],'n_mg_l',[],'time_diff',[]);
flds = fieldnames(sundat);
% Set plot (variable) name
varStr = 'sun_1';
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_sun'];
s_str = ' and time_diff < 40000 order by Date_Time DESC';
[sundat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);

if (rows > 0) % If we have data
  %% Create monthly averages
  numdate_vec = datevec(sundat.Date_Time);
  mnVar = sundat.n_mM;
  mnVname = 'SUNA_N_mM_30';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
%% Plot data
  % Set legend string
  legend_M = '';
  
  % Set Y limits for variables
  varYlim = [250 400];
  
  % If we have data - plot and print graphs
  x = {sundat.Date_Time};
  y = {sundat.n_mM};
  varTitle = {'SUNA Nitrate sensor',...
    ['Latest data: ' datestr(sundat.Date_Time(end))]};
  y_lab = 'Nitrate mM';
  
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
else
  % If we don't have data, create an 'empty plot' file
  empty_plot(varStr);
end
