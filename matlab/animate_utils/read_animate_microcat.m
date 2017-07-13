function [ var, meta ] = read_animate_microcat(meta)
%read_animate_microcat Read microcat data from MySQL database into variable
%   Detailed explanation goes here
%% Setup variables
sbodat(1:meta.sbo_nv) = struct('n',0, 'Date_Time',[], ...
                 'temp',[], 'temp_qc',[], 'cond',[], 'cond_qc',[], ...
                 'press',[], 'press_qc',[] ...
                 ); % Just get out key variables for now - add others later
%                  'press',[],'press_qc',[],'S',[],'S_qc',...
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
         'cond','CNDC',...
         'cond_qc','CNDC_QC',...
         'press','PRES',...
         'press_qc','PRES_QC',...
         'PSAL','PSAL',...
         'PSAL_QC','PSAL_QC'...
         );
have_data = zeros(1,meta.sbo_nv);
last_date = datenum('01-01-1900');
%% Read in, apply QC and Calculate Derived Values
start_date = datestr(meta.sdatenum,'yyyy-mm-dd HH:MM:SS');
end_date = datestr(meta.edatenum,'yyyy-mm-dd HH:MM:SS');
% For each SBO dataset
for m=1:meta.sbo_nv;
  % Read data from MySQL database table
  db_tab=[meta.db_table '_sbo_' num2str(m)];
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
  tmin(i) = min(tmin(i),min(sbodat(m).Date_Time(sbodat(m).Date_Time>meta.sdatenum)));
  tmax(i) = max([tmax(i),sbodat(m).Date_Time']);
end
tstep = 30./24/60; % half hour timestep
t = min(tmin):tstep:max(tmax);
meta.nrecs = length(t);

% Find offset of each time stream from min
for i=1:length(tmin)
  toff(i) = tmin(i) - t(1);
  while toff(i) > tstep * .5;
    toff(i) = toff(i) - tstep;
  end
end
% correct time variable for mean offset
toff_mn = mean(toff,'omitnan');
t = t + toff_mn;
var.time = NaN(meta.nrecs,1);
var.time(:) = (t-datenum('1970-01-01 00:00:00'))*24*60*60; % time since xxx in seconds

% Create remaining dimension variables
var.depth = meta.sbo(have_data==1,2);
var.lat = meta.anchor_lat;
var.lon = meta.anchor_lon;

% Find the closest matching times in each stream to the new time array
t_used = zeros(meta.nrecs,meta.num_depths);
i = 0;
t = int32((t-toff_mn)*24*60); % time in minutes
for m=find(have_data==1)
  i=i+1;
  t_s = int32((sbodat(m).Date_Time-toff(i))*24*60);
  [~, is, it] = intersect(t_s,t);
  t_used(it,i) = is;
end

% Transfer to var structure
flds = fieldnames(fldmap);

for j=1:length(flds)
  fldnm = flds{j};
  varnm = fldmap.(fldnm);
  % Setup 'bad' records - NaN for values, QC=1
  if strcmp(varnm(end-1:end),'QC')
    var.(varnm) = int16(ones(meta.nrecs,meta.num_depths,1,1));
  else
    var.(varnm) = NaN(meta.nrecs,meta.num_depths,1,1);
  end
  i = 0;
  if isfield(sbodat,fldnm) % We haven't done salinity (or potential temp) yet...
    for m=find(have_data==1)
      i = i + 1;
      % At the moment, using nearest! sorts QC values...
      % var.(varnm)(:,i,1,1) = interp1(sbodat(m).Date_Time,sbodat(m).(fldnm),var.TIME,'nearest','extrap')';
      % Use results of intersect to select matching records
      var.(varnm)(t_used(:,1)>0,i,1,1) = sbodat(m).(fldnm)(t_used(t_used(:,1)>0,1));
    end
  end
end

%% Apply QC
% Pressure 1-1799, and not flagged
var.PRES_QC(var.PRES>1800 | var.PRES<1 | var.PRES_QC>1) = 9;
var.PRES(var.PRES_QC==9) = NaN;

% Temperature >=0.1, <=99, not=22.222
var.TEMP_QC(var.TEMP==22.222 | var.TEMP>99 | var.TEMP<0.1) = 9;
var.TEMP(var.TEMP_QC==9) = NaN;

% Conductivity >=0.1, <=99, not=22.222
var.CNDC_QC(var.CNDC==22.222 | var.CNDC>99 | var.CNDC<0.1) = 9;
var.CNDC(var.CNDC_QC==9) = NaN;

% If temperature bad, conductivity also bad
var.CNDC(var.TEMP_QC>1) = NaN;

%% Calculate derived parameters
% Salinity (& potenital temp) need good TEMP, CNDC & PRES
qc = find(var.PRES_QC<1 & var.TEMP_QC<1 & var.CNDC_QC<1);
%   var.POTEMP(qc) = NaN;
%   var.POTEMP_QC(qc) = 9;

Tsal = t90tot68(var.TEMP(qc));
var.PSAL(qc) = salinity(var.PRES(qc), Tsal, var.CNDC(qc));
var.PSAL_QC(isnan(var.PSAL)) = 9;
% var.POTEMP(qc) =sigmat(Tsal,var.PSAL(qc));

%% change Nans to Fill values
for j=1:length(flds)
  varnm = fldmap.(flds{j});
  % Setup 'bad' records - NaN for values, QC=1
  if ~strcmp(varnm(end-1:end),'QC')
      var.(varnm)(isnan(var.(varnm))) = 99999.0;
  end
end

end

