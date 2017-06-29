function [site, dat, dep, gr] =  setup_mooring_pap(deploy)
%   [site, dat, dep, gr] =  setup_mooring_pap(deploy)
% Return site, data, deployment and graph settings for deployment 'deploy'
% deploy (in) : PAP deployment specifier string - number (1-9) or date of
%               deployment in yyyymm format (eg '210704')
% site (out) : structure containing site metadata for PAP mooring
%         name: Name of the Site (eg PAP)
%         mooring: Moorig identifier for OceanSITES (eg PAP)
%         anchor_lon: longitude of anchor position
%         anchor_lat: latitude of anchor position
%         site_lon: nominal longitude of anchor position
%         site_lat: nominal latitude of anchor position
% dat (out) : structure containing metadata - for reading and netCDF
%         db_table: root database table name (eg PAP201704)
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
%  dep (out): structure containing deployment metadata for PAP mooring
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
site.name = 'PAP';
site.mooring = 'PAP'; % May change with deployment (PAP, PAP4 etc)
% site.spmooring = [' ' mooring]; % just has space in front - not needed
% site.mooringlc = 'pap'; % just lower case - not needed

% Mooring position info - check this is constant for all deployments
% position from Paul to within 50m 48.99320 N, 16.36947 W.
% from guessing when ship is in close proximity  49.01285 -16.3749
site.anchor_lon = -16.31896;
site.anchor_lat = 49.02946;
site.site_lon = -16.5; % Used for netCDF file position and +/- 2.5deg for limits
site.site_lat = 49.0;
site.platform_code =  ;
site.wmo_platform_code = '62442';


%% Data Metadata
dat.db_table = [site.name deploy]; % deploy is 1-9 or yyyymm
dat.mode = 'R';
dat.ncVerNo = 3;
dat.history_in = 'Near real-time processed quality controlled at DAC';
dat.comment_in = 'no comment';
dat.pi_name = 'Richard Lampitt';
dat.principal_investigator_email = 'Richard.Lampitt at noc.ac.uk';
dat.principal_investigator_url = 'http://noc.ac.uk/people/rsl';
dat.source_institution = 'NOC';
dat.update_interval = 'daily';
dat.institution_references = 'http://noc.ac.uk';
dat.data_area = 'North Atlantic Ocean';
dat.mc_Sensor_Sampling_Frequency = 'Every 30 minutes';
dat.mc_Sensor_Reporting_Time = 'No comment';
dat.os_format_version = '1.3';
dat.os_platform_category = 'Physical, Biogeochemical';
dat.os_data_type = 'Oceansites time-series';
dat.os_data_source = 'Mooring observation';
dat.os_title = 'Oceanographic Data';
dat.os_conventions = 'CF-1.6';
dat.contributor_name = 'Helen Snaith';
dat.contributor_role = 'Editor';
dat.contributor_email = 'bodcnocs at bodc.ac.uk';
dat.author = 'Helen Snaith';
dat.publisher_name = 'Helen Snaith';
dat.publisher_email = 'h.snaith at bodc.ac.uk';
dat.contacts_email = 'bodcnocs@noc.soton.ac.uk';
dat.keywords_vocabulary = 'SeaDataNet Parameter Discovery Vocabulary';
dat.keywords = 'WC_Temp, WC_Sal, http://vocab.nerc.ac.uk/collection/P02/current/TEMP/, http://vocab.nerc.ac.uk/collection/P02/current/PSAL/, http://vocab.nerc.ac.uk/collection/P02/current/DOXY/';


%% Deployment specific Info
dep.license = '';
dep.citation = '';
dep.acknowledgement = '';

switch deploy
  case '201704'
    % Deployment
    dep.project = 'FixO3';
    dep.deploy_voy = 'RSS Discovery DY032';
    % Dates - save as datenum then output to range of formats when needed
    dep.start_date = datenum('2017-04-20 12:30:00');
    dep.pro_o_start_date = dep.start_date; % only define if different
    dep.pro_o_K_start_date = dep.start_date; % only define if different
    dep.end_date = now; % set to now

    % Directories for graph output
    % Should be able to set same for all deployments if rename directories!
    % gr.webdir = ['/noc/users/animate/img/pap_' datestr(dep.start_date,'yyyy_mmm') '/'];
    gr.webdir = ['/noc/itg/www/apps/pap/pap_' datestr(dep.start_date,'yyyy_mmm') '/'];
    % gr.webdir2 = ['/data/ncs/www/eurosites/pap/pap_' datestr(dep.start_date,'yyyy_mmm') '/'];

    gr.dep_name = datestr(dep.start_date,'mmmm yyyy'); % Used for graph title
    gr.x_lab = ['Date (' datestr(dep.start_date,'yyyy') '-' datestr(dep.end_date,'yyyy') ')']; % graph x axis label

    % Parameters needed for SBO processing
    dep.sbo_nv = 3;
    dep.sbo = [1,9030; 30,10535; 30,13397];     % amended to be serial numbers for current deployment
    dep.sbo_press_corr = [0, 0, 0];
    gr.sboYlim = []; % previous [5 7];Used to set Y Limits on sbo graphs
    % Constants for scaled temperature calculation
    dep.b = [-0.00624097 -0.00693498 -0.00690358 -0.00429155];
    dep.c0 = -0.000000311680;
  
    % Parameters needed for FET processing
    dep.fet_nv = 2;
    dep.fet = [1, 257;30, 63];		% Depth & serial numbers for current deployment
    gr.fetYlim = [7.5 8.5];			% used to set Y limits on fet graphs

    % Parameters for Aanderaa 4430H (S/N 2001) Seaguard Oxygen processing
    dep.Aa_ox_calib = [1.0025 13.313]; % slope & offset from cruise report

    % Parameters for Turner cyclops (S/N 2103960) Seaguard Chlorophyll processing
    % from regression against bottle data in calibration dip
    dep.cyclops_calib = [0.0951 0.0937]; %  slope & offset from from cruise report
    gr. chlYlim = [0.0, 2.0]; % Used to set Y limits of chlorophyll graphs

    % Parameters for OC processing
    dep.oc_nv = 3;

    % Parameters for Wetlabs processing
    dep.wet_instr_calib = [1 690 0]; % sn 3050 2015 [slope offset cwo]
    % from regression against bottle chl in calibration dip - 2017 data from Corinne
    dep.wet_calib = [0.2225 0.0934]; % slope & offset

end % End of deployment switch

%% Update Project specific information
acknowledgement = ...
  ['When you use %s data in publications please acknowledge the %s Project (%s).;' ...
   'Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data for inclusion in the %s bibliography.;' ...
   'These publications should be sent to: %s Data Manager - BODC Data Management,;' ...
   'National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];

switch dep.project
	case 'ANIMATE'
	      dep.acknowledgement = ...
          sprintf(acknowledgement,dep.project, dep.project, 'EU FP5 contract EVR1-CT-2001-40014', dep.project, dep.project);
	case 'MERSEA' 
	      dep.acknowledgement = ...
          sprintf(acknowledgement,dep.project, dep.project, 'EU FP6 contract AIP3-CT-2003-502885', 'ANIMATE/MERSEA', 'ANIMATE/MERSEA');
	case 'EuroSITES' 
	      dep.acknowledgement = ...
          sprintf(acknowledgement,dep.project, dep.project, 'FP7-ENV-2007-1, grant agreement No 202955', dep.project, dep.project);
	case 'FixO3' 
	      dep.acknowledgement = ...
          sprintf(acknowledgement,dep.project, dep.project, 'FP7/2007-2013, grant agreement No 312463', dep.project, dep.project);
        dep.os_network = 'FixO3';
        dep.data_assembly_center = 'FixO3 DAC';
        dep.publisher_url = 'http://www.fixo3.eu';
        dep.references='http://www.fixo3.eu, http://www.oceansites.org, http://www.coriolis.eu.org, http://www.eurosites.info';
    otherwise
	      dep.acknowledgement = ['When you use these data in publications please acknowledge the NOC.;' ...
            'Also, we would appreciate receiving a preprint and/or reprint of publications utilizing these data.;' ...
            'These publications should be sent to: BODC Data Management,;' ...
            'National Oceanography Centre, Southampton, SO14 3ZH, UK (email bodcnocs@bodc.ac.uk)'];
end
dep.acknowledgement = char(strsplit(dep.acknowledgement,';'));
