% Script to plot Pro-Oceanus data from MySQL table

%% Setup variables
% proOdat = struct('Date_Time',[],'pro_o_conc',[],'pro_o_cell_temp',[],...
%                 'pro_o_AZPC',[],'pro_o_raw_co2',[],'pro_o_gas_temp',[],...
%                 'pro_o_gas_humid',[],'pro_o_gas_press',[],'time_diff',[]);
proOdat = struct('Date_Time',[],'pro_o_conc',[],'pro_o_gas_press',[],...
                 'pro_o_cell_temp',[]);
flds = fieldnames(proOdat);
% Set plot (variable) name
varStr = 'pro_o_conc';
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_gas'];
s_str = ' and time_diff < 40000 order by Date_Time ASC';
[proOdat, rows] = mysql_animate(db_tab,flds,pro_o_start_date,end_date,s_str);

if (rows > 0) % If we have data
  % Calculate pCO2
  proOdat.pCO2 = proOdat.pro_o_conc.*(proOdat.pro_o_gas_press/1013.25);
  flds = fieldnames(proOdat);
  % Reject data with out of bounds concentrations or cell temperature
  qc = find(proOdat.pro_o_conc<=100 |  proOdat.pro_o_cell_temp<40);
  % Set rejected data to NaN
  for j=2:length(flds)
    fld = flds{j};
    proKdat.(fld)(qc) = NaN;
  end
  % Reject pCO2 values < 100
  proOdat.pCO2(proOdat.pCO2<100) = NaN;
  %% Create monthly averages
  numdate_vec = datevec(proOdat.Date_Time);
  mnVar = proOdat.pCO2;
  mnVname = 'pCO2_30';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);

  %% Plot data
  % Set legend string
  legend_M = {'xCO_2 (ppm)','pCO_2 (\muatm)'};
  % Set marker type
  M = '.';
  % Set Y limits for variables
  varYlim = [250 400];
  
  % If we have data - plot and print graphs
  x = {proOdat.Date_Time, proOdat.Date_Time};
  y = {proOdat.pro_o_conc, proOdat.pCO2};
  varTitle = {'Pro-Oceanus data - Carbon Dioxide at 30m.',...
    ['Latest data: ' datestr(proOdat.Date_Time(end))]};
  y_lab = '';
  
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y,M);
else
  % If we don't have data, create an 'empty plot' file
  empty_plot(varStr);
  
end
