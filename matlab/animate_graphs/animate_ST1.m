% Script to plot Engineering Status data from MySQL table

%% Setup variables
st1dat = struct('Date_Time',[],...
  'diff_gps_pers',[],'space_left',[],'gps_fixes',[],...
  'comp_messages',[],'accel_messages',[],...
  'ocr3_messages',[],'co2_messages',[],...
  'seafet_messages',[],'guest_messages',[]);
%   'seafet_messages',[],'guest_messages',[],'time_diff',[]); % full table
flds = fieldnames(st1dat);

% Define plots, titles, legends and y labels
plt = {'ST1a','ST1b'};
pltTitle = {'Engineering Status','Engineering Status'};
pltLeg = {{'GPS v Persistor time','Flash space left','No. GPS fixes',...
  'No. Compass readings','No. accel. readings'},...
  {'OCR3 readings','CCO2 readings','SeaFET readings','Melchor readings'}};
pltYlab = {'Status','Status'};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_ST1'];
s_str = ' order by Date_Time DESC';
[st1dat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
%% Plot data
% Set Y limits for variables
varYlim=[];

% for each plot
for m=1:length(plt)
  % Set plot (variable) name
  varStr = plt{m};
  % If we have data
  if rows>0
    % Set title
    varTitle = {pltTitle{m},...
      ['Latest data: ' datestr(st1dat.Date_Time(1))]};
    % Set legend string
    legend_M = pltLeg{m};
    % Set y axis label
    y_lab = pltYlab{m};
    % Set number of plots
    if m==1
      np1 = 2;
      nps = 5;
    else
      np1 = 7;
      nps = 4;
    end
    % plot and print graphs
    x = cell(1,nps);
    y = x;
    np = 0;
    for i = np1:np1+nps-1;
      np = np + 1;
      fld = flds{i};
      x{np} = st1dat.Date_Time;
      y{np} = st1dat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end

