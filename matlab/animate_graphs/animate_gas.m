% Script to plot Pro-Oceanus data from MySQL table

%% Setup variables
% prodat = struct('Date_Time',[],'pro_o_conc',[],'pro_o_cell_temp',[],...
%                 'pro_o_AZPC',[],'pro_o_raw_co2',[],'pro_o_gas_temp',[],...
%                 'pro_o_gas_humid',[],'pro_o_gas_press',[],'time_diff',[]);
prodat = struct('Date_Time',[],'pro_o_conc',[],'pro_o_gas_press',[]);
flds = fieldnames(prodat);
% Set plot (variable) name
varStr = 'pro_o_conc';
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_gas'];
s_str = ' and time_diff < 40000 order by Date_Time ASC';
[prodat, rows] = mysql_animate(db_tab,flds,pro_o_start_date,end_date,s_str);

if (rows > 0) % If we have data
  % Calculate pCO2
  pCO2 = prodat.pro_o_conc.*(prodat.pro_o_gas_press/1013.25);
  % reject data where concentration > 50
  %   qc = find((pro_o_conc>50));
  % Reject pCO2 values < 100
  pCO2(pCO2<100) = NaN;
  %% Create monthly averages
  numdate_vec = datevec(prodat.Date_Time);
  mnVar = pCO2;
  mnVname = 'pCO2_30';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);

  %% Plot data
  % Set legend string
  legend_M = {'xCO_2 (ppm)','pCO_2 (\muatm)'};
  
  % Set Y limits for variables
  varYlim = [250 400];
  
  % If we have data - plot and print graphs
  x = {prodat.Date_Time, prodat.Date_Time};
  y = {prodat.pro_o_conc, pCO2};
  varTitle = {'Pro-Oceanus data - Carbon Dioxide at 30m.',...
    ['Latest data: ' datestr(prodat.Date_Time(end))]};
  y_lab = '';
  
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
else
  % If we don't have data, create an 'empty plot' file
  empty_plot(varStr);
  
end
