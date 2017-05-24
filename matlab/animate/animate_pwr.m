% Script to plot Power data from MySQL table

%% Setup variables
pwrdat = struct('numdate',[],'current_batt',[],'current_hub',[],...
  'batt_volt',[],'batt_power',[],...
  'housing_hum',[],'housing_temp',[],'time_diff',[]);
flds = fieldnames(pwrdat);

% Define plots, titles, legends and y labels
plt = {'current','voltage','housing'};
pltTitle = {'Electrical current','Battery Voltage','Housing'};
pltLegend = {{'Battery Current (mA)','Hub Current (mA)'},...
  {'Battery Voltage','Total Battery Power'},...
  {'Humidity','Temperature'}};
pltYlab = {'Current (mA)','Voltage (V)','Voltage (V)'};

%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_pwr'];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  pwrdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    pwrdat(m).(fld) = cell2mat({DATA(:).(fld)});
  end
end
%% Plot data
% Set Y limits for variables
varYlim=0;

% for each plot
for m=1:length(plts)
  % Set plot (variable) name
  varStr = ['pwr_' plt{m}];
  % If we have data
  if rows>0
    % Set title
    varTitle = {pltTitle{m},...
      ['Latest data: ' datestr(pwrdat.numdate(1))]};
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
      x{np} = pwrdat.numdate;
      y{np} = pwrdat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
