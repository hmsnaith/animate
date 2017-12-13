% Script to plot Met data from MySQL table

%% Setup variables
metdat = struct('Date_Time',[],...
   'air_press',[],'sea_temp',[],'wave_TP',[],...
  'Hsig',[],'Hmax',[],'wave_dir',[],'wave_spread',[],...
  'humidity',[],'humidity_2',[],...
  'air_temp',[],'dew_temp',[],'air_temp_2',[],'dew_temp_2',[],...
  'wind_speed',[],'wind_gust',[],'wind_dir',[]);
flds = fieldnames(metdat);

% Define plots & legends
plt = struct('air_press',[],...
       'sea_temp',[],...
       'temp',[],...
       'temp_3',[],...
       'humidity',[],...
       'waveTP',[],...
       'waveH',[],....
       'waveDir',[],...
       'wave_arrow',[],...
       'wind',[],...
       'wind_2',[],...
       'wind_arrow',[]);
%        'temp2',[]); % If we have a second sensor
plt.air_press={'air_press'};
plt.sea_temp={'sea_temp'};
plt.temp={'air_temp','dew_temp'};
plt.temp_3={'sea_temp','air_temp','dew_temp'};
plt.humidity={'humidity'}; % {'humidity','humidity_2'}; % 2 sensors
plt.waveTP={'wave_TP'};
plt.waveH={'Hsig','Hmax'};
plt.waveDir={'wave_dir','wave_spread'};
plt.wave_arrow={'Hsig','wave_dir'};
plt.wind={'wind_speed','wind_gust','wind_dir'};
plt.wind_2={'wind_speed','wind_gust','wind_dir'};
plt.wind_arrow={'wind_speed','wind_dir'};
% plt.temp2={'air_temp_2','dew_temp_2'};
pltTitle = {'Air Pressure',...
            'Sea Surface Temperature',...
            'Temperatures - UK Met.Office',...
            'Temperatures - UK Met.Office',...
            'Humidity - UK Met.Office',...
            'Wave Peak Period',...
            'Wave Heights',...
            'Wave Direction',...
            'Wave Direction : Arrows show direction and relative speed',...
            'Wind',...
            'Wind',...
            'Wind Direction : Arrows show direction and relative speed'};
%             'Temperatures 2nd Set--UK Met.Office'} % For second sensor
pltLeg = {{''},... % air_press
          {''},... % sea_temp
          {'Air','Dew Point'},... % Air & Dew temp
          {'Sea','Air','Dew'},... % Sea, Air & Dew temp
          {''},... % Humidity {'Sensor 1','Sensor 2'},... % For second sensor
          {''},... % Wave period
          {'Significant Wave Height','Maximum Wave Height'},... % Wave Heights
          {'Direction','Spread'},... % Wave Direction
          {'',''},... % Wave Direction quiver
          {'Speed knots','Gust knots','Direction'},... % Wind speed, gust & Dir - 1plot
          {'Speed knots','Gust knots','Direction'},... % Wind speed, gust & Dir - 2plots
          {'','',''}}; % Wind speed & dir quiver
%           {'Air','Dew Point'}}; % For second sensor
pltYlab = {'hectopascal',... % air_press
           '\circC',... % sea_temp
           '\circC',... % Air & Dew temp
           {'Sea Temp. (\circC)','Air Temp. (\circC)','Dew Point (\circC)'},... % Sea, Air & Dew temp
           '%',... % Humidity
           's',... % Wave period
           'm',... % Wave Heights
           'Dir (\circC)',... % Wave Direction
           '\circC)',... % Wave Direction quiver
          {'Speed knots','Gust knots','Direction'},... % Wind speed, gust & Dir - 1plot
          {'Speed knots','Gust knots','Direction'},... % Wind speed, gust & Dir - 3plots
          {'','',''}}; % Wind speed & dir quiver
%            '\circC'}; % For second sensor

%% Read in Values and apply QC
% Read data from MySQL database table
db_tab=[db_table '_met'];
s_str = ' order by Date_Time DESC';
[metdat, rows] = mysql_animate(db_tab,flds,start_date,end_date,s_str);

if (rows > 0)
  % Apply out of bounds checks
  metdat.air_temp(metdat.air_temp<0 | metdat.air_temp>50) = NaN;
  metdat.sea_temp(metdat.sea_temp<0 | metdat.sea_temp>50) = NaN;
  metdat.dew_temp(metdat.dew_temp<0 | metdat.dew_temp>50) = NaN;
  metdat.humidity(metdat.humidity<0) = NaN;
  metdat.humidity_2(metdat.humidity_2<=0) = NaN;
  metdat.wind_speed(metdat.wind_speed>9999) = NaN;
  metdat.wind_dir(metdat.wind_dir>360) = NaN;
  metdat.Hmax(metdat.Hmax>999) = NaN;
  metdat.wave_TP(metdat.wave_TP>=9999) = NaN;
 
  % Check wind_gust not null and in bounds
  if isempty(metdat.wind_gust)
    metdat.wind_gust = NaN(1,rows);
  elseif length(metdat.wind_gust)<rows
    metdat.wind_gust = NaN(1,rows);
    tmp = {DATA(:).wind_gust};
    for i=1:rows
      if ~isempty(tmp{i}), metdat.wind_gust(i) = tmp{i}; end
    end
  end
  metdat.wind_gust(metdat.wind_gust>9999) = NaN;
  % Check Hsig not null and in bounds
  if isempty(metdat.Hsig)
    metdat.Hsig = NaN(1,rows);
  elseif length(metdat.Hsig)<rows
    metdat.Hsig = NaN(1,rows);
    tmp = {DATA(:).Hsig};
    for i=1:rows
      if ~isempty(tmp{i}), metdat.Hsig(i) = tmp{i}; end
    end
  end
  metdat.Hsig(metdat.Hsig>999) = NaN;
  % end of data input
  %% Create monthly averages
  % monthly averages
  zqzq=find((metdat.wind_dir > 0) & (metdat.wind_speed > 0));
  numdate_vec=datevec(metdat.Date_Time(zqzq));
  mnVar=metdat.wind_speed(zqzq);
  mnVname='wind_speed';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  
end;

%% Plot data

pflds = fieldnames(plt);
% for each plot
for m=1:length(pflds)
  % Set plot (variable) name
  varStr = ['met_' pflds{m}];
  % If we have data
  if rows>0
    % Set y axis label
    y_lab = pltYlab{m};
    % Assume no y scaling
    varYlim=[];
    % Set title
    varTitle = {pltTitle{m},...
      ['Latest data: ' datestr(metdat.Date_Time(1))]};
    % Set fields to plot
    fpl = plt.(pflds{m});
    % Set plot type, Y Limits and qc
    qc = [];
    switch varStr
      case {'met_air_press'}
        pt = 1; varYlim = [900 1100];
      case {'met_waveH'}
        pt = 1; varYlim = [0 min(50,max(max(metdat.Hmax),max(metdat.Hsig)))];
      case {'met_temp_3'}
        % Only use data where air/sea temp difference <4
        pt = 1; qc = find(abs(metdat.sea_temp-metdat.air_temp)>=4);
      case {'met_wind_2'}
        pt = 2;
      case {'met_wave_arrow'}
        pt = 4; d = 0; % quiver - directions given 'to'
      case {'met_wind_arrow'}
        pt = 4; d = 180; % quiver - directions given 'from'
      otherwise
        pt = 1;
    end
    % Set legend
    legend_M = pltLeg{m};
    % plot and print graphs
    x = cell(1,length(fpl));
    y = x;
    for i = 1:length(fpl);
      fld = fpl{i};
      x{i} = metdat.Date_Time;
      y{i} = metdat.(fld);
      if ~isempty(qc), y{i}(qc) = NaN; end
    end

    if pt == 1 % Standard graphs (multiple variables, 1 set of axes)
      animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    elseif pt == 2 % 2 parameters on 1 graph on seperate y axes, other params on 1 graph
      animate_graphs_yy_1(varTitle,varStr,legend_M,varYlim,x,y);
    elseif pt == 3 % stacked plots
      animate_graphs_n(varTitle,varStr,y_lab,varYlim,x,y);
    elseif pt == 4 % Quiver plots
      %select time points closest to 00:00, 06:00, 12:00 & 18:00,
      drift = 0.0035; % 5 minutes as proportion of day 5/1440
      legend_M = {'00:00','06:00','12:00','18:00'};
      metnumtime = metdat.Date_Time-floor(metdat.Date_Time);
      x = cell(1,4);
      y = x; u = x; v = x;
      for  k = 1:4
        if k==1
          kk = find(metnumtime>1-drift | metnumtime<drift);
        else
          td = 0.25*(k-1);
          kk = find(metnumtime>td-drift & metnumtime<td+drift);
        end
        x{k} = metdat.Date_Time(kk);
        y{k} = ones(size(metdat.Date_Time(kk)));
        u{k} = metdat.(fpl{1})(kk).*sind(d-metdat.(fpl{2})(kk));
        v{k} = metdat.(fpl{1})(kk).*cosd(d-metdat.(fpl{2})(kk));
      end
      animate_quiver(varTitle,varStr,y_lab,legend_M,varYlim,x,y,u,v);
     
    end
  else
    % If we don't have data, create an 'empty plot' file
    empty_plot(varStr)
  end
end
