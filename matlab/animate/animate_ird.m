% Script to plot Iridium Status data from MySQL table

%% Setup variables
irddat = struct('Date_Time',[],...
  'seconds_on',[],'wait',[],'attempt',[],'status',[],'bytes',[]);
%   'seconds_on',[],'wait',[],'attempt',[],'status',[],... % full table
%   'bytes',[],'time_diff',[]);
flds = fieldnames(irddat);

% Define plots & legends
plts = {'ird1','ird2'};
pltLeg = {{'Seconds on','Wait','No. attempts','Status'},...
  {'Bytes sent'}};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_ird'];
s_str = ' order by Date_Time DESC';
[irddat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
%% Plot data
% Set Y limits for variables
varYlim=[];
% Set title
varTitle = {'Iridium Status',...
  ['Latest data: ' datestr(irddat.Date_Time(1))]};
% Set y axis label
y_lab = 'Status';

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
      nps = 4;
    else
      np1 = 6;
      nps = 1;
    end
    % plot and print graphs
    x = cell(1,nps);
    y = x;
    np = 0;
    for i = np1:np1+nps-1;
      np = np + 1;
      fld = flds{i};
      x{np} = irddat.Date_Time;
      y{np} = irddat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end

