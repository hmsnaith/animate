function [db_tab, meta, gr] =  setup_mooring_pap(deploy)
%   [db_table, meta, gr] =  setup_mooring_pap(deploy)
% Return metadata and graph settings for deployment 'deploy'
% deploy (in) : PAP deployment specifier string - number (1-9) or date of
%               deployment in yyyymm format (eg '210704')
% db_table (out) : root database table name (eg PAP201704)
% meta (out) : structure containing metadata for PAP mooring deployment
%         name: Name of the Site (eg PAP)
%         mooring: Moorig identifier for OceanSITES (eg PAP)
%         anchor_lon: longitude of anchor position
%         anchor_lat: latitude of anchor position
%         site_lon: nominal longitude of anchor position
%         site_lat: nominal latitude of anchor position
%         mode: data mode (R for real time)
%         ncVerNo: netCDF version number
%         history_in: default history for netCDF attributes
%         comment_in: default comment for netCdf attributes
%         pi_name: default PI for PAP
%         principal_investigator_email: PI contact email
%         principal_investigator_url: Pi contact URL
%         source_institution: deafult source institute for netCdf attributes
%         update_interval: update interval fro netCDF data
%         institution_references: URL for source institute
%         data_area: Mooring sea area
%         lSensor_Sampling_Frequency: default sensor sampling frequency
%         mc_Sensor_Reporting_Time: default sensor reporting time
%         os_format_version: OceanSITES format version
%         os_platform_category: OceanSITES platform category
%         os_data_type: OceanSITES data type
%         data_source: OceanSITES data source
%         os_title: OceanSITES title
%         contributor_name: netCDF data contact name
%         contributor_role: netCDF data contact role (editor)
%         contributor_email: netCDF data contact email
%         author: Author name
%         publisher_name: Author name
%         publisher_email: Author email
%         contacts_email: General contact email
%         keywords_vocabulary: URL for VocabularyKeyWords 
%         keywords; keywords
%         project: project for this deployment
%         data_assembly_center: DAC creating products for this project
%         os_network: OceanSITES network
%         publisher_url: Project URL
%         license: license text
%         citation: citation text
%         acknowledgement: acknowledgements text
%         deploy_voy: deployment cruise
%         start_date: start date of deplyment as datenum
%         pro_o_start_date: Start date for Pro Oceanus O2 sensor
%         pro_o_K_start_date: Start date for Pro Oceanus K O2 sensor
%         end_date: end date of deployment (now for current)
% Maybe split out this calibration / processing info
%         SBO processing info: 
%         sbo_nv: number of SBO instruments (microcats)
%         sbo: nominal depth & serial number of microcats (2 x sbo_nv)
%         sbo_press_corr: pressure correction for microcats (1 x sbo_nv)
%         b: Scaled temperature correction constants (1x4)
%         c0: Scaled temperature correction constant
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
meta.mooring = 'PAP';
meta.mooring_no = '1'; % May change with deployment (PAP, PAP4 etc)
[meta.wmo_platform_code, meta.os_id, meta.os_platform_code, meta.os_site_code] = ...
  wmo_codes(meta.mooring,meta.mooring_no);

% Mooring position info - check this is constant for all deployments
% position from Paul to within 50m 48.99320 N, 16.36947 W.
% from guessing when ship is in close proximity  49.01285 -16.3749
meta.anchor_lon = -16.31896;
meta.anchor_lat = 49.02946;
meta.site_lon = -16.5; % Used for netCDF file position and +/- 2.5deg for limits
meta.site_lat = 49.0;
%% Data Metadata
meta.db_table = [meta.name deploy]; % deploy is 1-9 or yyyymm
meta.mode = 'R';
meta.ncVerNo = 3;
meta.history_in = 'Near real-time processed quality controlled at DAC';
meta.comment_in = 'no comment';
meta.pi_name = 'Richard Lampitt';
meta.principal_investigator_email = 'Richard.Lampitt at noc.ac.uk';
meta.principal_investigator_url = 'http://noc.ac.uk/people/rsl';
meta.source_institution = 'NOC';
meta.update_interval = 'daily';
meta.institution_references = 'http://noc.ac.uk';
meta.data_area = 'North Atlantic Ocean';
meta.mc_Sensor_Sampling_Frequency = 'Every 30 minutes';
meta.mc_Sensor_Reporting_Time = 'No comment';
meta.os_format_version = '1.3';
meta.os_platform_category = 'Physical, Biogeochemical';
meta.os_data_type = 'Oceansites time-series';
meta.os_data_source = 'Mooring observation';
meta.os_title = 'Oceanographic Data';
meta.os_conventions = 'CF-1.6';
meta.contributor_name = 'Helen Snaith';
meta.contributor_role = 'Editor';
meta.contributor_email = 'bodcnocs at bodc.ac.uk';
meta.author = 'Helen Snaith';
meta.publisher_name = 'Helen Snaith';
meta.publisher_email = 'h.snaith at bodc.ac.uk';
meta.contacts_email = 'bodcnocs@noc.soton.ac.uk';
meta.keywords_vocabulary = 'SeaDataNet Parameter Discovery Vocabulary';
meta.keywords = 'WC_Temp, WC_Sal, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/, http://vocab.nerc.ac.uk/collection/P02/current/DOXY/';


%% Deployment specific Info
meta.license = '';
meta.citation = '';
meta.acknowledgement = '';

switch deploy
  case '201704'
    % Deployment
    meta.project = 'FixO3';
    meta.deploy_voy = 'RSS Discovery DY032';
    % Dates - save as datenum then output to range of formats when needed
    meta.start_date = datenum('2017-04-20 12:30:00');
    meta.pro_o_start_date = meta.start_date; % only define if different
    meta.pro_o_K_start_date = meta.start_date; % only define if different
    meta.end_date = now; % set to now

    % Directories for graph output
    % Should be able to set same for all deployments if rename directories!
    % gr.webdir = ['/noc/users/animate/img/pap_' datestr(meta.start_date,'yyyy_mmm') '/'];
    gr.webdir = ['/noc/itg/www/apps/pap/pap_' datestr(meta.start_date,'yyyy_mmm') '/'];
    % gr.webdir2 = ['/data/ncs/www/eurosites/pap/pap_' datestr(meta.start_date,'yyyy_mmm') '/'];

    gr.dep_name = datestr(meta.start_date,'mmmm yyyy'); % Used for graph title
    gr.x_lab = ['Date (' datestr(meta.start_date,'yyyy') '-' datestr(meta.end_date,'yyyy') ')']; % graph x axis label

    % Parameters needed for SBO processing
    meta.sbo_nv = 3;
    meta.sbo = [1,9030; 30,10535; 30,13397];     % amended to be serial numbers for current deployment
    meta.sbo_press_corr = [0, 0, 0];
    gr.sboYlim = []; % previous [5 7];Used to set Y Limits on sbo graphs
    % Constants for scaled temperature calculation
    meta.b = [-0.00624097 -0.00693498 -0.00690358 -0.00429155];
    meta.c0 = -0.000000311680;
  
    % Parameters needed for FET processing
    meta.fet_nv = 2;
    meta.fet = [1, 257;30, 63];		% Depth & serial numbers for current deployment
    gr.fetYlim = [7.5 8.5];			% used to set Y limits on fet graphs

    % Parameters for Aanderaa 4430H (S/N 2001) Seaguard Oxygen processing
    meta.Aa_ox_calib = [1.0025 13.313]; % slope & offset from cruise report

    % Parameters for Turner cyclops (S/N 2103960) Seaguard Chlorophyll processing
    % from regression against bottle data in calibration dip
    meta.cyclops_calib = [0.0951 0.0937]; %  slope & offset from from cruise report
    gr. chlYlim = [0.0, 2.0]; % Used to set Y limits of chlorophyll graphs

    % Parameters for OC processing
    meta.oc_nv = 3;

    % Parameters for Wetlabs processing
    meta.wet_instr_calib = [1 690 0]; % sn 3050 2015 [slope offset cwo]
    % from regression against bottle chl in calibration dip - 2017 data from Corinne
    meta.wet_calib = [0.2225 0.0934]; % slope & offset

end % End of deployment switch

%% Update Project specific information
acknowledgement = ...
  ['When you use %s data in publications please acknowledge the %s Project (%s).;' ...
   'Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data for inclusion in the %s bibliography.;' ...
   'These publications should be sent to: %s Data Manager - BODC Data Management,;' ...
   'National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];

 switch meta.project
   case 'ANIMATE'
     meta.project_title = 'ANIMATE Atlantic Network of Interdisciplinary Moorings and Time-series for Europe.';
     meta.project_contract = 'EU FP5 contract EVR1-CT-2001-40014.';
     meta.acknowledgement = ...
       sprintf(acknowledgement,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
   case 'MERSEA'
     meta.project_title = 'MERSEA Marine EnviRonment and Security for the European Area - Integrated Project. WP3 In Situ Ocean Observing Systems.';
     meta.project_contract = 'EU FP6 contract AIP3-CT-2003-502885'; % see also citation
     meta.acknowledgement = ...
       sprintf(acknowledgement,meta.project, meta.project, meta.project_contract, 'ANIMATE/MERSEA', 'ANIMATE/MERSEA');
   case 'EuroSITES'
     meta.project_title = 'EuroSITES European Ocean Observatory Network';
     meta.project_contract = 'EU FP7 collaborative project contract FP7-ENV-2007-1-202955'; % see also citation
     meta.acknowledgement = ...
       sprintf(acknowledgement,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
   case 'FixO3'
     meta.project_title = 'FixO3: Fixed-point Open Ocean Observatories';
     meta.project_contract = 'EU FP7 project (FP7/2007-2013) under grant agreement No 312463'; % see also citation
     meta.acknowledgement = ...
       sprintf(acknowledgement,meta.project, meta.project, meta.project_contract, meta.project, meta.project);
     meta.os_network = 'FixO3';
     meta.data_assembly_center = 'FixO3 DAC';
     meta.publisher_url = 'http://www.fixo3.eu';
     meta.references='http://www.fixo3.eu, http://www.oceansites.org, http://www.coriolis.eu.org, http://www.eurosites.info';
   otherwise
     meta.acknowledgement = ['When you use these data in publications please acknowledge the NOC.;' ...
       'Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data.;' ...
       'These publications should be sent to: BODC Data Management,;' ...
       'National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];
 end
 meta.acknowledgement = char(strsplit(meta.acknowledgement,';'));

