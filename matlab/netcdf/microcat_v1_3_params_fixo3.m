% for FixO3
% should be in calling script
%20140514 cell methods removed LATITUDE LONGITUDE

[ref_tab_2, ref_tab_3] = oceansites_ref_tables;
if   ~exist('institution_references','var')
  institution_references='http://www.noc.soton.ac.uk';
end
author='Maureen Pagnani';
publisher_name='Maureen Pagnani';
publisher_email='m.pagnani at bodc.ac.uk';
data_assembly_center='FixO3 DAC'
publisher_url='http://www.fixo3.eu';
contacts_email='noc-bodc@noc.soton.ac.uk'

if ~exist('comment_in','var'), comment_in='no comment'; end;
%QC_indicator='1';

quality_control_indicator = ref_tab_2{QC_indicator+1}; 				%see Oceansites table 2.1
if ~exist('quality_index','var') quality_index='B'; end;    %see Oceansites manual global attibute depending on source B pre PI, A after PI

% currently only ????_QC ancillary_variables='';
references=' http://www.fixo3.eu, http://www.oceansites.org, http://www.coriolis.eu.org, http://www.eurosites.info';
update_interval='void';
time_uncertainty=0.000005;   % 2.3 mins per year  0.5 second a day
if ~exist('qc_manual','var')
	if (mode =='D')
	  qc_manual='Calibration of Physical Data Microcat, TD-Logger, ADCP, RCM by Johannes Karstensen, IFM-GEOMAR, January 2005';
	else
	 qc_manual='MERSEA: In-situ real-time data quality control. Mersea-WP03-IFR-UMAN-001-02A, November 2005';
	end
end
qc_manual
data_source='Mooring observation';
if ~exist('data_area','var') nc.area='North Atlantic Ocean'; 
else                    nc.area=data_area;
end
os_platform_category='Physical, Biogeochemical';
os_data_type='Oceansites time-series';
os_title='Oceanographic Data';
os_network='FixO3';
os_format_version='1.3';
os_conventions='CF-1.6';
%, OceanSITES Manual 1.3';
mc_Sensor_Vendor='Seabird';
mc_Sensor_Sampling_Period='instantaneous';
if (exist('mc_Sensor_Reporting_Time')<1) mc_Sensor_Reporting_Time='No comment'; end
if (exist('rt_sample_period_text')<1) rt_sample_period_text='not applicable'; end

keywords_vocabulary='SeaDataNet Parameter Discovery Vocabulary';
keywords='WC_Temp, WC_Sal,http://vocab.nerc.ac.uk/collection/P02/current/TEMP/,http://vocab.nerc.ac.uk/collection/P02/current/PSAL/';


% 16Oct2009 QC required for GTS distribution
time_qc_indicator=ref_tab_2(2);
time_qc_procedure=ref_tab_3(2);
depth_qc_indicator=ref_tab_2(2);
depth_qc_procedure=ref_tab_3(2);
lat_qc_indicator=ref_tab_2(2);
lat_qc_procedure=ref_tab_3(2);
long_qc_indicator=ref_tab_2(2);
long_qc_procedure=ref_tab_3(2);

global_qcProcLevel=ref_tab_3(2);

lat_uncertainty=0.05;
lat_accuracy=999;
lat_precision=999;
lat_resolution=999;

long_uncertainty=0.05;
long_accuracy=999;
long_precision=999;
long_resolution=999;


%values copied from http://tao.noaa.gov/proj_overview/sensors_ndbc.shtml for seabird SBE37 

% will not be output if value is 999;
temp_uncertainty=999;
temp_accuracy=0.003;
temp_precision=999;
temp_resolution=0.001;
temp_cell_methods='TIME: point DEPTH: point';

cond_uncertainty=999;
cond_accuracy=0.02;
cond_precision=999;
cond_resolution=0.001;
cond_cell_methods='TIME: point DEPTH: point';

press_uncertainty=999;
press_accuracy=0.25;
press_precision=999;
press_resolution=0.03;
press_cell_methods='TIME: point DEPTH: point';

psal_uncertainty=999;
psal_accuracy=0.02;
psal_precision=999;
psal_resolution=999;
psal_cell_methods='TIME: point DEPTH: point';

doxy_uncertainty=999;  % from PoB ferrybox paper eprints.soton.ac.uk/48673/
doxy_accuracy=8;    %microMol/l  % Aanderaa Oxygen Optodes_3.pdf
doxy_precision=5;  %std dev microMol / l
doxy_resolution=1;
doxy_cell_methods='TIME:point DEPTH:point';

doxy_temp_uncertainty=999;  % from PoB ferrybox paper eprints.soton.ac.uk/48673/
doxy_temp_accuracy=0.1;    %C
doxy_temp_precision=999;  %std dev microMol / l
doxy_temp_resolution=0.05;
doxy_temp_cell_methods='TIME:point DEPTH:point';

%default for wetlabs 
cphl_uncertainty=999;  
cphl_accuracy=999;    
cphl_precision=999;  
cphl_resolution=0.01;
cphl_cell_methods='TIME:point DEPTH:point';

