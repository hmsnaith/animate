% Script to plot fet data from MySQL table

%% Setup variables
% Set constants

% var='fet';
fetcorrdat(1:fet_nv) = struct('n',[],'numdate',[],'FET_temp',[],...
                     'FET_INT_pH',[],'FET_EXT_pH',[],...
                     'FET_INT_v',[],'FET_EXT_v',[],'therm_v',[],...
                     'supply_v',[],'supply_amp',[],...
                     'FET_hum',[],'int_v',[],...
                     'int_isolated_v',[],'time_diff',[],...
                     'FET_INT_corr',[],'FET_EXT_corr',[]);
flds = fieldnames(fetcorrdat);
units = struct('FET_INT_corr','Internal pH','FET_EXT_corr','External pH');
  have_data = 0;

%% Read in and Calculate Values
% For each FET dataset
for m=1:fet_nv;
  % Read data from MySQL database table
  db_tab=[db_table '_fetcorr_' num2str(m)];
  s_str = ' and time_diff > 0 and time_diff < 9999 order by Date_Time ASC';
  [DATA, fetcorrdat(m).n] = mysql_animate(db_tab,start_date,end_date,s_str);
  
  if (fetcorrdat(m).n > 0)
    have_data = have_data + 1;
    % Convert Date and Time character string to datenum
    fetcorrdat(m).numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
    % transfer remaining data into data structure
    for j=3:length(flds)
      fld = flds{j};
      % Copy basic measurements into structure
      fetcorrdat(m).(fld) = cell2mat({DATA(:).(fld)});
    end
    
    % Set data to NaN if corrected values < 5
    qc = find((fetcorrdat(m).FET_INT_corr <=5)|(fetcorrdat(m).FET_EXT_corr <5));
    for i = [2 3 6 7 15 16]
      fetcorrdat(m).(fld)(i) = NaN;
    end
  end % end of 'if fetdat(m).n>0'
end % End FET dataset loop
%% Plot data
% Internal PH & External PH for all sensors
% Set legend and title strings
legend_M = num2str(fet,'Nom %2i (fet %5i)');
varTitle = ['PAP mooring ' dep_name ' Deployment:  SeaFET pH sensor - with salinity correction'];
% Set Y limits for variables
varYlim=fetYlim;
for i = [15 16]
  fld = flds{i};
  % Set plot (variable) name
  varStr = fld;
  % If we have data - plot and print graphs
  if have_data > 0
    x = cell(1,fet_nv);
    y = x;
    y_lab = units.(fld);   
    for m=1:fet_nv
      x{m} = fetcorrdat(m).numdate;
      y{m} = abs(fetcorrdat(m).(fld));
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
  varStr = ['FET_corr_' num2str(m)];
  % If we have data - plot and print graphs
  if fetcorrdat(m).n > 0
    x = cell(1,2);
    y = x;
    ldat = nanmax(fetcorrdat(m).numdate);
		varTitle = (['Satlantic SeaFET pH sensor - corrected. sn.' int2str(fet(m,2)) ...
              ' Latest data: ' datestr(ldat)  ]);
    np = 0;
    for i = [15 16];
      np = np + 1;
      fld = flds{i};
      x{np} = fetcorrdat(m).numdate;
      y{np} = abs(fetcorrdat(m).(fld));
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end


