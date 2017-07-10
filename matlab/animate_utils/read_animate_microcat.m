function [ var, meta ] = read_animate_microcat(meta)
%read_animate_microcat Read microcat data from MySQL database into variable
%   Detailed explanation goes here
%% Setup variables
sbodat(1:meta.sbo_nv) = struct('n',[],'Date_Time',[],...
                 'temp',[],'temp_qc',[],'cond',[],'cond_qc',[],...
                 'press',[],'press_qc',[],'S',[],'S_qc'...
                 ); % Just get out key variables for now - add others later
%                  'press',[],'press_qc',[],'psal',[],'psal_qc',...
%                  'St',[],'St_qc,[],...
%                  'ox',[],'ox_qc',[],'ox_mol',[],'ox_mol_qc',[],...
%                  'ox_mol_comp',[],'ox_mol_comp_qc',[]...
%                  );
flds = {'Date_Time', 'sbo_temp', 'sbo_temp_qc', 'sbo_cond', 'sbo_cond_qc',...
                     'sbo_press',  'sbo_press_qc'};
%                      'sbo_press',  'sbo_press_qc', ...
%                      'sbo_ox', 'sbo_ox_qc',...
%                      'ox_mol', 'ox_mol_qc','ox_mol_comp', 'ox_mol_comp_qc'};
fldmap = struct(...
         'temp','TEMP',...
         'temp_qc','TEMP_QC',...
         'cond','COND',...
         'cond_qc','COND_QC',...
         'press','PRESS',...
         'press_qc','PRESS_QC',...
         'S','PSAL',...
         'S_qc','PSAL_QC'...
         );
have_data = zeros(1,meta.sbo_nv);
last_date = datenum('01-01-1900');
%% Read in, apply QC and Calculate Derived Values
start_date = datestr(meta.sdate,'yyyy-mm-dd HH:mm:ss');
end_date = datestr(meta.edate,'yyyy-mm-dd HH:mm:ss');
% For each SBO dataset
for m=1:meta.sbo_nv;
  % Read data from MySQL database table
  db_tab=[meta.db_tab '_sbo_' num2str(m)];
  s_str = ' order by Date_Time ASC';
  [DATA, sbodat(m).n] = mysql_animate(db_tab,flds,start_date,end_date,s_str);
  if (sbodat(m).n > 0)
    have_data(m) = 1;
    % transfer data into data structure
    sbodat(m).Date_Time = DATA.Date_Time;
    last_date = max(last_date,sbodat(m).Date_Time(end));
%     for fld={'temp','cond','press','ox'}
    for fld={'temp','cond','press'}
      % Copy basic measurements into data structure
      fldnm = ['sbo_' char(fld)];
      sbodat(m).(char(fld)) = DATA.(fldnm);
      % If qc flags are set - apply to relevant data
      tmp = DATA.([fldnm '_qc']);
      % If all values are null, we ignore them, otherwise
      if ~isempty(tmp)
        % Convert QC cell array to matrix
        qc = int16(tmp);
        if length(qc)<sbodat(m).n % if the QC array is 'short', not all values set
          % Assume all values bad
          qc = int16(ones(1,sbodat(m).n));
          for i=1:sbodat(m).n
            % Loop over all QC values, NULL or 0 are considered good
            if isempty(tmp(i)) || tmp(i)==0, qc(i) = 0; end
          end
        end
        % Any flagged bad values - set to NaN
        sbodat(m).(char(fld))(qc>0) = NaN;
        sbodat(m).([char(fld) '_qc']) = qc;
      else
        sbodat(m).([char(fld) '_qc']) = int16(zeros(1,sbodat(m).n));
      end
    end
    
    % Apply pressure correction
    sbodat(m).press=sbodat(m).press-meta.sbo_press_corr(m);
    
%     % Reject all Oxygen values >=10
%     qc = sbodat(m).ox > 9.9;
%     sbodat(m).ox(qc)=NaN;
        
    % Calculate Salinty
%     sbodat(m).S = salinity(sbodat(m).press, sbodat(m).temp, sbodat(m).cond);
%     sbodat(m).S_qc = int16(zeros(1,sbodat(m).n));
%     sbodat(m).S_qc = find((sbodat(m).S < 34.5) | (sbodat(m).S > 35.7));

%     if (~isempty(sbodat(m).S_qc))
%       disp(' potential out of range SBO salinity');
%       fprintf('    %s\n',datestr(sbodat(m).Date_Time(qc)));
%     end
    
%     % Calculate SigmaT
%     sbodat(m).St = sigmat(sbodat(m).temp,sbodat(m).S);
    
%     % Calculate Oxygen (/mol)
%     sbodat(m).ox_mol = sbodat(m).ox * 44.658;
%     
%     % Calculate T compensated Oxygen sat for all valid Oxygen values
%     sbo_t_rat_1 = 298.15-sbodat(m).temp;
%     sbo_t_rat_2 = 273.15+sbodat(m).temp;
%     sbo_temp_K_ratio = sbo_t_rat_1./sbo_t_rat_2;
%     sbo_temp_scaled = log(sbo_temp_K_ratio);
%     
%     s_coeff =(b0+(b1.*sbo_temp_scaled)+(b2.*sbo_temp_scaled.^2)+(b3.*sbo_temp_scaled.^3));
%     
%     sbodat(m).ox_mol_comp = sbodat(m).ox_mol.*(exp((sbodat(m).S.*s_coeff)+(c0*sbodat(m).S.^2)));
%     sbodat(m).ox_mol_comp(isnan(sbodat(m).ox)) = NaN;
    
  end % end of 'if sbodat(m).n>0'
end
%% Transfer sbodat to var
% Set number of valid data streams (num_depths)
meta.num_depths = sum(have_data);
% set depth / serial number of missing streams to NaN for later
meta.sbo(have_data==0,:) = NaN;

% Find a single time array
tmin = NaN(1,meta.num_depths); tmax = tmin; toff = tmin;
i = 0;
for m=find(have_data==1)
  i = i + 1;
  tmin(i) = min(tmin(i),min(sbodat(m).Date_Time(sbodat(m).Date_Time>meta.sdate)));
  tmax(i) = max([tmax(i),sbodat(m).Date_Time']);
end
tstep = 30./24/60; % half hour timestep
t = min(tmin):tstep:max(tmax);
% Find offset of each time stream from min
for i=1:length(tmin)
  toff(i) = tmin(i) - t(1);
  while toff(i) > tstep * .5;
    toff(i) = toff(i) - tstep;
  end
end

% Transfer to var structure
flds = fieldnames(fldmap);

for j=1:length(flds)
  fldnm = flds{j};
  varnm = fldmap(fldnm);
  % Setup 'bad' records - NaN for values, QC=1
  if strcmp(varnm(end-1:end),'QC')
    var.(varnm) = int16(ones(length(t),meta.num_depths,1,1));
  else
    var.(varnm) = NaN(length(t),meta.num_depths,1,1);
  end
  i = 0;
  if isfield(sbodat,fldnm) % We haven't done salinity (or potential temp) yet...
    for m=find(have_data==1)
      i = i + 1;
      % At the moment, using nearest! sorts QC values...
      var.(varnm)(:,i,1,1) = interp1(sbodat(m).Date_Time,sbodat(m).(fldnm),t,'nearest','extrap')';
    end
  end
end

%% Apply QC
% Pressure 1-1799, and not flagged
var.PRESS_QC(var.PRESS>1800 || var.PRESS<1 || var.PRESS_QC>1) = 9;
var.PRESS(var.PRESS_QC==9) = NaN;

% Temperature >=0.1, <=99, not=22.222
var.TEMP_QC(var.TEMP==22.222 || var.TEMP>99 || var.TEMP<0.1) = 9;
var.TEMP(var.TEMP_QC==9) = NaN;

% Conductivity >=0.1, <=99, not=22.222
var.COND_QC(var.COND==22.222 || var.COND>99 || var.COND<0.1) = 9;
var.COND(var.COND_QC==9) = NaN;

% If temperature bad, conductivity also bad
var.COND(var.TEMP_QC>1) = NaN;

% Salinity (& potenital temp) need good TEMP, COND & PRESS
var.PSAL_QC(:,:,:,:) = 9;
% var.POTEMP_QC(:,:,:,:) = 9;
qc = find(var.PRESS_QC<1 && var.TEMP_QC<1 || var.COND_QC<1);
%   var.POTEMP(qc) = NaN;
%   var.POTEMP_QC(qc) = 9;

Tsal = t90tot68(var.TEMP(qc));
var.PSAL(qc) = salinity(var.PRESS(qc), Tsal, var.COND(qc));
% var.POTEMP(qc) =sigmat(Tsal,var.PSAL(qc));

%% change Nans to Fill values
for j=1:length(flds)
  varnm = fldmap(flds{j});
  % Setup 'bad' records - NaN for values, QC=1
  if ~strcmp(varnm(end-1:end),'QC')
      var.(varnm)(isnanvar.(varnm)) = 99999.0;
  end
end

end

