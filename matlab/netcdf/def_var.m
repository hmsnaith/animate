function v = def_var(vname,xType,dep_str,vm,instr,hasqc)
%v = def_var(vname,xType,dep_str,instr[,hasqc])
%  Function to define structure holding
% variable settings and attributes for OceanSITES netcdf file
%
% vname - standard variable name (string)
%         currently recognises TEMP, CNDC, PSAL, PRES
% xType - NetCDF type of variable (string)
%         currently recognises NC_DOUBLE, NC_FLOAT, NC_INT
% dep_str - Description of sensor depths (string)
%         eg '1m, 30m'
% vm - valid range for variable [min max]
% instr - structure of instrument metadata with optional fields:
%         sensor_model
%         sensor_manufacturer
%         sensor_reference
%         sensor_serial_number
%         sensor_mount
%         sensor_orientation
% hasqc - (optional) true if a matching QC variable (vname_QC) exists
%
% Output v is a structure having fields:
%       xType, dimids (always = {'TIME' 'DEPTH' 'LAT' 'LON'}) and Atts.
%          note : to get c ordering correct, we actually set dimids as
%             {'LON' 'LAT' 'DEPTH' 'TIME'}
%       Atts is a structure which always has fields:
%         long_name
%         comment
%         FillValue (dependant on xType),
%        [ and missing_value (9 or 9999 dependant on xType) ] - not set
%         coordinates = 'time depth latitude longitude'
%         cell_methods = 'TIME: point DEPTH: point';
%         DM_indicator = 'R'
%       Non-QC variables have additional attributes:
%         processing_level (dependant on xType),
%         ancillary_variables (is hasqc set),
%       If defined, also has:
%         standard_name, units, valid_min, valid_max
%         and input instrument metadata
%       QC variables have attributes:
%         flag_values ([0:9])
%         flag_meanings (oceansite_ref_table - table2 values)

long_names = struct('TEMP', 'Temperature', ...
                    'CNDC', 'Conductivity', ...
                    'PSAL', 'Practical Salinity', ...
                    'PRES', 'Pressure', ...
                    'DOXY', 'Dissolved Oxygen' ...
                    );
standard_names = struct('TEMP', 'sea_water_temperature', ...
                        'CNDC', 'sea_water_electrical_conductivity', ...
                        'PSAL', 'sea_water_practical_salinity', ...
                        'PRES', 'sea_water_pressure', ...
                        'DOXY', 'moles_of_oxygen_per_unit_mass_in_sea_water' ...
                        );
units = struct('TEMP', 'degree_Celsius', ...
               'CNDC', 'mS/cm', ...
               'PSAL', '1e-3', ...
               'PRES', 'dbar', ...
               'DOXY', 'micromole/kg' ...
               );
x_types = struct('NC_DOUBLE', 'double', ...
                 'NC_FLOAT', 'single', ...
                 'NC_INT', 'int32', ...
                 'NC_SHORT', 'int16', ...
                 'NC_BYTE', 'int8' ...
                 );
[OS_tab2, OS_tab3] = oceansites_ref_tables;

switch vname(end-1:end)
  case 'QC'
    long_name = ['Quality Flag for ' long_names.(vname(1:end-3))];
    flag_values = 0:9;
    flag_meanings = strjoin(OS_tab2);
  otherwise
    long_name = long_names.(vname);
    processing_level = OS_tab3{2};
end
if isfield(units,vname)
  description = [long_name ' (' strrep(units.(vname),'_',' ') ') at nominal depths ' dep_str];
else
  description = [long_name ' at nominal depths' dep_str];
end
% Don't use missing_value - use this instead of default _FillValue?
% switch xType
%   case {'NC_DOUBLE','NC_FLOAT'}
%     missing_value = 9999;
%   case {'NC_INT','NC_SHORT','NC_BYTE'}
%     missing_value = 9;
%   otherwise
%     missing_value = 999;
%  end
v.xType = xType;
v.dimids = {'LONGITUDE' 'LATITUDE' 'DEPTH' 'TIME'};
if isfield(standard_names,vname), v.Atts.standard_name = standard_names.(vname); end
if isfield(units,vname), v.Atts.units = units.(vname); end
v.Atts.FillValue = netcdf.getConstant(strrep(xType,'NC_','NC_FILL_'));
v.Atts.coordinates = 'TIME DEPTH LATITUDE LONGITUDE';
v.Atts.long_name = long_name;
% v.Atts.QC_indicator = meta.OS_tab2{2}; % reset on read?
if exist('processing_level','var'), v.Atts.processing_level = processing_level; end% reset on read?
if exist('vm','var') && ~isempty(vm)
  v.Atts.valid_min = cast(vm(1),x_types.(xType));
  v.Atts.valid_max = cast(vm(2),x_types.(xType));
end
v.Atts.comment = description;
if exist('hasqc','var') && hasqc
    v.Atts.ancillary_variables = [vname '_QC'];
end
switch vname(end-1:end)
  case 'QC'
    if exist('flag_values','var'), v.Atts.flag_values = cast(flag_values,x_types.(xType)); end
    if exist('flag_meanings','var'), v.Atts.flag_meanings = flag_meanings; end
  otherwise
    v.Atts.cell_methods = 'TIME: point DEPTH: point';
    v.Atts.DM_indicator = 'R'; % assume real time - change to DM in calling routine if different
    atts = fieldnames(instr);
    if length(atts) > 1;
      for i=1:length(atts); v.Atts.(atts{i}) = instr.(atts{i}); end
    end
end
end

