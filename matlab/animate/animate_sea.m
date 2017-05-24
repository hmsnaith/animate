% Script to plot sea data from MySQL table

%% Setup variables

% seadat = struct('Date_Time',[],'batt_voltage',[],'memory_used',[],...
%   'cyclops_chl',[],'Aa_ox_microM',[],'Aa_ox_air_sat',[],'Aa_ox_temp',[],...
%   'Aa_ox_cal_phase',[],'Aa_ox_tcphase',[],'Aa_ox_c1_r_ph',[],...
%   'Aa_ox_c2_r_ph',[],'Aa_ox_c1_a',[],'Aa_ox_c2_a',[],'Aa_ox_raw_temp',[],...
%   'rcm_speed',[],'rcm_dir',[],'rcm_n',[],'rcm_e',[],'heading_mag',[],...
%   'tilt_x',[],'tilt_y',[],'sp_std',[],'sig_strength',[],'ping_count',[],...
%   'abs_tilt',[],'max_tilt',[],'std_tilt',[]);
seadat = struct('Date_Time',[],'batt_voltage',[],'memory_used',[],...
                'cyclops_chl',[],...
                'Aa_ox_microM',[],'Aa_ox_air_sat',[],...
                'rcm_speed',[],'rcm_dir',[],'rcm_n',[],'rcm_e',[],...
                'heading_mag',[],'tilt_x',[],'tilt_y',[],...
                'Aa_ox_microM_corr',[]);
flds = fieldnames(seadat);
param = struct('cyclops_chl','Cyclops Chlorophyll-a',...
               'Aa_ox_microM','Oxygen Conc. (\muM/l)',...
               'Aa_ox_air_sat','Oxygen Saturation (%)',...
               'Aa_ox_microM_corr','Calibrated Oxygen Concentration (\muM/l)',...
               'rcm_speed','Speed (cm/s)','rcm_dir','Direction (\circ)',...
               'rcm_n','North Vel (cm/s)','rcm_e','East Vel (cm/s)',...
               'batt_voltage','Battery (V)','memory_used','Memory used',...
               'heading_mag','Magnetic Heading',...
               'tilt_x','Tilt X','tilt_y','Tilt Y');
plt = struct('Aa_oxygen',[],...
             'Aa_oxygen2',[],...
             'Aa_oxygen3',[],...
             'Aa_oxygen4',[],...
             'cyclops',[],...
             'rcm1',[],...
             'rcm2',[],...
             'rcm3',[],...
             'rcm4',[],...
             'sea_tilt',[],...
             'sea_monitor',[]);
plt.Aa_oxygen={'Aa_ox_microM','Aa_ox_air_sat'};
plt.Aa_oxygen2={'Aa_ox_microM','Aa_ox_air_sat'};
plt.Aa_oxygen3={'Aa_ox_microM_corr','Aa_ox_air_sat'};
plt.Aa_oxygen4={'Aa_ox_microM_corr','Aa_ox_air_sat'};
plt.cyclops={'cyclops_chl'};
plt.rcm1={'rcm_speed','rcm_dir'};
plt.rcm2={'rcm_speed','rcm_dir'};
plt.rcm3={'rcm_n','rcm_e'};
plt.rcm4={'rcm_n','rcm_e'};
plt.sea_tilt={'heading_mag','tilt_x','tilt_y'};
plt.sea_monitor={'batt_voltage','memory_used'};
pltTitle = {'Aanderaa Oxygen','Aanderaa Oxygen',...
            'Calibrated Aanderaa Oxygen','Calibrated Aanderaa Oxygen',...
            'Cyclops Chlorophyll-a',...
            'Current','Current',...
            'Current : arrows show direction of flow and relative speed',...
            'Current',...
            'Seaguard Orientation','Seaguard monitoring'};
pltUnits = {'','','','',... % Oxygen
            'Chl Conc.',...  % chlorophyll
            '',{'Speed cm/s','Dir. \circ'},'rcm3','cm/s',...  % current speed
            '\circ','\circ'};  % orientation
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_sea'];
s_str = ' order by Date_Time ASC';
[DATA, rows] = mysql_animate(db_tab,flds(1:end-1),start_date,end_date,s_str);
if (rows > 0)
  % transfer data into data structure
  for i=1:length(flds)-1
    fld = flds{i};
    seadat.(char(fld)) = DATA.(char(fld));
  end
  % Reject Oxygen values < 1  
  seadat.Aa_ox_microM(seadat.Aa_ox_microM<1) = NaN;
  seadat.Aa_ox_air_sat(seadat.Aa_ox_air_sat<1) = NaN;
  % Calculate calibrated Oxygen
  seadat.Aa_ox_microM_corr = (seadat.Aa_ox_microM.*Aa_ox_slope)+Aa_ox_offset;
  % Calculate calibrated Chlorophyll
  seadat.cyclops_chl=(seadat.cyclops_chl.*cyclops_slope)+cyclops_offset;
  % Ignore zero velocities
  qc = find(((seadat.rcm_speed==0.00)&(seadat.rcm_dir==0.00))|(seadat.rcm_speed<-2));
  seadat.rcm_speed(qc) = NaN;
  seadat.rcm_dir(qc) = NaN;
  seadat.rcm_n(qc) = NaN;
  seadat.rcm_e(qc) = NaN;
  %% Create monthly averages
  numdate_vec = datevec(seadat.Date_Time);
  for fld = {'Aa_ox_air_sat','Aa_ox_microM_corr','cyclops_chl'}
    mnVar = seadat.(char(fld));
    mnVname=char(fld);
    monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  end
end
%% Plot data
pflds = fieldnames(plt);
for m=1:length(pflds)
  % Set plot (variable) name
  varStr = pflds{m};
  if rows>0
    % Set Y axis label
    y_lab = pltUnits{m};
    % Assume no y scaling
    varYlim = [];
    % Set title
    varTitle = {pltTitle{m}, ...
                ['Latest data: ' datestr(seadat.Date_Time(end))]};
    % Set fields to plot
    fpl = plt.(varStr);
    % Set plot type, Y Limits
    switch varStr
      case {'Aa_oxygen','Aa_oxygen3','sea_tilt','rcm1','rcm4'}
        pt = 1;
      case {'cyclops'}
        pt = 1; varYlim = chlYlim;
      case {'Aa_oxygen2','Aa_oxygen4','sea_monitor'}
        pt = 2;
      case 'rcm2'
        pt = 3;
      case 'rcm3'
        pt = 4;
    end
    % Set legend
    if length(fpl) > 1
      legend_M = cell(1,length(fpl));
      for j=1:length(fpl)
        legend_M(j) = {param.(fpl{j})};
      end
    else
      legend_M = [];
    end
    x = cell(1,length(fpl));
    y = x;
    np = 0;
    for j = 1:length(fpl);
      np = np + 1;
      fld = fpl{j};
      x{np} = seadat.Date_Time;
      y{np} = seadat.(fld);
    end
    if pt == 1 % Standard graphs (multiple variables, 1 set of axes)
      animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
    elseif pt == 2 % 2 parameters on seperate y axes
      animate_graphs_yy(varTitle,varStr,legend_M,varYlim,x,y);
    elseif pt == 3 % stacked plots
      animate_graphs_n(varTitle,varStr,y_lab,varYlim,x,y);
    elseif pt == 4 % Quiver plots
      %select time points closest to 0,6,12,18,
      drift = 0.021; % 30 minutes as proportion of day 30/1440
      legend_M = {'00:00','06:00','12:00','18:00'};
      seanumtime = seadat.Date_Time-floor(seadat.Date_Time);
      x = cell(1,4);
      y = x; u = x; v = x;
      for  k = 1:4
        if k==1
          kk = find(seanumtime>1-drift | seanumtime<drift);
        else
          td = 0.25*(k-1);
          kk = find(seanumtime>td-drift & seanumtime<td+drift);
        end
        x{k} = seadat.Date_Time(kk);
        y{k} = ones(size(seadat.Date_Time(kk)));
        u{k} = seadat.(fpl{1})(kk);
        v{k} = seadat.(fpl{2})(kk);
      end
      animate_quiver(varTitle,varStr,y_lab,legend_M,varYlim,x,y,u,v);
     
    end
  else
    % If we don't have data, create an 'empty plot' file
    empty_plot(varStr)
  end
  
end


