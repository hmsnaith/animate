function [g,d,v] = oceansites_create_params(meta)

% Create the global attributes for an OceanSITES format netCDF file

%% Set some conversion info
osite_dfmt = 'yyyy-mm-ddTHH:MM:SSZ'; % All dates / times should be in oceansites date/time format
data_mode = struct('R', 'Real Time ', ...
                   'P', 'Provisional ', ...
                   'D', 'Delayed-mode ', ...
                   'M', 'Mixed ');
%% Discovery and identification - common to all data types
g.site_code = meta.os_site_code; % [req] Name of the site within OceanSITES project. The site codes are available on GDAC ftp servers (GDAC)
g.platform_code = meta.os_platform_code; % [req] The unique platform code, assigned by an OceanSITES project (GDAC)
g.data_mode = meta.mode; % [req] Indicates if the file contains real-time, provisional or delayed- mode data. The list of valid data modes is in reference table 4 (GDAC)
g.title = [data_mode.(meta.mode) 'OceanSITES ' meta.os_site_code ' in-situ data']; % Free-format text describing the dataset, for use by human readers. Use the file name if in doubt (NUG)
g.summary = ['Oceanographic mooring data from ' meta.os_site_code ' observatory in the ' meta.data_area '.']; % Longer free-format text describing the dataset. This attribute should allow data discovery for a human reader. A paragraph of up to 100 words is appropriate. (ACDD)
if isfield(meta,'project_title'), g.summary = [g.summary ' Collected under ' meta.project_title '.']; end
if isfield(meta,'project_contract'), g.summary = [g.summary ' ' meta.project_contract '.']; end
g.naming_authority = 'OceanSITES'; % The organization that manages data set names. (ACDD)
g.id = ['OS_' meta.os_platform_code '_', datestr(meta.sdatenum,'yyyymm') '_' meta.mode '_' meta.data_type]; % The ?id? and ?naming_authority? attributes are intended to provide a globally unique identification for each dataset. The id may be the file name without .nc suffix, which is designed to be unique. (ACDD)
g.wmo_platform_code = meta.wmo_platform_code; % WMO (World Meteorological Organization) identifier. This platform number is unique within the OceanSITES project.
g.source = 'subsurface mooring'; % Use a term from the SeaVoX Platform Categories,(L06) list, usually one of the following: ?moored surface buoy?, ?subsurface mooring? (CF)
if isfield(meta,'pi_name'),  g.principal_investigator = meta.pi_name; end % Name of the person responsible for the project that produced the data contained in the file.
if isfield(meta,'pi_email'), g.principal_investigator_email = meta.pi_email; end % Email address of the project lead for the project that produced the data contained in the file.
if isfield(meta,'pi_url'),   g.principal_investigator_url = meta.pi_url; end % URL with information about the project lead
g.institution = meta.source_institution; % Specifies institution where the original data was produced. (CF)
if isfield(meta,'project'), g.project = meta.project;
else g.network = 'FixO3' ; end % The scientific project that produced the data.
if isfield(meta,'os_array'), g.array = meta.os_array; end % A grouping of sites based on a common and identified scientific question, or on a common geographic location.
if isfield(meta,'os_network'), g.network = meta.os_network; end % A grouping of sites based on common shore-based logistics or infrastructure.
if isfield(meta,'keywords_vocabulary')
  g.keywords_vocabulary = meta.keywords_vocabulary; % Please use one of ?GCMD Science Keywords?, 'SeaDataNet Parameter Discovery Vocabulary' or 'AGU Index Terms'. (ACDD)
  if isfield(meta,'keywords'), g.keywords = meta.keywords; end% Provide comma-separated list of terms that will aid in discovery of the dataset. (ACDD)
end;
if isfield(meta,'sdn_edmo_code'), g.sdn_edmo_code = meta.sdn_edmo_code; end % [Not in OceanSITES standard attributes]
g.comment = meta.comment_in; % Miscellaneous information about the data or methods used to produce it. Any free-format text is appropriate. (CF)

%% Geo-spatial-temporal - common to all data types
if isfield(meta,'data_area'), g.area = meta.data_area;
else g.network = 'North Atlantic Ocean' ; end % Geographical coverage. Try to compose of the following: North/Tropical/South Atlantic/Pacific/Indian Ocean, Southern Ocean, Arctic Ocean. 
g.geospatial_lat_min = num2str(meta.lat_min); % [req] The southernmost latitude, a value between -90 and 90 degrees; may be string or numeric. (ACDD, GDAC) 
g.geospatial_lat_max = num2str(meta.lat_max); % [req] The northernmost latitude, a value between -90 and 90 degrees. (ACDD, GDAC) 
g.geospatial_lat_units = 'degree_north'; % Must conform to udunits. If not specified then ?degree_north? is assumed. (ACDD) 
g.geospatial_lon_min = num2str(meta.lon_min); % [req] The westernmost longitude, a value between -180 and 180 degrees. (ACDD, GDAC)
g.geospatial_lon_max = num2str(meta.lon_max); % [req] The easternmost longitude, a value between -180 and 180 degrees. (ACDD, GDAC)
g.geospatial_lon_units = 'degree_east'; % Must conform to udunits, If not specified then ?degree_east? is assumed. (ACDD)
g.geospatial_vertical_min = num2str(meta.d_min); % [req] Minimum depth or height of measurements. (ACDD, GDAC)
g.geospatial_vertical_max = num2str(meta.d_max); % [req] Maximum depth or height of measurements. (ACDD, GDAC)
g.geospatial_vertical_positive = 'down'; % Indicates which direction is positive; "up" means that z represents height, while a value of "down" means that z represents pressure or depth. If not specified then ?down? is assumed. (ACDD)
g.geospatial_vertical_units = 'meter'; % Units of depth, pressure, or height. If not specified then ?meter? is assumed. (ACDD)
g.time_coverage_start = datestr(meta.sdatenum,osite_dfmt); % [req] Start date of the data in UTC. See note on time format below. (ACDD, GDAC)
g.time_coverage_end = datestr(meta.edatenum,osite_dfmt); % [req] Final date of the data in UTC. See note on time format below. (ACDD, GDAC)
if isfield(meta,'time_coverage_duration'), g.time_coverage_duration = meta.time_coverage_duration;
else g.time_coverage_duration = ['P' num2str(floor(meta.edatenum-meta.sdatenum)) 'D']; end % Use ISO 8601 (examples: P1Y ,P3M, P10D) (ACDD)
if isfield(meta,'time_coverage_resolution'), g.time_coverage_resolution = 'time_coverage_resolution'; end % Interval between records: Use ISO 8601 (PnYnMnDTnHnMnS) e.g. PT5M for 5 minutes, PT1H for hourly, PT30S for 30 seconds. (ACDD)
g.cdm_data_type = 'station'; % [req] The Unidata CDM (common data model) data type used by THREDDS. e.g. point, profile, section, station, station_profile, trajectory, grid, radial, swath, image; use Station for OceanSITES mooring data. (ACDD)
if isfield(meta,'featureType'), g.featureType = meta.featureType;
else g.featureType = 'timeSeries'; end % Optional, and only for files using the Discrete Sampling Geometry, available in CF-1.5 and later. See CF documents. (CF)
g.data_type = 'OceanSITES time-series data'; % From Reference table 1: OceanSITES specific. (GDAC)

%% Conventions used 
g.format_version = meta.os_format_version; % [req] OceanSITES format version; may be 1.1, 1.2, 1.3. (GDAC)
g.Conventions = meta.os_conventions; % Name of the conventions followed by the dataset. (NUG)
if (meta.ncVerNo > 3), g.netcdf_version = '4.0'; % netCDF version 4.0 if specified > 3
else g.netcdf_version = '3.5'; % if not specified, or not set >3, default to 3.5
end % NetCDF version used for the data set

%% Publication information 
if isfield(meta,'publisher_name'), g.publisher_name = meta.publisher_name;
else g.publisher_name = meta.author; end; % Name of the person responsible for metadata and formatting of the data file. (ACDD) 
if isfield(meta,'publisher_email'), g.publisher_email = meta.publisher_email;
else g.publisher_email = meta.contacts_email; end; % Email address of person responsible for metadata and formatting of the data file. (ACDD) 
if isfield(meta,'publisher_url'), g.publisher_url = meta.publisher_url;
else g.publisher_url = meta.author_url; end; % Web address of the institution or of the data publisher. (ACDD) 
g.references = meta.references; % Published or web-based references that describe the data or methods used to produce it. Include a reference to OceanSITES and a project-specific reference if appropriate. 
g.institution_references = meta.institution_references; % [Not in OceanSITES standard attributes]
g.data_assembly_center = meta.data_assembly_center; % Data Assembly Center (DAC) in charge of this data file. The data_assembly_center are listed in reference table 5. 
g.update_interval = meta.update_interval; % [req] Update interval for the file, in ISO 8601 Interval format: PnYnMnDTnHnM, where elements that are 0 may be omitted. Use ?void? for data that are not updated on a schedule. Used by inventory software. (GDAC) 
if isfield(meta,'useLicense')
  g.license = meta.useLicense;
else
  g.license = ['Follows CLIVAR (Climate Varibility and Predictability) standards, cf. http://www.clivar.org/data/data_policy.php. Data available free of charge. User assumes all risk for use of data. User must display citation in any publication or product using data. User must contact PI prior to any commercial use of data.'];
end % A statement describing the data distribution policy; it may be a project- or DAC-specific statement, but must allow free use of data. OceanSITES has adopted the CLIVAR data policy, which explicitly calls for free and unrestricted data exchange. Details at: http://www.clivar.org/data/data_policy.php (ACDD) 
if isfield(meta,'citation')
  g.citation = meta.citation;
else
  g.citation = ['These data were collected and made freely available by the EuroSITES and OceanSITES projects and the national programs that contribute to them.'];
end % The citation to be used in publications using the dataset; should include a reference to OceanSITES but may contain any other text deemed appropriate by the PI and DAC.. 
if isfield(meta,'acknowledgement'), g.acknowledgement = meta.acknowledgement;
elseif isfield(meta,'citation'), g.acknowledgement = meta.citation;
end; % A place to acknowledge various types of support for the project that produced this data. (ACDD) 

%% Provenance - common to all data types
g.date_created = datestr(now,osite_dfmt); % The date on which the data file was created. Version date and time for the data contained in the file. (UTC). See note on time format below. (ACDD) 
if isfield(meta,'date_modified'), g.date_modified = meta.date_modified;
else g.date_modified = g.date_created; end % The date on which [data in] this file was last modified. (ACDD) 
g.history = meta.history_in; % Provides an audit trail for modifications to the original data. It should contain a separate line for each modification, with each line beginning with a timestamp, and including user name, modification name, and modification arguments. The time stamp should follow the format outlined in the note on time formats below. (NUG) 
% Level of processing and quality control applied to data. Preferred values are listed in reference table 3. - set by datatype using oceansites_ref_tables
switch meta.mode
  case 'R'
    g.processing_level = meta.OS_tab3{2};
  case 'D'
    g.processing_level = meta.OS_tab3{3};
end
if isfield(meta,'quality_control_indicator'), g.QC_indicator = meta.quality_control_indicator;
else g.QC_indicator = 'unknown'; end  % A value valid for the whole dataset, one of: 'unknown' - no QC done, no known problems 'excellent' - no known problems, some QC done 'probably good' - validation phase, 'mixed' - some problems, see variable attributes 
if isfield(meta,'contributor_name'), g.contributor_name = meta.contributor_name;
else g.contributor_name = meta.institution_references; end % A semi-colon-separated list of the names of any individuals or institutions that contributed to the creation of this data. (ACDD) 
if isfield(meta,'contributor_role'), g.contributor_role = meta.contributor_role;
end % The roles of any individuals or institutions that contributed to the creation of this data, separated by semi-colons.(ACDD) 
if isfield(meta,'contributor_email'), g.contributor_name = meta.contributor_email;
end % The email addresses of any individuals or institutions that contributed to the creation of this data, separated by semi- colons. (ACDD) 

%% Define Dimensions
d = struct('TIME',meta.nrecs, ... % TIME is always first dimension
           'DEPTH', meta.num_depths, ... % DEPTH always second dimension
           'LAT', 1, 'LON', 1); % LAT and LON are singleton dimensions

%% Define Variables included for all data types
varStruct = struct('xType', [], 'dimids', [], 'Atts', []); % Empty variable definition structure
% We always have TIME, DEPTH, LAT and LON
v = struct('time', varStruct,'depth', varStruct,'lat', varStruct,'lon', varStruct);
v.time.xType = 'NC_DOUBLE';
v.time.dimids = {'TIME'};
v.time.Atts = struct(...
      'standard_name', 'time',...
      'units', 'days since 1950-01-01T00:00:00Z',...
      'axis', 'T', ...
      'long_name', 'time of measuremnet',...
      'valid_min', 0.0,...
      'valid_max', 90000.0,...
      'QC_indicator', meta.OS_tab2{2},...
      'processing_level', meta.OS_tab3{2},...
      'uncertainty', 0.000005,...   % 2.3 mins per year
      'comment', ''...
      );
v.depth.xType = 'NC_FLOAT';
v.depth.dimids = {'DEPTH'};
v.depth.Atts = struct(...
      'standard_name', 'depth', ...
      'units', 'meter', ...
      'positive', 'down', ...
      'axis','Z', ...
      'reference', 'sea_level',...
      'coordinate_reference_frame', 'urn:ogc:def:crs:EPSG::5831',...
      'long_name', 'Depth of each measurement', ...
      'valid_min', single(0), ...
      'valid_max', single(12000), ...
      'QC_indicator', meta.OS_tab2{2},...
      'processing_level', meta.OS_tab3{2},...
      'uncertainty', 0,...
      'comment','Nominal depth of each instrument. Use PRES to derive time-varying depths of instruments, as the mooring may tilt in ambient currents' ...
      );
v.lat.xType = 'NC_FLOAT';
v.lat.dimids = {'LAT'};
v.lat.Atts = struct(...
      'standard_name', 'latitude', ...
      'units', 'degrees_north', ...
      'axis','Y', ...
      'reference', 'WGS84',...
      'coordinate_reference_frame', 'urn:ogc:def:crs:EPSG::4326',...
      'long_name', 'latitude of measurements', ...
      'valid_min', single(-90), ...
      'valid_max', single(90), ...
      'QC_indicator', meta.OS_tab2{2},...
      'processing_level', meta.OS_tab3{2},...
      'uncertainty', 0.05,...
      'comment','Anchor latitude of mooring' ...
      );
v.lon.xType = 'NC_FLOAT';
v.lon.dimids = {'LON'};
v.lon.Atts = struct(...
      'standard_name', 'longitude', ...
      'units',  'degrees_east', ...
      'axis','X', ...
      'reference', 'WGS84',...
      'coordinate_reference_frame', 'urn:ogc:def:crs:EPSG::4326',...
      'long_name', 'longitude of measurements', ...
      'valid_min', single(-180), ...
      'valid_max', single(180), ...
      'QC_indicator', meta.OS_tab2{2},...
      'processing_level', meta.OS_tab3{2},...
      'uncertainty', 0.05,...
      'comment','Anchor longitude of mooring' ...
      );
switch meta.data_type
  case {'CTD','CTDO'} % microcats
    [v1, meta] = def_pap_microcat(meta);
  otherwise
    disp(['Unknown DataType ' meta.data_type '- no variables defined']);
    v1 = [];
    meta.nrecs=0;
end
% Update / create new global attributes with data specific metadata
if isfield(meta,'properties'), g.summary = [g.summary ' Measured properties: ' meta.properties]; end
if isfield(meta,'dep_str'), g.summary = [g.summary ' at ' meta.dep_str ' depth levels']; end
if isfield(meta,'keywords'), g.keywords = meta.keywords; end
if isfield(meta,'time_coverage_resolution'), g.time_coverage_resolution = meta.time_coverage_resolution;
elseif meta.nrecs>0, g.time_coverage_resolution = ['PT' num2str(floor((meta.edatenum-meta.sdatenum)*24*60)/meta.nrecs) 'M']; end

% Create single output variable definition structure from common and data
% type specific variable definitions
flds = fieldnames(v1);
for i=1:length(flds)
  v.(flds{i}) = v1.(flds{i});
end
