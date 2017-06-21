% Script to plot isus data from MySQL table

%% Setup variables
issdat = struct('Date_Time',[],'isus_n',[],'isus_n_rms',[],'isus_average',[],...
                'isus_temp1',[],'isus_humidity',[],...
                'isus_volt',[],'isus_dark_calc',[],'time_diff',[]);
flds = fieldnames(issdat);
% Set plot (variable) name
varStr = 'isus_n';
%% Read in and Calculate Values
% Read data from MySQL database table
db_tab=[db_table '_iss'];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);

if (rows > 0)
  t_diff = -diff(issdat.Date_Time);
  gaps = [1 find(t_diff >= (1/48)) rows];
  ng = length(gaps)-1;
  
  iss_mean = NaN(1,ng);
  iss_mean_time = iss_mean;
  iss_count = iss_mean;
  
  for i=1:ng
    iss_mean(i) = mean(issdat.isus_n(gaps(i:i+1)));
    iss_mean_time(i) = mean(issdat.Date_Time(gaps(i:i+1)));
    iss_count(i) = length(gaps(i):gaps(i+1));
  end
  % end of data input
  %% Create monthly averages
  % monthly averages
  Date_Time_vec = datevec(iss_mean_time);
  mnVar = isus_mean;
  mnVname='isis_N';
  monthly_average(deploy,start_year,end_year,Date_Time_vec,mnVar,mnVname);
  
  %% Plot data
  % Set legend string
  legend_M = {'Readings','Average '};
  
  % Set Y limits for variables
  varYlim=0;
  
  % Set legend string
  varTitle = {'ISUS data - Nitrate concentration in \muMol/litre.',...
             ['Latest data: ' datestr(issdat.Date_Time(1))]};
  % Set y label string
  ylabel('\muMol_/litre');
  
  x = {issdat.Date_Time, isus_mean_time};
  y = {issdat.isus_n, isus_mean};
  
% plot and print graphs
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
else
  empty_plot(varStr)
end
