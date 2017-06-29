%% Define global attributes from metadata
g.site_code = site.site_code;
g.platform_code = site.platform_code;
g.data_mode = dat.mode;
g.title = ['OceanSITES ' OS_mooring ' in-situ data'];
g.summary = strcat(l0a,' ',l0b;
g.naming_authority = 'OceanSITES';
%g.data_type = 'OceanSITES time-series data';
id_len=length(OS_name)-3;
id_in=OS_name(1:id_len;
g.id = id_in;
g.name = id_in;
g.wmo_platform_code = wmo_platform_code;
g.source = 'Mooring observation';
if exist('pi_name') g.principal_investigator = pi_name;          end;
if exist('pi_email') g.principal_investigator_email = pi_email; end;
if exist('pi_url') g.principal_investigator_url = pi_url;     end;
g.institution = source_institution;
if exist('sdn_edmo_code') g.sdn_edmo_code = sdn_edmo_code;      end
if exist('project') g.project = project;                        end;
if exist('os_array') g.array = os_array;         	             end;
if exist('os_network') g.network = os_network;
else g.network,'FixO3' ;
end
if exist('keywords_vocabulary')
 g.keywords_vocabulary = keywords_vocabulary;  
 g.keywords = keywords;   
end;
g.comment = comment_in;


%%%%%%%%%%%%%WHERE
if exist('data_area')<1 g.area = 'North Atlantic Ocean'; 
else                    g.area = data_area;
end
g.geospatial_lat_min = num2str(moor_lat_min);
g.geospatial_lat_max = num2str(moor_lat_max);
g.geospatial_lat_units = 'degree_north';
g.geospatial_lon_min = num2str(moor_long_min);
g.geospatial_lon_max = num2str(moor_long_max);
g.geospatial_lon_units = 'degree_east';
g.geospatial_vertical_min = num2str(v(1));
g.geospatial_vertical_max = num2str(v(nvar));
g.geospatial_vertical_positive = 'down';
g.geospatial_vertical_units = 'meter';
g.time_coverage_start = [datestr(DateTime(1,1),29) 'T' datestr(DateTime(1,1),13) 'Z'];
g.time_coverage_end = [datestr(DateTime(end,1),29) 'T' datestr(DateTime(end,1),13) 'Z'];
if exist('time_coverage_duration')
   g.time_coverage_duration = 'time_coverage_duration'; 
else
   day_dur=floor(DateTime(end,1)-DateTime(1,1);
   g.time_coverage_duration = ['P' num2str(day_dur) 'D']; 
end;
if exist('time_coverage_resolution')
   g.time_coverage_resolution = 'time_coverage_resolution'; 
else
   time_res=(DateTime(2,1)-DateTime(1,1))*(24*60);
   g.time_coverage_resolution = ['PT' num2str(time_res) 'M']; 
end;

netcdf.putAtt(scope,NC_GLOBAL,'cdm_data_type = 'Station';

if exist('featureType')<1
	g.featureType = 'timeSeries';
else
	g.featureType = featureType;
end

g.data_type = 'OceanSITES time-series data';

%%%%%%%%%%conventions
g.format_version = os_format_version;
g.Conventions = os_conventions;
g.netcdf_version = netcdf_version;

%%%%%%%%%%%publication info

if exist('publisher_name')
  g.publisher_name = publisher_name;
else
  g.publisher_name = author;
end;
if exist('publisher_email')
  g.publisher_email = publisher_email;
else
  g.publisher_email = contacts_email;
end;
if exist('publisher_url')
  g.publisher_url = publisher_url;
else
  g.publisher_url = author;
end;

g.references = references;
g.institution_references = institution_references;
g.data_assembly_center = data_assembly_center;
g.update_interval = update_interval;

if ~exist('useLicense') 
 useLicense=['Follows CLIVAR (Climate Varibility and Predictability) standards, cf. http://www.clivar.org/data/data_policy.php. Data available free of charge. User assumes all risk for use of data. User must display citation in any publication or product using data. User must contact PI prior to any commercial use of data.'];
end;
g.license = useLicense;
    
if ~exist('citation') 
 citation=['These data were collected and made freely available by the EuroSITES and OceanSITES project and the national programs that contribute to it.'];
end;
g.citation = citation;

if ~exist('acknowledgement') 
 if exist('citation') 
 	acknowledgement=citation;
 else
 	acknowledgement='';
end;
end;
g.acknowledgement = acknowledgement;


%%%%%%%%%%%%%provenance
date_created=[datestr(now,29) 'T' datestr(now,13) 'Z'];
g.date_created = date_created;
if exist('date_modified') 
 g.date_modified = date_modified;
else
 g.date_modified = date_created;
end
g.history = history_in;
if exist('processing_level')
 g.processing_level = processing_level;
end;	
if exist('global_qcProcLevel')
 g.processing_level = global_qcProcLevel{:};
end;	
if exist('quality_control_indicator')
 g.QC_indicator = quality_control_indicator;
else
 g.QC_indicator = 'unknown';
end;	

if exist('contributor_name')
 g.contributor_name = [contributor_name];
else
 g.contributor_name = [institution_references];
end
if exist('contributor_role')
 g.contributor_role = [contributor_role];
end
if exist('contributor_email')
 g.contributor_name = [contributor_email];
end


% 1.3 only by parameter/variable
%g.quality_index = quality_index;
