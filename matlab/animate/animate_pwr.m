% Script to plot Power data from MySQL table

%% Setup variables
pwrdat = struct('Date_Time',[],'current_batt',[],'current_hub',[],...
  'batt_volt',[],'batt_power',[],...
  'housing_hum',[],'housing_temp',[]);
%   'housing_hum',[],'housing_temp',[],'time_diff',[]); % full table
flds = fieldnames(pwrdat);

% Define plots, titles, legends and y labels
plts = {'current','voltage','housing'};
pltTitle = {'Electrical current','Battery Voltage','Housing'};
pltLeg = {{'Battery Current (mA)','Hub Current (mA)'},...
  {'Battery Voltage','Total Battery Power'},...
  {'Humidity','Temperature'}};
pltYlab = {'Current (mA)','Voltage (V)','Voltage (V)'};

%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_pwr'];
s_str = ' order by Date_Time DESC';
[pwrdat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
%% Plot data
% Set Y limits for variables
varYlim=[];

% for each plot
for m=1:length(plts)
  % Set plot (variable) name
  varStr = ['pwr_' plts{m}];
  % If we have data
  if rows>0
    % Set title
    varTitle = {pltTitle{m},...
      ['Latest data: ' datestr(pwrdat.Date_Time(1))]};
    % Set legend string
    legend_M = pltLeg{m};
    % Set y axis label
    y_lab = pltYlab{m};
    % plot and print graphs
    x = cell(1,2);
    y = x;
    np = 0;
    for i = (2:3)+((m-1)*2);
      np = np + 1;
      fld = flds{i};
      x{np} = pwrdat.Date_Time;
      y{np} = pwrdat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
