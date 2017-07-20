function oceansites_make_netcdf(ffn,g,d,v,dat)
% make_oceansites_netcdf(ffn,g,d,v,dat)
% Create OceanSITES netCDF file
%
% ffn: Filename - including path
% g: Structure array of Global Attributes.
%       g.AttName = Attribute Value;
% d: Structure array of Dimensions in the order to be defined.
%       d.dimName = dimension size
% v: Structure array od Variable definitions and Attributes.
%       v.varName has fields:
%         xType - netcdF data type (NC_DOUBLE etc)
%         dimids - dimension ids of variable
%         Atts - structure array of attributes, as for g
% dat: Structure containing Variable data arrays. Must have fieldnames
%      matching variables defined, with matching dimensions

disp('in make_oceansites_netcdf');
%% Setup netCDF variables
NC_GLOBAL=netcdf.getConstant('NC_GLOBAL');

%% Create netcdf file
% Split full path into filename consitutents
[OS_dir, fn, ft] = fileparts(ffn);
% Generate OceanSITES netCDF file name from file name parts
OS_name = [fn ft];
% if the OceanSITES directory exists - cd to that directory
if ~exist(OS_dir,'dir')
%   cd(OS_dir);
% else % If it doesn't exist, raise an error
  error(['OceanSITES directory ' OS_dir ' does not exist']);
end

% Set netcdf version to use - if specified as >v3, use 4.0
ncVersion = sscanf(g.netcdf_version,'%d');
if ncVersion > 3
  ncVer='NETCDF4';
else % if not specified, or not set >3, default to 3.5
  ncVer='CLASSIC_MODEL';
end
ncMode = netcdf.getConstant(ncVer);

% If the file already exists - we overwrite
if exist(ffn,'file')
  disp(['Overwriting netcdf file ' OS_name ' in ' OS_dir]);
  ncMode = bitor(ncMode,netcdf.getConstant('NC_CLOBBER'));
else % otherwise, create a new file
  disp(['Creating netcdf file ' OS_name ' in ' OS_dir]);
end
scope = netcdf.create(ffn,ncMode);

%% Write Global Attributes
attNames = fieldnames(g);
for i=1:length(attNames)
  attName = attNames{i};
  netcdf.putAtt(scope,NC_GLOBAL,attName,g.(attName));
end

%% Define Dimensions
dimNames = fieldnames(d);
for i=1:length(dimNames)
  dimName = dimNames{i};
  netcdf.defDim(scope,dimName,d.(dimName));
  % Ideally save dimIds here
  dimids.(dimName) = netcdf.inqDimID(scope,dimName);
end

%% Define Variables and Variable Attributes
varNames = fieldnames(v);
for i=1:length(varNames)
  varName = varNames{i};
  varIn = v.(varName);
  % Convert varIn.dimids (dimension names) to dimension ids
  ndims = length(varIn.dimids);
  dims = NaN(1,ndims);
  for j=1:ndims, dims(j)=dimids.(varIn.dimids{j}); end
  varid = netcdf.defVar(scope,varName,varIn.xType,dims);
  attNames = fieldnames(varIn.Atts);
  for j=1:length(attNames)
    attName = attNames{j};
    if strcmp(attName,'FillValue'), attName = '_FillValue'; end
    netcdf.putAtt(scope,varid,attName,varIn.Atts.(attNames{j}));
  end
end

%% Close definition mode for file
netcdf.endDef(scope);

%% Write data into variables
for i=1:length(varNames)
  varName = varNames{i};
  varid = netcdf.inqVarID(scope,varName);
  netcdf.putVar(scope,varid,dat.(varName));
end

%% Close netCDF file
netcdf.close(scope);

return
