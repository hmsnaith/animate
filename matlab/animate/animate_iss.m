% Script to plot isus data from MySQL table

%% Setup variables
issdat = struct('numdate',[],'isus_n',[],'isus_n_rms',[],'isus_average',[],...
                'isus_temp1',[],'isus_humidity',[],...
                'isus_volt',[],'isus_dark_calc',[],'time_diff',[]);
flds = fieldnames(issdat);
% Set plot (variable) name
varStr = 'isus_n';
%% Read in and Calculate Values
% Read data from MySQL database table
db_tab=[db_table '_iss'];
s_str = ' order by Date_Time DESC';
[DATA, rows] = mysql_animate(db_tab,start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  issdat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    issdat(m).(fld) = cell2mat({DATA(:).(fld)});
  end
  %
  %   iss_count = 0;
  %   iss_mean  = 0;
  %   iss_mean_time = 0;
  %   j = 1;
  %   for i = 1:(rows-1);
  %     % reshape and calculate mean
  %     iss_count = iss_count + 1;
  %     iss_mean  = iss_mean  + issdat.isus_n(i);
  %     iss_mean_time = iss_mean_time + issdat.numdate(i);
  %     if (issdat.numdate(i)-issdat.numdate(i+1))>=(1/48)
  %       isus_mean(j) = iss_mean / iss_count; %#ok<SAGROW>
  %       isus_mean_time(j)=iss_mean_time/iss_count; %#ok<SAGROW>
  %       j = j + 1;
  %       iss_count = 0;
  %       iss_mean  = 0;
  %       iss_mean_time = 0;
  %     end
  %   end
  %
  %   iss_count = iss_count+1;
  %   iss_mean  = iss_mean+issdat.isus_n(rows);
  %   iss_mean_time = iss_mean_time + issdat.numdate(rows);
  %   isus_mean(j)  = iss_mean/iss_count;
  %   isus_mean_time(j) = iss_mean_time/iss_count;
  t_diff = -diff(issdat.numdate);
  gaps = [1 find(t_diff >= (1/48)) rows];
  ng = length(gaps)-1;
  
  iss_mean = NaN(1,ng);
  iss_mean_time = iss_mean;
  iss_count = iss_mean;
  
  for i=1:ng
    iss_mean(i) = mean(issdat.isus_n(gaps(i:i+1)));
    iss_mean_time(i) = mean(issdat.numdate(gaps(i:i+1)));
    iss_count(i) = length(gaps(i):gaps(i+1));
  end
  % end of data input
  %% Create monthly averages
  % monthly averages
  numdate_vec = datevec(iss_mean_time);
  mnVar = isus_mean;
  mnVname='isis_N';
  monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  
  %% Plot data
  % Set legend string
  legend_M = {'Readings','Average '};
  
  % Set Y limits for variables
  varYlim=0;
  
  % Set legend string
  varTitle = {'ISUS data - Nitrate concentration in \muMol/litre.',...
             ['Latest data: ' datestr(issdat.numdate(1))]};
  % Set y label string
  ylabel('\muMol_/litre');
  
  x = {issdat.numdate, isus_mean_time};
  y = {issdat.isus_n, isus_mean};
  
% plot and print graphs
  animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
else
  empty_plot(varStr)
end
