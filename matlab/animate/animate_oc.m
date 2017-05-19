% Script to plot OCR data from MySQL tables

%% Setup variables
ocdat(1:oc_var) = struct('n',[],'Date_Time',[],...
                         'channel_1',[],'channel_2',[],'channel_3',[],...
                         'channel_4',[],'channel_5',[],'channel_6',[],...
                         'channel_7',[],'supply_v',[],'int_temp',[]);
oc_channs={'412.4 nm','434.5 nm','470.2 nm','532.9 nm','555.0 nm','589.4 nm','682.4 nm';...
           '411.5 nm','434.2 nm','469.4 nm','533.0 nm','555.2 nm','682.4 nm','704.6 nm';...
           '411.5 nm','434.2 nm','469.4 nm','533.0 nm','555.2 nm','682.4 nm','704.6 nm'};
%2012 OCR1 === serial no DI70225
%2012 OCR2 === serial no DR70102
%2012 OCR3 === serial no DI70226
%2013 OCR3 === serial no DI70201
  
ocTitle = {'Irradiance sensor 1: Upward looking in sensor frame', ...
           'Irradiance sensor 2: Downward looking, in Sensor frame',...
           'Irradiance sensor 3: Upward looking on the buoy'};
flds = fieldnames(ocdat);
units = {'\muW/cm^2/nm','\muW/cm^2/sr','\muW/cm^2/nm'};
have_data = 0;

%% Read in and QC Values
for m=1:oc_nv
  % Read data from MySQL database table
  db_tab=[db_table '_oc' num2str(m)];
  s_str = ' order by Date_Time DESC';
  [DATA, ocdat(m).n] = mysql_animate(db_tab,flds(2:end),pro_o_start_date,end_date,s_str);
  
  if (ocdat(m).n > 0)
    % transfer data into data structure
    for j=2:length(flds)
      fld = flds{j};
      % Copy measurements into structure
      ocdat(m).(fld) = DATA.(fld);
    end
    
    % Apply qc
    qc = find(ocdat(m).supply_v>=10 | ocdat(m).int_temp>=30);
    for j=3:10
      fld = flds{j};
      ocdat(m).(fld)(qc) = NaN;
    end
  end
end % end of OC dataset read loop
%% Plot data

% All channels for all sensors
% Set legend strings - generic for all 3
%legend_M = ['Ch. 1','Ch. 2','Ch. 3','Ch. 5','Ch. 5','Ch. 6','Ch. 7'];
% Set Y limits for variables
varYlim=[0 10];

for m=1:oc_nv
  % Set plot (variable) name
  varStr = ['oc' num2str(m)];
  % If we have data - plot and print graphs
  if ocdat(m).n > 0
    x = cell(1,7);
    y = x;
    % Set legend string
    legend_M = oc_channs(m,:);
    % Set title
    varTitle = ([ocTitle{m}, ...
      ' Latest data: ' datestr(ocdat(m).Date_Time(end))]);
    % Set Y axis label
    y_lab = units{m};
    np = 0;
    for i = 3:9;
      np = np + 1;
      fld = flds{i};
      x{np} = ocdat(m).Date_Time;
      y{np} = ocdat(m).(fld);
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
