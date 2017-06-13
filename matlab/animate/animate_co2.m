% Script to plot CO2 data from MySQL table
%% Setup variables
proKdat = struct('Date_Time',[],...
  'pro_o_K_seconds',[],'pro_o_K_conc',[],'pro_o_K_cell_temp',[],...
  'pro_o_K_AZPC',[],'pro_o_K_raw_co2',[],'pro_o_K_gas_temp',[],...
  'pro_o_K_gas_humid',[],'pro_o_K_gas_press',[],'pCO2',[]);
flds = fieldnames(proKdat);
param = struct('pro_o_K_seconds',[],'pro_o_K_conc','xCO_2 (ppm)','pro_o_K_cell_temp',[],...
  'pro_o_K_AZPC','eng, units','pro_o_K_raw_co2','eng, units','pro_o_K_gas_temp',[],...
  'pro_o_K_gas_humid',[],'pro_o_K_gas_press','Pressure (mb)','pCO2','pCO_2 (\muatm)');

plt = struct('keel_pro_o_K_conc',[],...
             'keel_pro_o_K_raw_co2',[],...
             'keel_pro_o_K_AZPC',[],...
             'keel_pro_o_K_gas',[],...
             'keel_pro_o_K_cell_temp',[]);
plt.keel_pro_o_K_conc={'pro_o_K_conc', 'pCO2'};
plt.pro_o_K_raw_co2={'pro_o_K_raw_co2'};
plt.keel_pro_o_K_AZPC={'pro_o_K_AZPC'};
plt.keel_pro_o_K_gas={'pro_o_K_gas_temp','pro_o_K_gas_humid','pro_o_K_gas_press'};
plt.keel_pro_o_K_cell_temp={'pro_o_K_cell_temp'};

pltTitle = {'Pro-Oceanus data - Carbon Dioxide at 1m',...
            'Pro-Oceanus data - Raw sensor CO2',...
            'Pro-Oceanus data - AZPC from sensor',...
            'Pro-Oceanus Gas Temperature, Humity and Pressure',...
            'Pro-Oceanus Cell Temperature'};
pltUnits = {'Concentration',...
            'Raw Engineering CO2',...
            'Raw Engineering AZPC',...
           {'Temperature (\circC)','Humidity','Pressure'},...
            'Temperature (\circC)'};
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_co2'];
s_str = ' order by Date_Time ASC';
[DATA, rows] = mysql_animate(db_tab,flds(1:end-1),pro_o_start_date,end_date,s_str);

if (rows > 0)
  % transfer remaining data into data structure
  for j=1:length(flds)-1
    fld = flds{j};
    % Copy measurements into structure
    proKdat.(fld) = DATA.(fld);
  end
  
  % Calculate pCO2
  proKdat.pCO2 = proKdat.pro_o_K_conc.*(proKdat.pro_o_K_gas_press/1013.25);
  % Reject values less than 10
  proKdat.pCO2(proKdat.pCO2 < 10) = NaN;
%   qc = find(proKdat.pro_o_K_conc>0 & proKdat.pro_o_K_gas_press<1100 &...
%             proKdat.pro_o_K_seconds<122 & proKdat.pro_o_K_cell_temp<50);
  qc = find(proKdat.pro_o_K_conc<=0 | proKdat.pro_o_K_gas_press>1100 |...
            proKdat.pro_o_K_seconds>122 | proKdat.pro_o_K_cell_temp>50);
  for j=1:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    proKdat.(fld)(qc) = NaN;
  end
  %% Create monthly averages
  numdate_vec = datevec(proKdat.Date_Time);
  mnVar = proKdat.pCO2(qc);
  mnVname = 'pCO2_1';
  monthly_average(deploy,start_year,end_year,numdate_vec(qc,:),mnVar,mnVname);
end
%% Plot data
pflds = fieldnames(plt);
for m=1:length(pflds)
  % Set plot (variable) name
  varStr = pflds{m};
  if rows>0
    % Set Y axis label
    y_lab = pltUnits{m};
    % Assume no y scaling
    varYlim = [];
    % Set title
    varTitle = {pltTitle{m}, ...
                ['Latest data: ' datestr(seadat.Date_Time(end))]};
    % Set fields to plot
    fpl = plt.(varStr);
    % Set plot type, Y Limits
    switch varStr
      case {'keel_pro_o_K_conc'}
        pt = 1; varYlim = [250 400];
      case {'keel_pro_o_K_raw_co2','keel_pro_o_K_AZPC','keel_pro_o_K_cell_temp'}
        pt = 1;
      case {'keel_pro_o_K_pressure'}
        pt = 1; varYlim = [1000,1060];
      case 'keel_pro_o_K_gas'
        pt = 3;
    end
    % Set legend
    if length(fpl) > 1
      legend_M = cell(1,length(fpl));
      for j=1:length(fpl)
        legend_M(j) = {param.(fpl{j})};
      end
    else
      legend_M = [];
    end
    x = cell(1,length(fpl));
    y = x;
    np = 0;
    for j = 1:length(fpl);
      np = np + 1;
      fld = fpl{j};
      x{np} = proKdat.Date_Time;
      y{np} = proKdat.(fld);
    end
    if pt == 1 % Standard graphs (multiple variables, 1 set of axes)
      animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    elseif pt == 2 % 2 parameters on seperate y axes
      animate_graphs_yy(varTitle,varStr,legend_M,varYlim,x,y);
    elseif pt == 3 % stacked plots
      animate_graphs_n(varTitle,varStr,y_lab,varYlim,x,y);
     
    end
  else
    % If we don't have data, create an 'empty plot' file
    empty_plot(varStr)
  end
  
end
