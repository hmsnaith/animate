% Script to plot Pro-Oceanus data from MySQL table

%% Setup variables
prodat = struct('numdate',[],'pro_o_conc',[],'pro_o_cell_temp',[],'pro_o_AZPC',[],...
  'pro_o_raw_co2',[],'pro_o_gas_temp',[],...
  'pro_o_gas_humid',[],'pro_o_gas_press',[],'time_diff',[]);
flds = fieldnames(prodat);
% Set plot (variable) name
varStr = 'pro_o_conc';
%% Read in and Calculate Values
% Read data from MySQL database table
db_tab=[db_table '_gas'];
s_str = ' order by Date_Time ASC';
[DATA, rows] = mysql_animate(db_tab,pro_o_start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  prodat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    prodat.(fld) = cell2mat({DATA(:).(fld)});
  end
  
  qc = find((pro_o_conc>50));
  pCO2 = prodat.pro_o_conc.*(prodat.pro_o_gas_press/1013.25);
  
  kk1= find(pCO2<100);
  pCO2(kk1)=NaN;
  kzkz=find(pro_o_gas_tdiff> 40000);
  pro_o_numdate_last=prodat.numdate(kzkz(end));
  pCO2_last=pCO2(kzkz(end));
  
  % monthly averages
  numdate_vec=datevec(pro_o_numdate_last);
  mnVar=pCO2_last;
  mnVname='pCO2_30';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  
  %% Plot data
  % Set legend string
  legend_M = {'xCO_2 (ppm)','pCO_2 (\muatm)'};
  
  % Set Y limits for variables
  varYLim = [250 400];
  
  % If we have data - plot and print graphs
  x = {prodat.numdate, prodat.numdate};
  y = {prodat.pro_o_conc, pCO2};
  varTitle = {'Pro-Oceanus data - Carbon Dioxide at 30m.',...
    ['Latest data: ' datestr(pro_o_numdate(rows))]};
  y_lab = units.(fld);
  
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
else
  % If we don't have data, create an 'empty plot' file
  empty_plot(varStr)
end

% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_pressure.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_pressure.png']);
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_diff_1.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_diff_1.png']);
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_diff_2.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_diff_2.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_raw_co2.png']);
%
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_raw_co2.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_conc_2.png']);
%
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_conc_2.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_conc_3.png']);
%
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_conc_3.png']);
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',16);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% saveas(gcf,[webdir 'pro_o_AZPC.png']);
%
%
% plot(1,1);
% text(0.4,1,'Plot Not Yet Available','fontsize',6);
% axis off
% set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% saveas(gcf,[webdir 'small_pro_o_AZPC.png']);

