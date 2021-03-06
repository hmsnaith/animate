% Script to plot fet data from MySQL tables

%% Setup variables
% fetdat(1:fet_nv) = struct('n',[],'Date_Time',[],'FET_temp',[],...
%                      'FET_INT_pH',[],'FET_EXT_pH',[],...
%                      'FET_INT_v',[],'FET_EXT_v',[],'therm_v',[],...
%                      'supply_v',[],'supply_amp',[],...
%                      'FET_hum',[],'int_v',[],...
%                      'int_isolated_v',[],'time_diff',[]);
fetdat(1:fet_nv) = struct('n',[],'Date_Time',[],...
                     'FET_INT_pH',[],'FET_EXT_pH',[]);
flds = fieldnames(fetdat);
units = struct('FET_INT_pH','Internal pH','FET_EXT_pH','External pH');
have_data = 0;
last_date = datenum('01-01-1900');
%% Read in Values
% For each FET dataset
for m=1:fet_nv;
  % Read data from MySQL database table
  db_tab=[db_table '_fet_' num2str(m)];
  s_str = ' and time_diff > 0 and time_diff < 9999 order by Date_Time ASC';
  [DATA, fetdat(m).n] = mysql_animate(db_tab,flds(2:end),start_date,end_date,s_str);
  
  if (fetdat(m).n > 0)
    have_data = have_data + 1;
    % transfer remaining data into data structure
    for j=2:length(flds)
      fld = flds{j};
      % Copy basic measurements into structure
      fetdat(m).(fld) = DATA.(fld);
    end
    last_date = max(last_date,fetdat(m).Date_Time(end));
  end % end of 'if fetdat(m).n>0'
end % End FET dataset loop
%% Plot data
% Internal PH & External PH for all sensors
% Set legend and title strings
legend_M = num2str(fet,'Nom %2i (fet %5i)');
varTitle = {['PAP ' dep_name ' Deployment:  SeaFET pH sensor'], ...
            ['Latest data: ' datestr(last_date)]};
% Set Y limits for variables
varYlim=fetYlim;
  
% for i = [4 5]
for i = [3 4]
  fld = flds{i};
  % Set plot (variable) name
  varStr = fld;
  % If we have data - plot and print graphs
  if have_data > 0
    x = cell(1,fet_nv);
    y = x;
    y_lab = units.(fld);   
    for m=1:fet_nv
      x{m} = fetdat(m).Date_Time;
      y{m} = abs(fetdat(m).(fld));
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
 
% Internal & External PH for each sensor
legend_M = (['FET INT pH';'FET EXT pH']);
y_lab = 'pH';
for m=1:fet_nv
  % Set plot (variable) name
  varStr = ['FET_' num2str(m)];
  % If we have data - plot and print graphs
  if fetdat(m).n > 0
    x = cell(1,2);
    y = x;
		varTitle = {['Satlantic SeaFET pH sensor-sn.' int2str(fet(m,2))]; ...
                ['Latest data: ' datestr(last_date)]};
    np = 0;
%     for i = [4 5];
    for i = [3 4];
      np = np + 1;
      fld = flds{i};
      x{np} = fetdat(m).Date_Time;
      y{np} = abs(fetdat(m).(fld));
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end



