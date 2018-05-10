function [meta] =  setup_mooring(mooring,deploy,mode)
%   [meta] =  setup_mooring(mooring, deploy[, mode])
% Return metadata for mooring 'mooring', deployment 'deploy'
% mooring (in) : mooring idetinfier (eg 'RTEB1', 'PAP')
% deploy (in) : mooring deployment specifier string - number (1-9) or date of
%               deployment in yyyymm format (eg '210704')
% mode (in) : data mode 'R' for NRT or 'D' for delayed mode
% meta (out) : structure containing metadata for mooring deployment
%         qxf_fn : QXF file name (eg 'b1789132.qxf') for delayed mode only
%         db_table: database table for NRT data
%         os_site_code: OceanSITES Name of the Site (eg PAP)
%         os_platform_code: Mooring identifier for OceanSITES (eg PAP-1)
%         wmo_platform_code: WMO platform code
%         os_network: OceanSITES Network (eg FixO3, OSNAP)
%         os_id: OceanSITES numeric id of site
%         anchor_lon: longitude of anchor position
%         anchor_lat: latitude of anchor position
%         site_lon_min: minimum longitude of position
%         site_lon_max: mxaimum longitude of position
%         site_lat_min: minimum longitude of position
%         site_lat_max: mxaimum longitude of position
%         pi_name: default PI for data
%         pi_email: PI contact email
%         pi_url: Pi contact URL
%         source_institution: deafult source institute for netCdf attributes
%         update_interval: update interval for netCDF data (NRT data)
%         institution_references: URL for source institute
%         data_area: Mooring sea area
%         os_data_type: OceanSITES data type
%         data_source: OceanSITES data source
%         os_title: OceanSITES title
%         keywords: keywords
%         project: project for this deployment
%         data_assembly_center: DAC creating products for this project
%         os_network: OceanSITES network
%         publisher_url: Project URL
%         license: license text
%         citation: citation text
%         acknowledgement: acknowledgements text
%         deploy_voy: deployment cruise
%         sdatenum: start date of deployment as datenum
%         edatenum: end date of deployment
% Maybe split out this calibration / processing info
%         SBO processing info:
%         sbo_nv: number of SBO instruments (microcats)
%         sbo: nominal depth & serial number of microcats (2 x sbo_nv)
%         sbo_press_corr: pressure correction for microcats (1 x sbo_nv)
%         sbo_b: Scaled temperature correction constants (1x4)
%         sbo_c0: Scaled temperature correction constant
%         co2: nominal depth & serial number of ProOceanus CO2 sensors
%         fet_nv: number of FET sensors
%         fet: nominal depth & serial number of FET sensors (2 x fet_nv)
%         Aa_ox_calib: Aanderaa Seaguard Oxygen calibration [slope offset]
%         cyclops_calib: Turner Cyclops Chlorophyll calibration [slope offset]
%         oc_nv: number of OC sensors
%         wet_instr_calib: Wetlabs Chlorophyll instrument calibration [slope offset cwo]
%         wet_calib: Wetlabs Chlorophyll calibration [slope offset]
%% Need to check the inut arguments
if nargin<2
  error('Required input is mooring & deployment');
elseif nargin==2
  mode = 'D';
elseif ~ischar(mode) || length(mode)>1
  error('''Mode'' must be "R" or "D"');
elseif ~ischar(mooring)
  error('''mooring'' must be input string');
elseif ~ischar(deploy)
  deploy = num2str(deploy);
  warning(['input ''deploy'' parameter converted to string ' deploy]);
elseif nargin>3
  warning('Additional Arguments Ignored');
end

%% Site Metadata
% Platform code - acts as catch for unrecognised moorings
[meta.os_site_code, meta.os_platform_code, meta.wmo_platform_code,...
  meta.os_network, meta.os_id] = ...
  wmo_codes(lower(mooring));
if isempty(meta.os_site_code)
  error(['Unrecognised mooring ' mooring]);
end

% Add mooring number for those that have one...
switch lower(mooring)
  case 'pap' % PAP - can be 1, 2 or 3, for surface, mid-water or bottom
    meta.os_platform_code = [meta.os_platform_code '-1'];
  case {'rteb', 'rtwb'} % Not sure for OSNAP - but use 1 for now...
    switch deploy
      case '201407'
        meta.os_platform_code = [meta.os_platform_code '1'];
      case '201607'
        meta.os_platform_code = [meta.os_platform_code '1'];
    end
end

% Mooring position info - check this is constant for all deployments
% Maybe push to external modules - can read from tables eventually...
switch lower(mooring)
  case 'pap' % pap site
    meta.anchor_lon = -16.31896;
    meta.anchor_lat = 49.02946;
    meta.lon_min = -17.;
    meta.lon_max = -16.;
    meta.lat_min = 48.;
    meta.lat_max = 50.;
    meta.d_min = 1;
    meta.d_max = 30.;
  case 'rteb' % UK-OSNAP Eastern Boundary
    meta.anchor_lon = -9.54833;
    meta.anchor_lat = 57.10;
    meta.lon_min = -9.54;
    meta.lon_max = -9.55;
    meta.lat_min = 57.0;
    meta.lat_max = 57.2;
    meta.d_min = 1;
    meta.d_max = 1800.;
  case 'rtwb1' % UK-OSNAP Western Boundary 1
    meta.anchor_lon = -12.71;
    meta.anchor_lat = 57.47;
    meta.lon_min = -12.71;
    meta.lon_max = -12.71;
    meta.lat_min = 57.47;
    meta.lat_max = 57.47;
    meta.d_min = 1;
    meta.d_max = 1570;
  case 'rtwb2' % UK-OSNAP Western Boundary 1
    meta.anchor_lon = -12.71;
    meta.anchor_lat = 57.47;
    meta.lon_min = -12.71;
    meta.lon_max = -12.71;
    meta.lat_min = 57.47;
    meta.lat_max = 57.47;
    meta.d_min = 1;
    meta.d_max = 1570;
  otherwise
    error(['Sorry - unable to setup mooring ' mooring ' (yet)']);
end
%% Data Metadata
% File identifier - this will be from dataset ids..
if (mode == 'R')
  meta.db_table = [meta.os_site_code deploy]; % deploy is 1-9 or yyyymm
else
  switch lower(mooring)
    case 'pap' % pap site
      switch deploy
        case '201704'
          meta.qxf_fn = 'xxxxx.qxf';
      end
    case 'rteb'
      switch deploy
        case '201407'
          meta.qxf_fn = {'b1789132.qxf'};
      end
    case 'rtwb'
      switch deploy
        case '201407'
          meta.qxf_fn = {'b1795358.qxf', 'b1795371.qxf', 'b1795383.qxf',...
            'b1795395.qxf', 'b1795402.qxf', 'b1795414.qxf', 'b1795426.qxf', 'b1795438.qxf'};
      end
  end
end
% PI and source info
switch lower(mooring)
  case 'pap' % pap site
    meta.pi_name = 'Richard Lampitt';
    meta.pi_email = 'Richard.Lampitt at noc.ac.uk';
    meta.pi_url = 'http://noc.ac.uk/people/rsl';
    meta.source_institution = 'NOC';
    if (mode == 'R'), meta.update_interval = 'daily'; end
    meta.institution_references = 'http://noc.ac.uk';
    meta.data_area = 'North Atlantic Ocean';
    meta.os_platform_category = 'Physical, Biogeochemical';
    meta.os_title = 'Oceanographic Data';
  case {'rteb'; 'rtwb'}
    meta.pi_name = '';
    meta.pi_email = ' at sams.ac.uk';
    meta.pi_url = 'http://';
    meta.source_institution = 'SAMS';
    if (mode == 'R'), meta.update_interval = 'daily'; end
    meta.institution_references = 'http://noc.ac.uk';
    meta.data_area = 'North Atlantic Ocean';
    meta.os_platform_category = 'Physical';
    meta.os_title = 'Oceanographic Data';
end

%% Deployment specific Info
switch lower(mooring)
  case 'pap' % pap site
    switch deploy
      case '201704'
        % Deployment
        meta.project = 'FixO3';
        meta.deploy_voy = 'RSS Discovery DY032';
        % Dates - save as datenum then output to range of formats when needed
        meta.sdatenum = datenum('2017-04-20 12:30:00');
        if (mode == 'R'), meta.edatenum = now; end
        % set to now
        meta.num_depths = 2; % Number of unique nominal depths with sensors
        
        % SBO sensor metadata
        meta.sbo_nv = 3;
        meta.sbo = [1,9030; 30,10535; 30,13397];     % depth & serial numbers for current deployment
        meta.sbo_ox = 1;
        meta.sbo_sensor_model = {'MicroCAT sbe-37IMP-ODO with pump' ...
                                 'MicroCAT sbe-37IMP-ODO with pump' ...
                                 'MicroCAT sbe-37IMP-ODO with pump'};
        meta.sbo_sensor_manufacturer = 'Seabird Electronics';
        %meta.sbo_sensor_reference
        meta.sbo_sensor_mount = 'mounted_on_mooring_line';
        meta.sbo_sensor_orientation = 'vertical';
        meta.sbo_press_corr = [0, 0, 0];
        % Constants for scaled temperature calculation
        meta.sbo_b = [-0.00624097 -0.00693498 -0.00690358 -0.00429155];
        meta.sbo_c0 = -0.000000311680;
        
        % CO2 sensor metadata
        meta.co2_nv = 2;
        meta.co2 = {1, '29-097-45';30, '34-200-45'};		% Depth & serial numbers for current deployment
        meta.co2_sensor_model = {'Pro-Oceanus: CO2-Pro' ...
                                 'Pro-Oceanus: Logging CO2-Pro'};
        meta.co2_sensor_manufacturer = 'Pro-Oceanus';
        %meta.co2_sensor_reference
        meta.co2_sensor_mount = 'mounted_on_mooring_line';
        meta.co2_sensor_orientation = 'vertical';
        
        % FET sensor metadata
        meta.fet_nv = 2;
        meta.fet = [1, 257;30, 63];		% Depth & serial numbers for current deployment
        
        % Aanderaa 4430H (S/N 2001) Seaguard Oxygen sensor metadata
        meta.Aa_ox_calib = [1.0025 13.313]; % slope & offset from cruise report
        
        % Turner cyclops (S/N 2103960) Seaguard Chlorophyll sensor metadata
        % from regression against bottle data in calibration dip
        meta.cyclops_calib = [0.0951 0.0937]; %  slope & offset from from cruise report
        
        % OC sensor metadata
        meta.oc_nv = 3;
        
        % Wetlabs sensor metadata
        meta.wet_instr_calib = [1 690 0]; % sn 3050 2015 [slope offset cwo]
        % from regression against bottle chl in calibration dip - 2017 data from Corinne
        meta.wet_calib = [0.2225 0.0934]; % slope & offset
      otherwise
        disp(['Sorry - not yet able to setup deployment ' deploy ' for mooring ' mooring]);
    end
  case 'rteb'
    switch deploy
      case '201407'
        % Deployment
        meta.project = 'UK-OSNAP';
        meta.deploy_voy = 'RV Knorr KN221-2';
        meta.recover_voy = 'RV Pelagia PE399';
        % Dates - save as datenum then output to range of formats when needed
        meta.sdatenum = datenum('2014-07-18');
        meta.edatenum = datenum('2015-06-20');
        meta.num_depths = 14; % Number of unique nominal depths with sensors
        
        % SBO sensor metadata
        meta.sbo_nv = 8;
        meta.sbo_sensor_model = {'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT'};
        meta.sbo_sensor_manufacturer = 'Seabird Electronics';
        %meta.sbo_sensor_reference
        meta.sbo_sensor_mount = 'mounted_on_mooring_line';
        meta.sbo_sensor_orientation = 'vertical';
        meta.sbo = [100,11321; 253,11322; 502,11323; 751,11324; 1005,11325; 1250,11331; 1500,11332; 1775,11333];     % Depth & serial numbers for current deployment
        
        % Parameters needed for ADCP sensor metadata
        meta.adcp_nv = 5;
        meta.adcp_sensor_model = {'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp'};
        meta.adcp_sensor_manufacturer = 'Nortek';
        %meta.adcp_sensor_reference
        meta.adcp_sensor_mount = 'mounted_on_mooring_line';
        meta.adcp_sensor_orientation = 'vertical';
        meta.adcp = [98,11047; 247,11055; 497,11058; 999,11063; 1352,11064];     % Depth & serial numbers for current deployment
        
        % BPR sensor metadata
        meta.bpr_nv = 1;
        meta.bpr_sensor_model = {'Seabird SBE53 Bottom Pressure Recorder'};
        meta.bpr_sensor_manufacturer = 'Seabird Electronics';
        %meta.bpr_sensor_reference
        meta.bpr_sensor_mount = 'mounted_off_mooring_line';
        meta.bpr_sensor_orientation = 'vertical';
        meta.bpr = [1796,81];     % serial numbers for current deployment
      otherwise
        disp(['Sorry - not yet able to setup deployment ' deploy ' for mooring ' mooring]);
    end
  case 'rtwb'
    switch deploy
      case '201407'
        % Deployment
        meta.project = 'UK-OSNAP';
        meta.deploy_voy = 'RV Knorr KN221-2';
        meta.recover_voy = 'RV Pelagia PE399';
        % Dates - save as datenum then output to range of formats when needed
        meta.sdatenum = datenum('2014-07-18');
        meta.edatenum = datenum('2015-06-20');
        meta.num_depths = 14; % Number of unique nominal depths with sensors
        
        % SBO sensor metadata
        meta.sbo_nv = 8;
        meta.sbo_sensor_model = {'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT' ...
          'Seabird SBE37 MicroCAT'};
        meta.sbo_sensor_manufacturer = 'Seabird Electronics';
        %meta.sbo_sensor_reference
        meta.sbo_sensor_mount = 'mounted_on_mooring_line';
        meta.sbo_sensor_orientation = 'vertical';
        meta.sbo = [100,11321; 253,11322; 502,11323; 751,11324; 1005,11325; 1250,11331; 1500,11332; 1775,11333];     % Depth & serial numbers for current deployment
        
        % Parameters needed for ADCP sensor metadata
        meta.adcp_nv = 5;
        meta.adcp_sensor_model = {'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp' ...
          'Nortek Aquadopp'};
        meta.adcp_sensor_manufacturer = 'Nortek';
        %meta.adcp_sensor_reference
        meta.adcp_sensor_mount = 'mounted_on_mooring_line';
        meta.adcp_sensor_orientation = 'vertical';
        meta.adcp = [98,11047; 247,11055; 497,11058; 999,11063; 1352,11064];     % Depth & serial numbers for current deployment
        
        % BPR sensor metadata
        meta.bpr_nv = 1;
        meta.bpr_sensor_model = {'Seabird SBE53 Bottom Pressure Recorder'};
        meta.bpr_sensor_manufacturer = 'Seabird Electronics';
        %meta.bpr_sensor_reference
        meta.bpr_sensor_mount = 'mounted_off_mooring_line';
        meta.bpr_sensor_orientation = 'vertical';
        meta.bpr = [1796,81];     % serial numbers for current deployment
        
      otherwise
        disp(['Sorry - not yet able to setup deployment ' deploy ' for mooring ' mooring]);
    end % End of deployment switch
end
%% Update Project specific information
switch meta.project
  case {'ANIMATE', 'MERSEA', 'EuroSITES', 'FixO3'}
    ack_fmt = ...
      ['When you use %s data in publications please acknowledge the %s Project (%s).' ...
      ' Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data for inclusion in the %s bibliography.' ...
      ' Publications should be sent to: %s Data Manager - BODC Data Management,' ...
      ' National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];
    cit_fmt = ...
      ['These data were collected and made freely available by the %s Project (%s)' ...
      ' and the national programs that contribute to it'];
    switch meta.project
      case 'ANIMATE'
        meta.project_title = 'ANIMATE Atlantic Network of Interdisciplinary Moorings and Time-series for Europe.';
        meta.project_contract = 'EU FP5 contract EVR1-CT-2001-40014.';
        meta.acknowledgement = ...
          sprintf(ack_fmt,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
        meta.citation = sprintf(cit_fmt,meta.project, meta.project_contract);
      case 'MERSEA'
        meta.project_title = 'MERSEA Marine EnviRonment and Security for the European Area - Integrated Project. WP3 In Situ Ocean Observing Systems.';
        meta.project_contract = 'EU FP6 contract AIP3-CT-2003-502885'; % see also citation
        meta.acknowledgement = ...
          sprintf(ack_fmt,meta.project, meta.project, meta.project_contract, 'ANIMATE/MERSEA', 'ANIMATE/MERSEA');
        meta.citation = sprintf(cit_fmt,meta.project, meta.project_contract);
      case 'EuroSITES'
        meta.project_title = 'EuroSITES European Ocean Observatory Network';
        meta.project_contract = 'EU FP7 collaborative project contract FP7-ENV-2007-1-202955'; % see also citation
        meta.acknowledgement = ...
          sprintf(ack_fmt,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
        meta.citation = sprintf(cit_fmt,meta.project, meta.project_contract);
      case 'FixO3'
        meta.project_title = 'FixO3: Fixed-point Open Ocean Observatories';
        meta.project_contract = 'EU FP7 project (FP7/2007-2013) under grant agreement No 312463'; % see also citation
        meta.acknowledgement = ...
          sprintf(ack_fmt,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
        meta.citation = sprintf(cit_fmt,meta.project, meta.project_contract);
        meta.os_network = 'FixO3';
        meta.data_assembly_center = 'FixO3 DAC';
        meta.publisher_url = 'http://www.fixo3.eu';
        meta.references='http://www.fixo3.eu, http://www.oceansites.org, http://www.coriolis.eu.org, http://www.eurosites.info';
    end
  case 'UK-OSNAP'
    ack_fmt = ...
      'When you use %s data in publications please acknowledge the %s (%s).';
    cit_fmt = ...
      ['These data were collected and made freely available by the %s (%s)' ...
      ' and the national programs that contribute to it'];
    meta.project_title = 'UK - Overturning in the Subpolar North Atlantic Programme (UK-OSNAP) Programme';
    meta.project_contract = 'Funded by the Natural Environment Research Council';
    meta.acknowledgement = ...
      sprintf(ack_fmt,meta.project, meta.project_title, meta.project_contract);
    meta.citation = sprintf(cit_fmt,meta.project, meta.project_contract);
end

