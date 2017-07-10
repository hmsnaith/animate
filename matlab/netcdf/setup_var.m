function v = setup_var(vname,xType,dep_str,vm)
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
                 'NC_INT', 'int32' ...
                 );
switch vname(1:2)
  case 'QC'
    long_name = ['Quality Marker for ' long_names.(vname(4:end))];
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
  case {'NC_INT'}
    missing_value = 9;
  otherwise
    missing_value = 999;
 end
v.(vname).xType = xType;
v.(vname).dimids = [1 2 3 4];
v.(vname).Atts.long_name = long_name;
if isfield(standard_names,vname), v.(vname).Atts.standard_name = standard_names.(vname); end
v.(vname).Atts.description = description;
if isfield(epic_codes,vname), v.(vname).Atts.epic_code = epic_codes.(vname); end
if isfield(units,vname), v.(vname).Atts.units = units.(vname); end
v.(vname).Atts.FillValue = netcdf.getConstant(strrep(xType,'NC_','NC_FILL'));
v.(vname).Atts.missing_value = cast(missing_value,x_types.(xType));
if exist(vm,'var')
  v.(vname).Atts.valid_min = cast(vm(1),x_types.(xType));
  v.(vname).Atts.valid_max = cast(vm(2),x_types.(xType));
end

end

