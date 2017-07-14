function [meta, gr] =  setup_mooring_pap(mooring,deploy)
%   [meta, gr] =  setup_mooring_pap(mooring, deploy)
% Return metadata and graph settings for mooring 'mooring', deployment 'deploy'
% mooring (in) : mooring idetinfier (eg 'PAP')
% deploy (in) : mooring deployment specifier string - number (1-9) or date of
%               deployment in yyyymm format (eg '210704')
% meta (out) : structure containing metadata for PAP mooring deployment
%         db_table : root database table name (eg 'PAP201704')
%         os_site_code: OceanSITES Name of the Site (eg PAP)
%         os_platform_code: Mooring identifier for OceanSITES (eg PAP-1)
%         meta.wmo_platform_code: WMO platform code
%         meta.os_network: OceanSITES Network (eg FixO3)
%         meta.os_id: OceanSITES numeric id of site
%         anchor_lon: longitude of anchor position
%         anchor_lat: latitude of anchor position
%         site_lon_min: minimum longitude of position
%         site_lon_max: mxaimum longitude of position
%         site_lat_min: minimum longitude of position
%         site_lat_max: mxaimum longitude of position
%         pi_name: default PI for PAP
%         pi_email: PI contact email
%         pi_url: Pi contact URL
%         source_institution: deafult source institute for netCdf attributes
%         update_interval: update interval fro netCDF data
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
%         sdatenum: start date of deplyment as datenum
%         pro_o_start_date: Start date for Pro Oceanus O2 sensor
%         pro_o_K_start_date: Start date for Pro Oceanus K O2 sensor
%         edatenum: end date of deployment (now for current)
% Maybe split out this calibration / processing info
%         SBO processing info: 
%         sbo_nv: number of SBO instruments (microcats)
%         sbo: nominal depth & serial number of microcats (2 x sbo_nv)
%         sbo_press_corr: pressure correction for microcats (1 x sbo_nv)
%         sbo_b: Scaled temperature correction constants (1x4)
%         sbo_c0: Scaled temperature correction constant
%         fet_nv: number of FET sensors
%         fet: nominal depth & serial number of FET sensors (2 x fet_nv)
%         Aa_ox_calib: Aanderaa Seaguard Oxygen calibration [slope offset]
%         cyclops_calib: Turner Cyclops Chlorophyll calibration [slope offset]
%         oc_nv: number of OC sensors
%         wet_instr_calib: Wetlabs Chlorophyll instrument calibration [slope offset cwo]
%         wet_calib: Wetlabs Chlorophyll calibration [slope offset]
% gr (out): structure containing Info for graph generation
%         webdir: Output for graphs for web viewing
%         dep_name: Deployment name (for grpah titles)
%         x_lab: Year range for graph X labels
%         sboYlim: Y limits for SBO (microcats) Ox? values
%         fetYlim: Y limits for FET values 
%         chlYlim: Y limits for Cyclops Chl values 
%         sensor_type ...% netCDF parameter lists

%% Site Metadata
mooring_no = '1'; % Need to set this according to some criteria - maybe mooring / deployment related?
% Platform code - acts as catch for unrecognised moorings
[meta.os_site_code, meta.os_platform_code, meta.wmo_platform_code,...
  meta.os_network, meta.os_id] = ...
  wmo_codes(lower(mooring),mooring_no);

if isempty(meta.os_site_code)
  error(['Unrecognised mooring ' mooring]);
end

% Mooring position info - check this is constant for all deployments
switch lower(meta.os_site_code)
  case 'pap'
    meta.anchor_lon = -16.31896;
    meta.anchor_lat = 49.02946;
    meta.lon_min = -17.;
    meta.lon_max = -16.;
    meta.lat_min = 48.;
    meta.lat_max = 50.;
    meta.d_min = 1;
    meta.d_max = 30.;
  otherwise
    error(['Sorry - unable to setup mooring ' mooring ' (yet)']);
end
%% Data Metadata
meta.db_table = [meta.os_site_code deploy]; % deploy is 1-9 or yyyymm
switch lower(meta.os_site_code)
  case 'pap'
    meta.pi_name = 'Richard Lampitt';
    meta.pi_email = 'Richard.Lampitt at noc.ac.uk';
    meta.pi_url = 'http://noc.ac.uk/people/rsl';
    meta.source_institution = 'NOC';
    meta.update_interval = 'daily';
    meta.institution_references = 'http://noc.ac.uk';
    meta.data_area = 'North Atlantic Ocean';
    meta.os_platform_category = 'Physical, Biogeochemical';
    meta.os_title = 'Oceanographic Data';

end

%% Deployment specific Info
switch deploy
  case '201704'
    % Deployment
    meta.project = 'FixO3';
    meta.deploy_voy = 'RSS Discovery DY032';
    % Dates - save as datenum then output to range of formats when needed
    meta.sdatenum = datenum('2017-04-20 12:30:00');
    meta.pro_o_start_date = meta.sdatenum; % only define if different
    meta.pro_o_K_start_date = meta.sdatenum; % only define if different
    meta.edatenum = now; % set to now
    meta.num_depths = 2; % Number of unique nominal depths with sensors
 
    % Directories for graph output
    % Should be able to set same for all deployments if rename directories!
    % gr.webdir = ['/noc/users/animate/img/pap_' datestr(meta.sdatenum,'yyyy_mmm') '/'];
    gr.webdir = ['/noc/itg/www/apps/pap/pap_' datestr(meta.sdatenum,'yyyy_mmm') '/'];
    % gr.webdir2 = ['/data/ncs/www/eurosites/pap/pap_' datestr(meta.sdatenum,'yyyy_mmm') '/'];

    gr.dep_name = datestr(meta.sdatenum,'mmmm yyyy'); % Used for graph title
    gr.x_lab = ['Date (' datestr(meta.sdatenum,'yyyy') '-' datestr(meta.edatenum,'yyyy') ')']; % graph x axis label

    % Parameters needed for SBO processing
    meta.sbo_nv = 3;
    meta.sbo_sensor_model = {'MicroCAT sbe-37IMP-IDO with pump' ...
                             'MicroCAT sbe-37IMP-ODO with pump' ...
                             'MicroCAT sbe-37IMP-ODO with pump'};
    meta.sbo_sensor_manufacturer = 'Seabird Electronics';
    %meta.sbo_sensor_reference
    meta.sbo_sensor_mount = 'mounted_on_mooring_line';
    meta.sbo_sensor_orientation = 'vertical';
    meta.sbo = [1,9030; 30,10535; 30,13397];     % amended to be serial numbers for current deployment
    meta.sbo_press_corr = [0, 0, 0];
    gr.sboYlim = []; % previous [5 7];Used to set Y Limits on sbo graphs
    % Constants for scaled temperature calculation
    meta.sbo_b = [-0.00624097 -0.00693498 -0.00690358 -0.00429155];
    meta.sbo_c0 = -0.000000311680;
  
    % Parameters needed for FET processing
    meta.fet_nv = 2;
    meta.fet = [1, 257;30, 63];		% Depth & serial numbers for current deployment
    gr.fetYlim = [7.5 8.5];			% used to set Y limits on fet graphs

    % Parameters for Aanderaa 4430H (S/N 2001) Seaguard Oxygen processing
    meta.Aa_ox_calib = [1.0025 13.313]; % slope & offset from cruise report

    % Parameters for Turner cyclops (S/N 2103960) Seaguard Chlorophyll processing
    % from regression against bottle data in calibration dip
    meta.cyclops_calib = [0.0951 0.0937]; %  slope & offset from from cruise report
    gr.chlYlim = [0.0, 2.0]; % Used to set Y limits of chlorophyll graphs

    % Parameters for OC processing
    meta.oc_nv = 3;

    % Parameters for Wetlabs processing
    meta.wet_instr_calib = [1 690 0]; % sn 3050 2015 [slope offset cwo]
    % from regression against bottle chl in calibration dip - 2017 data from Corinne
    meta.wet_calib = [0.2225 0.0934]; % slope & offset
  otherwise
    disp(['Sorry - not yet able to setup deployment ' deploy ' for mooring ' mooring]);
end % End of deployment switch

%% Update Project specific information
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
  otherwise
    meta.acknowledgement = ['When you use these data in publications please acknowledge the NOC.' ...
      ' Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data.' ...
      ' Publications should be sent to: BODC Data Management,' ...
      ' National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];
    meta.citation = sprintf(cit_fmt, meta.project, meta.project_contract);
end

