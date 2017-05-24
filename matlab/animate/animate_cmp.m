% Script to plot Buoy attitude data from MySQL tables

%% Setup variables
cmpdat = struct('numdate',[],...
                'max_pitch',[],'min_pitch',[],'ave_pitch',[],...
                'max_roll',[],'min_roll',[],'ave_roll',[],...
                'max_mag_heading',[],'min_mag_heading',[],'ave_mag_heading',[]);
flds = fieldnames(cmpdat);

plt = {'pitch','roll','mag_heading'};
pltTitle = {'Pitch','Roll','Magnetic Heading'};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_cmp' num2str(m)];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,pro_o_start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  cmpdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    cmpdat.(fld) = cell2mat({DATA(:).(fld)});
  end
end
%% Plot data
% First, Pitch, Roll and Heading Max, Min & Average
% Set legend string
legend_M = {'Max','Min','Average'};
% Set y limits to default
varYlim = 0;
for m=1:3
  % Set plot (variable) name
  varStr = ['cmp_' plt{m}];
  % If we have data
  if rows>0
    % Set Y axis label
    y_lab = [plt{m} ' (Degrees)'];
    % Set title
    varTitle = {['Buoy ' pltTitle{m}], ...
                ['Latest data: ' datestr(cmpdat.numdate(end))]};
 % If we have data - plot and print graphs
    x = cell(1,3);
    y = x;
    np = 0;
    for i = (2:4)+((m-1)*3);
      np = np + 1;
      fld = flds{i};
      x{np} = cmpdat.numdate;
      y{np} = cmpdat.(fld);
    end
    % All 3 on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    % Max, Min and average on 3 subplots
    animate_graphs_n(varTitle,[varStr '_3'],legend_M,varYlim,x,y);
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
    empty_plot([varStr '_3'])
  end
end
