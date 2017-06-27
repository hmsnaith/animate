% Script to plot Pro-Oceanus GTD data from MySQL table

%% Setup variables
% gtddat = struct('Date_Time',[],'tdgp',[],'time_diff',[]);
gtddat = struct('Date_Time',[],'tdgp',[]);
flds = fieldnames(gtddat);
% Set plot (variable) name
varStr = 'gtd_1';
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_gtd'];
s_str = ' and time_diff < 40000 order by Date_Time DESC';
[gtddat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);

%% Plot data
if (rows > 0) % If we have data
  % Set legend string
  legend_M = '';
  
  % Set Y limits for variables
  % varYlim = [250 400];
  varYlim = [];
  
  % If we have data - plot and print graphs
  x = {gtddat.Date_Time};
  y = {gtddat.tdgp};
  varTitle = {'Pro-Oceanus GTD sensor',...
    ['Latest data: ' datestr(gtddat.Date_Time(end))]};
  y_lab = 'TDGP mbar';
  
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
else
  % If we don't have data, create an 'empty plot' file
  empty_plot(varStr);
end
