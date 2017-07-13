function v = setup_var(vname,xType,dep_str,vm,hasqc)
%v = setup_var(vname,xType,dep_str[,v-range])
%  Function to setup structure holding
% variable settings and attributes for OceanSITES netcdf file
%
% vname - standard variable name (string)
%         currently recognises TEMP, CNDC, PSAL, PRES
% xType - NetCDF type of variable (string)
%         currently recognises NC_DOUBLE, NC_FLOAT, NC_INT
% dep_str - Description of sensor depths (string)
%         eg '1m, 30m'
% v-range - (optional) valid range for variable [min max]
% hasqc - (optional) true if a matching QC variable exists
%
% Output v is a structure having fields:
%       xType, dimids (always = [1 2 3 4]) and Atts.
%       Atts is a structure which always has fields:
%         long_name, description, FillValue (dependant on xType),
%         and missing_value(9 or 9999 dependant on xType)
%       If defined, also has:
%         standard_name, units, epic_code, valid_min, valid_max

long_names = struct('TEMP', 'Temperature', ...
                    'CNDC', 'Conductivity', ...
                    'PSAL', 'Practical Salinity', ...
                    'PRES', 'Pressure' ...
                    );
standard_names = struct('TEMP', 'sea_temperature', ...
                        'CNDC', 'electrical_conductivity', ...
                        'PSAL', 'practical_salinity', ...
                        'PRES', 'sea_pressure' ...
                        );
units = struct('TEMP', 'degree_Celsius', ...
               'CNDC', 'mS/cm', ...
               'PSAL', 'practical_salinity', ...
               'PRES', 'dbar' ...
               );
epic_codes = struct('TEMP', int16(20), ...
                    'CNDC', int16(50), ...
                    'PSAL', int16(41), ...
                    'PRES', int16(1) ...
                    );
x_types = struct('NC_DOUBLE', 'double', ...
                 'NC_FLOAT', 'single', ...
                 'NC_INT', 'int32', ...
                 'NC_SHORT', 'int16' ...
                 );
switch vname(end-1:end)
  case 'QC'
    long_name = ['Quality Marker for ' long_names.(vname(1:end-3))];
  otherwise
    long_name = long_names.(vname);
end
if isfield(units,vname)
  description = [long_name ' ' strrep(units.(vname),'_',' ') ' ' 'at ' dep_str];
else
  description = [long_name ' ' 'at ' dep_str];
end
switch xType
  case {'NC_DOUBLE','NC_FLOAT'}
    missing_value = 9999;
  case {'NC_INT','NC_SHORT'}
    missing_value = 9;
  otherwise
    missing_value = 999;
 end
v.xType = xType;
v.dimids = {'TIME' 'DEPTH' 'LAT' 'LON'};
v.Atts.long_name = long_name;
if isfield(standard_names,vname), v.Atts.standard_name = standard_names.(vname); end
v.Atts.description = description;
if isfield(epic_codes,vname), v.Atts.epic_code = epic_codes.(vname); end
if isfield(units,vname), v.Atts.units = units.(vname); end
v.Atts.FillValue = netcdf.getConstant(strrep(xType,'NC_','NC_FILL_'));
v.Atts.missing_value = cast(missing_value,x_types.(xType));
if exist('vm','var') && ~isempty(vm)
  v.Atts.valid_min = cast(vm(1),x_types.(xType));
  v.Atts.valid_max = cast(vm(2),x_types.(xType));
end
if exist('hasqc','var') && hasqc
    v.Atts.ancillary_variables = [vname '_QC'];
end
    

end

