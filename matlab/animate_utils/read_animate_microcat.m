function [ var, meta ] = read_animate_microcat(meta)
%read_animate_microcat Read microcat data from MySQL database into variable
%   Detailed explanation goes here
%% Setup variables
sbodat(1:meta.sbo_nv) = struct('n',0, 'Date_Time',[], ...
                 'temp',[], 'temp_qc',[], 'cond',[], 'cond_qc',[], ...
                 'press',[], 'press_qc',[], 'ox',[],'ox_qc',[]...
                 ); % Measured variables from database
flds = {'Date_Time', 'sbo_temp', 'sbo_temp_qc', 'sbo_cond', 'sbo_cond_qc',...
                   'sbo_press',  'sbo_press_qc', 'sbo_ox', 'sbo_ox_qc'};
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
if meta.sbo_ox==1, fldmap.ox = 'DOX2'; fldmap.ox_qc = 'DOX2_QC'; end
varnms = fieldnames(fldmap);
i = 1;
while i<=length(varnms)
  if strcmpi(varnms{i}(end-1:end),'qc'), varnms(i)=[]; else i=i+1; end
end
have_data = zeros(1,meta.sbo_nv);
last_date = datenum('01-01-1900');
%% Read in Measurmenets from database
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
    % transfer data into sbodat structure
    sbodat(m).Date_Time = DATA.Date_Time;
    last_date = max(last_date,sbodat(m).Date_Time(end));
    for fld=varnms
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
        % Any flagged bad values - set corresponding value to NaN
        sbodat(m).(char(fld))(qc>0) = NaN;
        % Save qc data to sbodat structure
        sbodat(m).([char(fld) '_qc']) = qc;
      else
        sbodat(m).([char(fld) '_qc']) = int16(zeros(1,sbodat(m).n));
      end
    end
    
    % Apply pressure correction
    sbodat(m).press=sbodat(m).press-meta.sbo_press_corr(m);
    
  end % end of 'if sbodat(m).n>0'
end
%% Transfer sbodat to var
% Set number of valid data streams (num_depths) for netcdf output
meta.num_depths = sum(have_data);
% set depth / serial number of missing streams to NaN for later
meta.sbo(have_data==0,:) = NaN;

% Find a single time array for all streams
tmin = NaN(1,meta.num_depths); tmax = tmin; toff = tmin;
% Find the time range for each data stream, starting after deployment start
i = 0;
for m=find(have_data==1)
  i = i + 1;
  tmin(i) = min(tmin(i),min(sbodat(m).Date_Time(sbodat(m).Date_Time>meta.sdatenum)));
  tmax(i) = max([tmax(i),sbodat(m).Date_Time']);
end
tstep = 30./24/60; % set a half hour timestep
t = min(tmin):tstep:max(tmax); % set time series every half hour from first time
meta.nrecs = length(t); % Find length of time series

% Find offset of each time stream from min
for i=1:length(tmin)
  toff(i) = tmin(i) - t(1); % Offset of the time stream from earliest record
  while toff(i) > tstep * .5; % If it's > 15 mins
    toff(i) = toff(i) - tstep; % step back to account for missing record
  end
end
% correct time series for mean offset (times will be at mean of reported times)
toff_mn = mean(toff,'omitnan');
t = t + toff_mn;
% Save time series to var time structure - converted to days since 1950
var.time = NaN(meta.nrecs,1);
var.time(:) = (t-datenum('1950-01-01 00:00:00')); % days since 1/1/1950

% Create remaining dimension variables
var.depth = meta.sbo(have_data==1,1);
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

% Transfer measurements to var structure
flds = fieldnames(fldmap);

for j=1:length(flds)
  fldnm = flds{j};
  varnm = fldmap.(fldnm);
  % Setup empty arrays as 'bad' records - NaN for values, QC=1
  if strcmp(varnm(end-1:end),'QC')
    var.(varnm) = int16(ones(meta.nrecs,meta.num_depths,1,1));
  else
    var.(varnm) = NaN(meta.nrecs,meta.num_depths,1,1);
  end
  i = 0;
  if isfield(sbodat,fldnm) % We haven't done ox, salinity (or potential temp) yet...
    for m=find(have_data==1)
      i = i + 1;
      % At the moment, using nearest! sorts QC values...
      % Use results of intersect to select matching records
      var.(varnm)(t_used(:,i)>0,i,1,1) = sbodat(m).(fldnm)(t_used(t_used(:,i)>0,i));
    end
  end
end

%% Apply QC to measured parameters
% Pressure 1-1799, and not flagged
var.PRES_QC(isNaN(var.PRES)) = 9;
var.PRES_QC(var.PRES>1800 | var.PRES<1) = 4; % bad_data
var.PRES(var.PRES_QC==9) = NaN;

% Temperature >=0.1, <=99, not=22.222
var.TEMP_QC(isNaN(var.TEMP)) = 9; % maybe add | TEMP_QC>1
var.TEMP_QC(var.TEMP==22.222 | var.TEMP>99 | var.TEMP<0.1) = 4;
% var.TEMP(var.TEMP_QC==9) = NaN; % include if use TEMP_QC>1 

% Conductivity >=0.1, <=99, not=22.222
var.CNDC_QC(isNaN(var.CNDC)) = 9; % maybe add | CNDC_QC>1
var.CNDC_QC(var.CNDC==22.222 | var.CNDC>99 | var.CNDC<0.1) = 4;
% var.CNDC(var.CNDC_QC==9) = NaN; % include if use CNDC_QC>1

% If temperature bad, conductivity also bad
var.CNDC_QC(var.TEMP_QC>1) = 4;

if isfield(var.DOX2)
  % Reject all Oxygen values >=10
  var.DOX2_QC(isNaN(var.DOX2)) = 9;
  var.DOX2_QC(var.DOX2 > 9.9) = 4;
end
%% Calculate derived parameters
if isfield(var.DOX2)
  % Calculate Oxygen (/mol)
  var.DOX2 = var.DOX2 * 44.658;
end
% Salinity (& potential temp) need good TEMP, CNDC & PRES
qc = find(var.PRES_QC<1 & var.TEMP_QC<1 & var.CNDC_QC<1);

% Calculate salinity
Tsal = t90tot68(var.TEMP(qc));
var.PSAL(qc) = salinity(var.PRES(qc), Tsal, var.CNDC(qc));
var.PSAL_QC(isnan(var.PSAL)) = 9; % Will be true where not calculated
var.PSAL_QC(var.PSAL< 34.5 | var.PSAL > 35.7) = 5;

% Calculate Potential Temperature
% var.POTEMP(qc) = sigmat(Tsal,var.PSAL(qc));
% var.POTEMP_QC(isnan(var.POTEMP)) = 9;

% % Calculate T compensated Oxygen sat
% sbo_t_rat_1 = 298.15-var.TEMP;
% sbo_t_rat_2 = 273.15+var.TEMP;
% sbo_temp_K_ratio = sbo_t_rat_1./sbo_t_rat_2;
% sbo_temp_scaled = log(sbo_temp_K_ratio);
% 
% s_coeff = (meta.sb0_b(1)+(meta.sb0_b(2).*sbo_temp_scaled)+...
%   (meta.sb0_b(3).*sbo_temp_scaled.^2)+(meta.sb0_b(4).*sbo_temp_scaled.^3));
% 
% var.DOX2_comp = var.DOX2.*(exp((sbodat(m).S.*s_coeff)+(meta.sb0_c0*sbodat(m).S.^2)));
%% change Nans to Fill values - changed to do in oceansites_make_netcdf
% for j=1:length(flds)
%   varnm = fldmap.(flds{j});
%   % Setup 'bad' records - NaN for values, QC=1
%   if ~strcmp(varnm(end-1:end),'QC')
%       var.(varnm)(isnan(var.(varnm))) = 99999.0;
%   end
% end

end

