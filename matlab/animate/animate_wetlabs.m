% Script to plot Wetlabs data from MySQL table
%% Setup variables
% wetdat = struct('Date_Time',[],...
%   'fl_chl_ref',[],'fl_chl',[],'fl_ntu_ref',[],...
%   'fl_ntu',[],'fl_thermistor',[],'fl_pressure',[]);
wetdat = struct('Date_Time',[],...
  'fl_chl_ref',[],'fl_chl',[],'fl_ntu',[],'Chl',[]);
flds = fieldnames(wetdat);
param = struct('pro_o_K_seconds',[],'pro_o_K_conc','xCO_2 (ppm)','pro_o_K_cell_temp',[],...
  'pro_o_K_AZPC','eng, units','pro_o_K_raw_co2','eng, units','pro_o_K_gas_temp',[],...
  'pro_o_K_gas_humid',[],'pro_o_K_gas_press','Pressure (mb)','pCO2','pCO_2 (\muatm)');

plt = struct('wetlabs',[],...
             'wetlabs_ntu',[]);
plt.wetlabs={'Chl'};
plt.wetlabs_ntu={'fl_ntu'};

pltTitle = {['PAP mooring  ' dep_name ' Deployment- Chlorophyll-a (\mug/l) at nominal 30m'],...
            ['PAP mooring  ' dep_name ' Deployment- Turbidity at nominal 30m']};
pltUnits = {'Chlorophyll-a (\mug/l)',...
            'Turbidity'};
%% Read in, apply QC  and calculate derived Values
% Read data from MySQL database table
db_tab=[db_table '_wet'];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,flds(1:end-1),pro_o_start_date,end_date,s_str);

if (rows > 0)
  % transfer remaining data into data structure
  for j=1:length(flds)-1
    fld = flds{j};
    % Copy measurements into structure
    wetdat.(fld) = DATA.(fld);
  end
  
  % Calculate QC'd Chlorophyll
  Q = zeros(size(wetdat.fl_chl_ref));
  f1 = find((wetdat.fl_chl_ref<Fl_ref_constant)|...
            (wetdat.fl_chl_ref>(Fl_ref_constant*3))); % arbitary upper limit
  Q(f1) = 4;
  f2 = find(wetdat.fl_chl_ref>22000);
  Q(f2) = 9;
  wetdat.fl_chl(f1)=NaN;
  wetdat.fl_chl(f2)=NaN;

  Fl=Fl_scale.*(wetdat.fl_chl-cwo); % instrument calibration
  wetdat.Chl=(Fl .* chl_slope) + chl_intercept; % bottle calibration
  kkk=find(Q < 2);

  %% Create monthly averages
  numdate_vec = datevec(wetdat.Date_Time);
  mnVar = wetdat.Chl;
  mnVname = 'wetlabs_Chl';
  monthly_average(deploy,start_year,end_year,numdate_vec(qc,:),mnVar,mnVname);
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
      case {'wetlabs'}
        varYlim = [0 2];
    end
    legend_M = [];
    x = cell(1,length(fpl));
    y = x;
    np = 0;
    for j = 1:length(fpl);
      np = np + 1;
      fld = fpl{j};
      x{np} = wetdat.Date_Time;
      y{np} = wetdat.(fld);
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  else
    % If we don't have data, create an 'empty plot' file
    empty_plot(varStr)
  end
  
end

