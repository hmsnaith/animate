% Script to plot sbo data from MySQL table

%% Setup variables
sbodat(1:sbo_nv) = struct('n',[],'Date_Time',[],'temp',[],'cond',[],'press',[],...
                     'S',[],'St',[],'ox',[],'ox_mol',[],'ox_mol_comp',[]);
flds = {'Date_Time', 'sbo_temp', 'sbo_cond', 'sbo_press','sbo_ox',...
        'sbo_temp_qc', 'sbo_cond_qc','sbo_press_qc', 'sbo_ox_qc'};
param = struct('temp','Temperature \circC','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen on Seabird microcat','ox_mol','Oxygen on Seabird microcat',...
               'ox_mol_comp','Salinity compensated Oxygen on Seabird microcat');
units = struct('temp','Temperature \circC','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen (ml/l)','ox_mol','Oxygen (\mumol/l)',...
               'ox_mol_comp','Sal. comp. O_2 (\mumol)' );
have_data = 0;
last_date = datenum('01-01-1900');
%% Read in, apply QC and Calculate Derived Values
% For each SBO dataset
for m=1:sbo_nv;
  % Read data from MySQL database table
  db_tab=[db_table '_sbo_' num2str(m)];
  s_str = ' order by Date_Time ASC';
  [DATA, sbodat(m).n] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
  
  if (sbodat(m).n > 0)
    have_data = have_data + 1;
    % transfer data into data structure
    sbodat(m).Date_Time = DATA.Date_Time;
    last_date = max(last_date,sbodat(m).Date_Time(end));
    for fld={'temp','cond','press','ox'}
      % Copy basic measurements into data structure
      fldnm = ['sbo_' char(fld)];
      sbodat(m).(char(fld)) = DATA.(fldnm);
      % If qc flags are set - apply to relevant data
      tmp = DATA.([fldnm '_qc']);
      % If all values are null, we ignore them, otherwise
      if ~isempty(tmp)
        % Convert QC cell array to matrix
        qc = tmp;
        if length(qc)<sbodat(m).n % if the QC array is 'short', not all values set
          % Assume all values bad
          qc = ones(1,sbodat(m).n);
          for i=1:sbodat(m).n
            % Loop over all QC values, NULL or 0 are considered good
            if isempty(tmp(i)) || tmp(i)==0, qc(i) = 0; end
          end
        end
        % Any flagged bad values - set to NaN
        sbodat(m).(char(fld))(qc>0) = NaN;
      end
    end
    
    % Apply pressure correction
    sbodat(m).press=sbodat(m).press-sbo_press_corr(m);
    
    % Reject all Oxygen values >=10
    qc = sbodat(m).ox > 9.9;
    sbodat(m).ox(qc)=NaN;
        
    % Calculate Salinty
    sbodat(m).S = salinity(sbodat(m).press, sbodat(m).temp, sbodat(m).cond);
    
    qc = find((sbodat(m).S < 34.5) | (sbodat(m).S > 35.7));
    if (~isempty(qc))
      disp(' potential out of range SBO salinity');
      fprintf('    %s\n',datestr(sbodat(m).Date_Time(qc)));
      sbodat(m).S(qc)=NaN;
    end
    
    % Calculate SigmaT
    sbodat(m).St = sigmat(sbodat(m).temp,sbodat(m).S);
    
    % Calculate Oxygen (/mol)
    sbodat(m).ox_mol = sbodat(m).ox * 44.658;
    
    % Calculate T compensated Oxygen sat for all valid Oxygen values
    sbo_t_rat_1 = 298.15-sbodat(m).temp;
    sbo_t_rat_2 = 273.15+sbodat(m).temp;
    sbo_temp_K_ratio = sbo_t_rat_1./sbo_t_rat_2;
    sbo_temp_scaled = log(sbo_temp_K_ratio);
    
    s_coeff =(b0+(b1.*sbo_temp_scaled)+(b2.*sbo_temp_scaled.^2)+(b3.*sbo_temp_scaled.^3));
    
    sbodat(m).ox_mol_comp = sbodat(m).ox_mol.*(exp((sbodat(m).S.*s_coeff)+(c0*sbodat(m).S.^2)));
    sbodat(m).ox_mol_comp(isnan(sbodat(m).ox)) = NaN;
    
  end % end of 'if sbodat(m).n>0'
  % end of data input
  %% Create monthly averages
  % monthly averages
  numdate_vec = datevec(sbodat(m).Date_Time);
  for fld = {'temp','S','ox_mol','ox_mol_comp'}
    mnVar = sbodat(m).(char(fld));
    mnVname=['sbo_' char(fld) num2str(sbo(m,2))];
    monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  end
end % End SBO dataset loop

%% Plot data
% Set legend string
legend_M = num2str(sbo,'Nom %2i (sbo %5i)');

% Set Y limits for variables
flds = fieldnames(param);
for i = 1:length(flds);
  fld = flds{i};
  switch fld
    case 'ox'
      varYlim=sboYlim;
    otherwise
      varYlim=[];
  end
  
  % Set plot (variable) name
  varStr = ['sbo_' fld];
  
  % If we have data - plot and print graphs
  if have_data > 0
    x = cell(1,sbo_nv);
    y = x;
    varTitle = {['PAP ' dep_name ' Deployment:  ' param.(fld)]; ...
               ['Latest data: ' datestr(last_date)]};
    y_lab = units.(fld);
    
    for m=1:sbo_nv
      x{m} = sbodat(m).Date_Time;
      y{m} = sbodat(m).(fld);
    end
    animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y);
  % If we don't have data, create an 'empty plot' file
  else
    empty_plot(varStr)
  end
end
    
    


