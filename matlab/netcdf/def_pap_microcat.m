
function [v, meta] = def_pap_microcat(meta)
%def_microcats Define variables in a pap microcats OceanSITES netCDF file
%   Generate structure array, v, of variable description for OceanSITES
%   netCDF CTD (microcats) file for PAP site

% Find which instruments we have data for
have_data = ~isnan(meta.sbo(:,1));

% dep_str used to set comments and long names
meta.dep_str = num2str(meta.sbo(have_data,1)','%dm ');
meta.dep_str = strtrim(meta.dep_str);
% if length(meta.sbo)>1
  sp = strfind(meta.dep_str,' ');
if ~isempty(sp)
  meta.dep_str = [meta.dep_str(1:sp(end)) '& ' meta.dep_str(sp(end)+1:end)];
end

% Instrument data - from set_mooring values
if isfield(meta,'sbo_sensor_model')
  instr.sensor_model = strjoin(meta.sbo_sensor_model(have_data),', '); end
if isfield(meta,'sbo_sensor_manufacturer')
  instr.sensor_manufacturer = meta.sbo_sensor_manufacturer; end
if isfield(meta,'sbo_sensor_reference')
  instr.sensor_reference = strjoin(meta.sbo_sensor_reference(have_data),', '); end
instr.sensor_serial_number = strtrim(strjoin(cellstr(num2str(meta.sbo(have_data,2))),', '));
if isfield(meta,'sbo_sensor_model')
  instr.sensor_mount = meta.sbo_sensor_mount; end
if isfield(meta,'sbo_sensor_orientation')
  instr.sensor_orientation = meta.sbo_sensor_orientation; end
% Dummy structure of instrument metadata for QC variables
instr_qc = struct();
%% Set up variable types and standard attributes
vname = 'TEMP'; v.(vname) = def_var(vname,'NC_FLOAT',meta.dep_str,[2.0 100.],instr,1);
% v.(vname).Atts.uncertainty = ;
v.(vname).Atts.accuracy = 0.003;
% v.(vname).Atts.precision = ;
v.(vname).Atts.resolution = 0.001;
vname = 'TEMP_QC'; v.(vname) = def_var(vname,'NC_BYTE',meta.dep_str,[0 9],instr_qc);

vname = 'CNDC'; v.(vname) = def_var(vname,'NC_FLOAT',meta.dep_str,[25 45],instr,1);
% v.(vname).Atts.uncertainty = ;
v.(vname).Atts.accuracy = 0.02;
% v.(vname).Atts.precision = ;
v.(vname).Atts.resolution = 0.001;
vname = 'CNDC_QC'; v.(vname) = def_var(vname,'NC_BYTE',meta.dep_str,[0 9],instr_qc);

vname = 'PRES'; v.(vname) = def_var(vname,'NC_FLOAT',meta.dep_str,[0. 6000.],instr,1);
% v.(vname).Atts.uncertainty = ;
v.(vname).Atts.accuracy = 0.25;
% v.(vname).Atts.precision = ;
v.(vname).Atts.resolution = 0.03;
vname = 'PRES_QC'; v.(vname) = def_var(vname,'NC_BYTE',meta.dep_str,[0 9],instr_qc);

vname = 'PSAL'; v.(vname) = def_var(vname,'NC_FLOAT',meta.dep_str,[29. 40.],instr,1);
% v.(vname).Atts.uncertainty = ;
v.(vname).Atts.accuracy = 0.25;
% v.(vname).Atts.precision = ;
v.(vname).Atts.resolution = 0.03;
v.(vname).Atts.reference_scale = 'PSS-78';
vname = 'PSAL_QC'; v.(vname) = def_var(vname,'NC_BYTE',meta.dep_str,[0 9],instr_qc);

% If this set of microcats has oxygen - setup Oxygen variable
% if strcmp(meta.data_type,'CTDO')
if meta.sbo_ox==1
  vname = 'DOXY'; v.(vname) = def_var(vname,'NC_FLOAT',meta.dep_str,[1. 446.],instr,1);
  v.(vname).Atts.comment = [v.(vname).Atts.comment ' Measured in ml/l converted to micromole/kg'];
  % v.(vname).Atts.uncertainty = ;
  v.(vname).Atts.accuracy = 8.;
  v.(vname).Atts.precision = 5.;
  v.(vname).Atts.resolution = 1;
  vname = 'DOXY_QC'; v.(vname) = def_var(vname,'NC_BYTE',meta.dep_str,[0 9],instr_qc);
end
%% Additional attributes that need to be set up
meta.time_coverage_resolution = 'PT30M';
% if strcmp(meta.data_type,'CTDO')
if meta.sbo_ox==1
  meta.properties = 'Pressure, Temperature, Conductivity, Salinity and Oxygen';
  meta.keywords = 'Pres_SL, WC_Temp, WC_Sal, WC_O2, http://vocab.nerc.ac.uk/collection/P01/current/PRESPS02/, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/, http://vocab.nerc.ac.uk/collection/P02/current/DOXY/'; %-> def_pap_microcats
else
  meta.properties = 'Pressure, Temperature, Conductivity and Salinity';
  meta.keywords = 'Pres_SL, WC_Temp, WC_Sal, http://vocab.nerc.ac.uk/collection/P01/current/PRESPS02/, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/'; %-> def_pap_microcats
end
end
