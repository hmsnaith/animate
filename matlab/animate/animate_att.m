% Script to plot Hub attitude data from MySQL tables
%% Setup variables
attdat = struct('numdate',[],...
  'max_pitch',[],'min_pitch',[],'ave_pitch',[],...
  'max_roll',[],'min_roll',[],'ave_roll',[],...
  'max_mag_heading',[],'min_mag_heading',[],'ave_mag_heading',[],...
  'max_g_X',[],'min_g_X',[],'ave_g_X',[],...
  'max_g_Y',[],'min_g_Y',[],'ave_g_Y',[],...
  'max_g_Z',[],'min_g_Z',[],'ave_g_Z',[]);
flds = fieldnames(attdat);

plt = {'pitch','roll','mag_heading','g_X','g_Y','g_Z'};
pltTitle = {'Pitch','Roll','Magnetic Heading',...
  'Accelerometer X-axis','Accelerometer Y-axis','Accelerometer Z-axis'};
%% Read in Values
% Read data from MySQL database table
db_tab=[db_table '_att' num2str(m)];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,pro_o_start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  attdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    attdat.(fld) = cell2mat({DATA(:).(fld)});
  end
end
%% Plot data
% First, Pitch, Roll and Heading Max, Min & Average
% Set legend string
legend_M = {'Max','Min','Average'};
for m=1:6
  % Set plot (variable) name
  varStr = ['att_' plt{m}];
  % If we have data
  if rows>0
    % Set Y axis label
    y_lab = [plt{m} ' (Degrees)'];
    % Set title
    varTitle = {['Hub ' pltTitle{m}], ...
      ['Latest data: ' datestr(attdat.numdate(end))]};
    % Set Y Limits
    if m<=2
      varYlim = [-50 50];
    elseif m==4 || m==5
      varYlim = [-2 2];
    elseif m==6
      varYlim = [-1 3];
    else
      varYlim = 0;
    end
    % If we have data - plot and print graphs
    x = cell(1,3);
    y = x;
    np = 0;
    for i = (2:4)+((m-1)*3);
      np = np + 1;
      fld = flds{i};
      x{np} = attdat.numdate;
      y{np} = attdat.(fld);
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
