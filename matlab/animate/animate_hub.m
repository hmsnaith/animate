% Script to plot Hub Status data from MySQL table

%% Setup variables
hubdat = struct('numdate',[],...
  'diff_hub_gps',[],'space',[],'cmp',[],'acc',[],'co2',[],...
  'gtd',[],'sea',[],'nas',[],'isus',[],...
  'ocr1',[],'ocr2',[],'wet',[],...
  'hub_volt',[],'hub_hum',[],'hub_temp',[],...
  'time_diff',[]);
% If we have 3 OCR sensors update here
%   'ocr1',[],'ocr2',[],'ocr3',[],'wet',[],...
%   'hub_volt',[],'hub_hum',[],'hub_temp',[],...
%   'time_diff',[]);
flds = fieldnames(hubdat);

% Define plots & legends
plt = {'hub1','hub2','hub3','hub3'};
pltLegend = {{'diff hub v gps','flash space','Compass','Accelerometer','Carbon Dioxide'},...
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
[DATA, rows] = mysql_animate(db_tab,start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  hubdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    hubdat(m).(fld) = cell2mat({DATA(:).(fld)});
  end
end
plot(hubnumdate,diff_hub_gps,hubnumdate,space,hubnumdate,cmp,hubnumdate,acc,hubnumdate,co2);
plot(hubnumdate,gtd,hubnumdate,sea,hubnumdate,nas,hubnumdate,isus);
plot(hubnumdate,ocr1,'b*-',hubnumdate,ocr2,'g',hubnumdate,wet,'r');
plot(hubnumdate,hub_volt,'b-',hubnumdate,hub_hum,'g',hubnumdate,hub_temp,'r');
%% Plot data
% Set Y limits for variables
varYlim=0;
% Set title
varTitle = {'Engineering HUB Status message',...
  ['Latest data: ' datestr(hubdat.numdate(1))]};
% Set y axis label
y_lab = 'Counts';

% for each plot
for m=1:length(plts)
  % Set plot (variable) name
  varStr = plt{m};
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
      x{np} = hubdat.numdate;
      y{np} = hubdat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
