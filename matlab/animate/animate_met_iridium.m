% Script to plot Met data from MySQL table

%% Setup variables
% metdat = struct('numdate',[],...
%   'air_press',[],'sea_temp',[],'wave_TP',[],...
%   'Hsig',[],'Hmax',[],'wave_dir',[],'wave_spread',[],...
%   'humidity',[],'humidity2',[],...
%   'air_temp',[],'dew_temp',[],'air_temp2',[],'dew_temp2',[],...
%   'wind_speed',[],'wind_gust',[],'wind_dir',[]);
% flds = fieldnames(metdat);
flds = {'Date_Time', 'air_press', 'sea_temp', 'wave_TP',...
  'Hsig', 'Hmax', 'wave_dir', 'wave_spread', ...
  'humidity', 'humidity_2', ...
  'air_temp', 'dew_temp', 'air_temp_2', 'dew_temp_2', ...
  'wind_speed', 'wind_gust', 'wind_dir'};

% Define plots & legends
plt = {'air_press','sea_temp','waveTP','waveH','waveDir','humidity',...
  'temp','temp2','wind','wind2'};
pltLegend = {{''},{''},{''},...
  {'Significant Wave Height','Maximum Wave Height'},...
  {'Direction','Spread'},{'Sensor 1','Sensor 2'},...
  {'Air','Dew Point'},{'Air','Dew Point'},...
  {'Speed knots','Gust  knots','Direction'}...
  };
pltTitle = {'Air Pressure','Sea Surface Temperature','Wave Peak Period',...
  'Wave Heights','Wave Direction','Humidity - UK Met.Office',...
  'Temperatures--UK Met.Office','Temperatures 2nd Set--UK Met.Office','Wind','Wind'};
pltYlab = {'hectopascal','\circC','',...
  'm','Degrees','%','\circC','\circC','',''};

%% Read in Values and apply QC
% Read data from MySQL database table
db_tab=[db_table '_met'];
s_str = ' order by Date_Time DESC';
[metdat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);

if (rows > 0)
%   % Convert Date and Time character string to datenum
%   metdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
%   % transfer remaining data into data structure
%   for j=2:length(flds)
%     fld = flds{j};
%     % Copy measurements into structure
%     metdat(m).(fld) = cell2mat({DATA(:).(fld)});
%   end
% 
  % Apply out of bounds checks
  metdat.air_temp(metdat.air_temp<0 | metdat.air_temp>50) = NaN;
  metdat.sea_temp(metdat.sea_temp<0 | metdat.sea_temp>50) = NaN;
  metdat.dew_temp(metdat.dew_temp<0 | metdat.dew_temp>50) = NaN;
  metdat.humidity(metdat.humidity<0) = NaN;
  metdat.humidity2(metdat.humidity2<0) = NaN;

  % Check Hsig and wind_gust not null
  if isempty(metdat.Hsig)
    metdat.HSig = NaN(1,rows);
  elseif length(metdat.Hsig)<rows
    metdat.HSig = NaN(1,rows);
    tmp = {DATA(:).Hsig};
    for i=1:rows
      if ~isempty(tmp{i}), metdat.HSig(i) = tmp{i}; end
    end
  end
  metdat.HSig(metdat.HSig>99) = NaN;
  if isempty(metdat.wind_gust)
    metdat.wind_gust = NaN(1,rows);
  elseif length(metdat.wind_gust)<rows
    metdat.wind_gust = NaN(1,rows);
    tmp = {DATA(:).wind_gust};
    for i=1:rows
      if ~isempty(tmp{i}), metdat.wind_gust(i) = tmp{i}; end
    end
  end
  % end of data input
  %% Create monthly averages
  % monthly averages
  numdate_vec = datevec(metdat.Date_Time);
  for fld = {'temp','S','ox_mol','ox_mol_comp'}
    mnVname=char(fld);
    mnVar = smetdat.(char(fld));
    monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  end
  
  %monthly averages
  zqzq=find((wind_dir > 0) & (wind_speed > 0));
  numdate_vec=datevec(metdat.Date_Time(zqzq));
  mnVar=wind_speed(zqzq);
  mnVname='wind_speed';
  monthly_average;
end;

%% Plot data

% for each plot
for m=1:length(plt)
  % Set plot (variable) name
  varStr = ['met_' plt{m}];
  % If we have data
  if rows>0
    % Set Y limits for variables
    varYlim=0;
    if m==1
      varYlim = [900 1100];
    end
    % Set title
    varTitle = {pltTitle{m},...
      ['Latest data: ' datestr(metdat.Date_Time(1))]};
    % Set legend string
    legend_M = pltLeg{m};
    % Set y axis label
    y_lab = pltYlab{m};
    % Set number of plots
    if m<=3
      p = m+1;
    elseif m<=7;
      p = m+((m-4)*2)+1:m+((m-3)*2);
    else
      p = m+((m-8)*3)+1:m+((m-7)*3);
    end
    nps = length(p);
    % plot and print graphs
    x = cell(1,nps);
    y = x;
    np = 0;
    for i = p;
      np = np + 1;
      fld = flds{i};
      x{np} = metdat.Date_Time;
      y{np} = metdat.(fld);
    end
    % All on one graph
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    % Wind data on 3 seperate graphs
    % - we actually want speed&gust on one, dir on another...
    if m==8
      animate_graphs_n(varTitle,[varStr '_3'],legend_M,varYlim,x,y);
    end
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end

% Additional plots
% sea temp, air temp and dew temp on one graph
varStr = 'met_temp3';
if rows > 0
  % Set Y limits for variables
  varYlim=0;
  % Set title
  varTitle = {'Temperatures--UK Met.Office',...
    ['Latest data: ' datestr(metdat.Date_Time(1))]};
  % Set legend string
  legend_M = {'Sea surface','Air','Dew Point'};
  % Set y axis label
  y_lab = '\circC';
  % Only use data where air/sea temp difference <4
  qc = find(abs(metdat.sea_temp-metdat.air_temp)<4);
  % plot and print graphs
  x = cell(1,3);
  y = x;
  np = 0;
  for i = [3 11 12];
    np = np + 1;
    fld = flds{i};
    x{np} = metdat.Date_Time(qc);
    y{np} = metdat.(fld)(qc);
  end
  % All 3 on one graph
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
else
  empty_plot(varStr)
end

% Quiver plots - plot records at 00:00, 06:00, 12:00 & 18:00, +/1 5 mins
drift = 0.0035; %5 minutes as proportion of hour 300/84600
for i = [7 16]
  if i==7
    varStr = 'met_wave_arrow';
    pltT = 'Wind';
    fld2 = flds{i-2};
  else
    varStr = 'met_wind3';
    pltT = 'Wave';
    fld2 = flds{i-1};
  end
  if rows>0
  varTitle = {[pltT ' Direction : Arrows show direction and relative speed'],...
    ['Latest data: ' datestr(metdat.Date_Time(1))]};
  legend_M = {'00:00','06:00','12:00','18:00'};
  fld = flds{i};
  w_dir = metdat.(fld)+180;
  u = sin(w_dir*0.0175).* metdat.(fld2);    % pi/180
  v = cos(w_dir*0.0175).* metdat.(fld2);
  metnumtime = metdat.Date_Time-floor(metdat.Date_Time);
  x = cell(1,4);
  y = x; up = x; vp = x;
  for  k = 1:4
    if k==1
      kk = find(metnumtime>1-drift | metnumtime<drift);
    else
      td = 0.25*(k-1);
      kk = find(metnumtime>td-drift & metnumtime<td+drift);
    end
    x{k} = metdat.Date_Time(kk);
    y{k} = ones(size(metdat.Date_Time(kk)));
    up{k} = u(kk);
    vp{k} = v{kk};
  end
  animate_quiver(varTitle,varStr,y_lab,legend_M,varYlim,x,y);

  else
    empty_plot(varStr)
  end
end

