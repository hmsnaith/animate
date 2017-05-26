% Script to plot Hub Status data from MySQL table

%% Setup variables
hubdat = struct('Date_Time',[],...
  'diff_hub_gps',[],'space',[],'cmp',[],'acc',[],'co2',[],...
  'gtd',[],'sea',[],'nas',[],'isus',[],...
  'ocr1',[],'ocr2',[],'wet',[],...
  'hub_volt',[],'hub_hum',[],'hub_temp',[]);
%   'hub_volt',[],'hub_hum',[],'hub_temp',[],... % Full table
%   'time_diff',[]);
% If we have 3 OCR sensors update here
%   'ocr1',[],'ocr2',[],'ocr3',[],'wet',[],...
%   'hub_volt',[],'hub_hum',[],'hub_temp',[],...
%   'time_diff',[]);
flds = fieldnames(hubdat);

% Define plots & legends
plts = {'hub1','hub2','hub3','hub3'};
pltLeg = {{'diff hub v gps','flash space','Compass','Accelerometer','Carbon Dioxide'},...
  {'GTD','Seaguard','NAS','ISUS'}...
  {'OCR1','OCR2','Wetlabs'},...
  {'Voltage','Humidity %','Temp \circC'}};
% If we have 3 OCR sensors update here
%   {'OCR1','OCR2','OCR3','Wetlabs'},...
%   {'Voltage','Humidity %','Temp \circC'}};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_hub'];
s_str = ' order by Date_Time DESC';
[hubdat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
%% Plot data
% Set Y limits for variables
varYlim=[];
% Set title
varTitle = {'Engineering HUB Status message';...
  ['Latest data: ' datestr(hubdat.Date_Time(1))]};
% Set y axis label
y_lab = 'Counts';

% for each plot
for m=1:length(plts)
  % Set plot (variable) name
  varStr = plts{m};
  % If we have data
  if rows>0
    % Set legend string
    legend_M = pltLeg{m};
    % Set number of plots
    if m==1
      np1 = 2;
      nps = 5;
    elseif m==2
      np1 = 7;
      nps = 4;
    elseif m==3
      np1 = 11;
      nps = 3; % If we have 3 OCR sensors update to nps=4
    else
      np1 = 14; % If we have 3 OCR sensors update to np1=15
      nps = 3;
    end
    % plot and print graphs
    x = cell(1,nps);
    y = x;
    np = 0;
    for i = np1:np1+nps-1;
      np = np + 1;
      fld = flds{i};
      x{np} = hubdat.Date_Time;
      y{np} = hubdat.(fld);
    end
    % All on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
