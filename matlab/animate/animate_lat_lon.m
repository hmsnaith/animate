function animate_lat_lon(db_table, t_suf, psuf, d_lims, coords, ll_lims, anchor)
% Script to plot lat / lon data from MySQL table

%% Setup variables
global webdir

db_tab = [db_table t_suf];
plnm = ['lat_long' psuf];
dat = struct(coords{1},[],coords{2},[]);
suff = {'','_all','_7','_7a'};
%% Read in Values
% Read data from MySQL database table
  s_str = [' and ' coords{1} ' <= ' num2str(ll_lims(2)) ...
           ' and ' coords{1} ' >= ' num2str(ll_lims(1)) ...
           ' and ' coords{2} ' <= ' num2str(ll_lims(4)) ...
           ' and ' coords{2} ' >= ' num2str(ll_lims(3)) ...
           ' order by Date_Time DESC'];
[DATA, rows] = mysql_animate(db_tab,d_lims{1},d_lims{2},s_str);

if (rows > 0)
  posdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  for fld=coords
    % Copy basic measurements into structure
    fldnm = char(fld);
    dat.(fldnm) = NaN(1,rows);
    % Default values are NaN
    tmp = {DATA(:).(fldnm)};
    % As long as we have some data
    if ~isempty([tmp{:}])
      % If we have all numeric data - just save it
      if isnumeric([tmp{:}])
        % Convert cell array to matrix
        tmp2 = cell2mat(tmp);
        if length(tmp2)<rows % if the array is 'short', not all values set
          for i=1:rows
            if ~isempty(tmp{i}), dat.(fldnm)(i) = tmp{i}; end
          end
        else
          dat.(fldnm) = tmp2;
        end
        % If there's non-numeric, loop over each one
      else
        for i=1:rows
          if ~isempty(tmp{i})
            if isnumeric(tmp{i})
              dat.(fldnm)(i) = tmp{i};
            else
              dat.(fldnm) = str2double(tmp{i});
            end
          end
        end
      end
    end
  end
  % Keep longitudes in +/-180
  dat.(coords{2})(dat.(coords{2})>180.) = dat.(coords{2})(dat.(coords{2})>180)-360.;
  %% Plot position info
  % Open new figure
  figure('visible','off');
  
  %% Plot the most recent position info
  % Set which data to plot (last 100, or all if less)
  hundred=min(rows,100);
  ten=10;
  eleven=11;
  if (rows < 50)
    ten=rows;
    eleven=1;
  end;
  % Plot the position
  plot(anchor(2),anchor(1),'ks',... % Notional position
    dat.(coords{2})(eleven:hundred),dat.(coords{1})(eleven:hundred),'y+-',... % dashed yellow line oldest
    dat.(coords{2})(2:ten),dat.(coords{1})(2:ten),'b*-',... % blue stars on dotted for recent
    dat.(coords{2})(1),dat.(coords{1})(1),'r* '); % Red star for latest position

  % Set legend and title text
  vLeg = {'Anchor Position',...
         ['Positions ' num2str(eleven) ' to ' num2str(hundred)],...
         ['Positions 2 to ' num2str(eleven)],...
          'Lastest Position'};
  s  = [db_table, ' mooring : Last ' num2str(hundred) ' reports of position'];
  s1 = [' Last position: ' num2str(dat.(coords{1})(1)) ' N ' num2str(dat.(coords{2})(1)) ' W'...
    ' at ' datestr(posdate(1))];

  % Send to plot
  animate_lat_lon_graphs(webdir, plnm, [], {s s1}, vLeg)
  
  %% Plot all position info
  clf
  plot(anchor(2),anchor(1),'ks',dat.(coords{2}),dat.(coords{1}),'b.:',...
    dat.(coords{2})(1),dat.(coords{1})(1),'r* ');
  
  % Set legend and title text
  vLeg = {'Anchor Position','All Positions','Last Position'};
  s = [db_table, ' mooring : All reports of position'];

  % Send to plot
  animate_lat_lon_graphs(webdir, plnm, suff{2}, {s s1}, vLeg)
  
  %% Plot last 7 days of data
  clf
  sel=find((posdate(1)-posdate)<7);
  plot(anchor(2),anchor(1),'ks',dat.(coords{2})(sel),dat.(coords{1})(sel),'b.:',dat.(coords{2})(1),dat.(coords{1})(1),'r* ');

  % Set legend and title text
  vLeg = {'Anchor Position','All Positions','Last Position'};
  s = [db_table, ' mooring : Last 7 days reports of position'];

  % Send to plot
  animate_lat_lon_graphs(webdir, plnm, suff{3}, {s s1}, vLeg)
  
  %% Plot last 7 days  plot with no anchor position
  clf
  plot(dat.(coords{2})(sel),dat.(coords{1})(sel),'b.:',dat.(coords{2})(1),dat.(coords{1})(1),'r* ');

  % Set legend and title text
  vLeg = {'Last 7 days','Last Position'};
  s = [db_table, ' mooring : Last 7 days reports of position'];

  % Send to plot
  animate_lat_lon_graphs(webdir, plnm, suff{4}, {s s1}, vLeg)

  % Close figure
  close
  
  %% Write latest data read to file
  animate_latest_date(webdir,psuf,posdate(1));
  
  %% If we don't have data, create an 'empty plot' file
else
  for i=1:length(suff)
    empty_plot([plnm suff{i}]); empty_plot(['small_' plnm suff{i}]);
  end
end
