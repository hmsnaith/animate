% Script to plot Iridium Status data from MySQL table

%% Setup variables
irddat = struct('numdate',[],...
  'seconds_on',[],'wait',[],'attempt',[],'status',[],...
  'bytes',[],...
  'time_diff',[]);
flds = fieldnames(irddat);

% Define plots & legends
plt = {'ird1','ird2'};
pltLegend = {{'Seconds on','Wait','No. attempts','Status'},...
  {'Bytes sent'}};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_ird'];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  irddat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    irddat(m).(fld) = cell2mat({DATA(:).(fld)});
  end
end
%% Plot data
% Set Y limits for variables
varYlim=0;
% Set title
varTitle = {'Iridium Status',...
  ['Latest data: ' datestr(irddat.numdate(1))]};
% Set y axis label
y_lab = 'Status';

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
      x{np} = irddat.numdate;
      y{np} = irddat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);    
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end

