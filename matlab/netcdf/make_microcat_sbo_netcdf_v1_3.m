% create netcdf file
disp 'in make_microcat_sbo_netcdf_v1_3_native'
pcmd='lpr -s -r -h';

size_DateTime=size(DateTime,1)

if exist('mc_sensor_mount') <1 
	mc_sensor_mount='mounted on mooring line'; 
end
if exist('mc_sensor_orientation') <1 
	mc_sensor_orientation='vertical'; 
end

first_char=mooringlc(1);

wmo_codes;
oceansites_ref_tables;

if (exist('mc_Sensor_Depth')<1)
	mc_Sensor_Depth='';
	for j=1:nvar
	 mc_Sensor_Depth=[mc_Sensor_Depth int2str(v(j)) ', '];
	end
	qc=size(mc_Sensor_Depth);
	mc_Sensor_Depth(qc(2)-1)=' ';
	mc_Sensor_Depth=[mc_Sensor_Depth 'm(s)'];
end

if (exist('mc_sensor_serial_number')<1)
	mc_sensor_serial_number='';
	for j=1:nvar
	 mc_sensor_serial_number=[mc_sensor_serial_number int2str(serial_no(j)) ', '];
	end
	qc=size(mc_sensor_serial_number);
	mc_sensor_serial_number(qc(2))=' ';
end


%
qc_flag_values=int8(0:9);
%qc_flag_meanings='no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value';
qc_flag_meanings='unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value';
OS_date=[StartDate(1:4) StartDate(6:7)];
%[qq1 qq2]=size(mooring);
%OS_mooring=mooring(1:(qq2-1));
% 20071218 mred
%qq2=find(platform_code=='-');
%OS_mooring=platform_code(1:(qq2-1));
OS_mooring=site_code;
cd(DIR);
DIR
%nc_file=strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.nc');
os_namer
if (exist('os_namer')<1)
	os_name_type=[mode '_CTD'];
else    
	os_name_type=[mode '_' os_namer];	
end
OS_name=strcat('OS_', OS_mooring,'-', mooring_no, '_', OS_date, '_', os_name_type, '.nc')

disp 'starting native netcdf' 
if exist('ncVerNo') 
	if ncVerNo >3 
		ncVer='NETCDF4';
		netcdf_version='4.0';
	else;
		ncVer='CLASSIC_MODEL';
		netcdf_version='3.5';
	end
else
		ncVer='CLASSIC_MODEL';
		netcdf_version='3.5';
end
NC_GLOBAL=netcdf.getConstant('NC_GLOBAL');
if exist(OS_name,'file')
    disp 'clobber netcdf file'
    ncMode = netcdf.getConstant(ncVer);    
    ncMode = bitor(ncMode,netcdf.getConstant('NC_CLOBBER'));
    scope=netcdf.create(OS_name,ncMode);  
   % netcdf.reDef(scope);
else
    disp 'create netcdf file'
    ncMode = netcdf.getConstant(ncVer);
    scope=netcdf.create(OS_name,ncMode);
end
os_description=['File of temperature, conductivity, salinity, oxygen and pressure data collected at',spmooring,' mooring number ',mooring_no,' at ',num2str(lat),' Degrees N ',num2str(long),' Degrees W',' Deployment between ',startdate,' and ',enddate];
netcdf.putAtt(scope,NC_GLOBAL,'summary',os_description);
%nc.description=os_description;
if (project == 'ANIMATE  ')
	l0a='ANIMATE Atlantic Network of Interdisciplinary Moorings and Time-series for Europe.';
	l0b='EU Project EVR1-CT-2001-40014.';
end
if (project == 'MERSEA   ')
  l0a='MERSEA Marine EnviRonment and Security for the European Area - Integrated Project. WP3 In Situ Ocean Observing Systems.';
  l0b='EU Framework 6 contract AIP3-CT-2003-502885'; % see also citation 
end
if (project == 'EuroSITES')
  l0a='EuroSITES European Ocean Observatory Network';
  l0b='EU Framework 7 collaborative project contract FP7-ENV-2007-1-202955'; % see also citation 
end
if (project == 'FixO3    ')
  l0a='FixO3: Fixed-point Open Ocean Observatories';
  l0b='EU Framework 7 project (FP7/2007-2013) under grant agreement n� [312463],'; % see also citation 
end

l1=['File of temperature, conductivity and pressure data collected at' spmooring ' mooring number ' mooring_no '. WMO number ' wmo_platform_code];
l2=['at ' num2str(lat) ' Degrees N ' num2str(long) ' Degrees W' ' Deployment between ' startdate ' and ' enddate];
if exist('deploy_voy')
	l2a=['Deployment voyage: ', deploy_voy];
else
  l2a=' ';
end
if exist('recover_voy')
	l2b=['Recovery voyage: ', recover_voy];
else
  l2b=' ';
end
l2c=['File created on ' datestr(now)];
l3='The data in this file are :- ';
l4='year';
l5='month';
l6='day';
l7='hour';
l8='minute';
l9='second';
l10=['temperatures (Celcius)1 to ' int2str(nvar)];
l10a=['temperature quality 1 to ' int2str(nvar)];
if exist('C')
  l11=['conductivities (mS/cm)1 to ' int2str(nvar)];
  l11a=['conductivity quality 1 to ' int2str(nvar)];
else
  l11='';
  l11a='';
end
l12=['pressures (dbar) 1 to ' int2str(nvar)];
l12a=['pressure quality 1 to ' int2str(nvar)];
l13=['salinities (PSU) 1 to ' int2str(nvar)];
l13a=['salinity quality 1 to ' int2str(nvar)];
l14=' ';
l15=['Data were measured at ' int2str(nvar) ' sensors at the nominal depth(s) of ' int2str(v) ' meter(s).'];
lsensor=['Nominal Depth  Serial No. Sensor Type';];
clear lsensor2;
for n=1:nvar;
lsensor2(n,:)=sprintf('%8.1f      %5u      %s \n',v(n),serial_no(n), mc_sensor_type(n,:));
end
lprocessing=['The data have been processed as described in the document ', qc_manual];

l15a=' ';
l16='Quality Indicators are :- ';
l17='  0        No Quality Control performed';
l18='  1        Good data';
l19='  2        Probably good data';
l20='  3        Bad data that are potentially correctable';
l21='  4        Bad data';
l22='  5        Value changed';
l23='  6        Not used';
l24='  7        Not used';
l25='  8        Interpolated value';
l26='  9        Missing value';

if ~exist('lcitation') lcitation=''; end
if ~exist('readme_comment') readme_comment = ''; end
readme_txt=strvcat(l0a,l0b,l1,l2,l2a,l2b,l2c,l3,l4,l5,l6,l7,l8,l9,l10,l10a,l11,l11a,l12,l12a,l13,l13a,l14,l15,lsensor,lsensor2,lprocessing,l15a,l16,l17,l18,l19,l20,l21,l22,l23,l24,l25,l26,lcitation,readme_comment);
%nc.source=strcat(l0a,' ',l0b);

%%% GLOBAL ATTRIBUTES
netcdf.putAtt(scope,NC_GLOBAL,'site_code',site_code);
netcdf.putAtt(scope,NC_GLOBAL,'platform_code',platform_code);
netcdf.putAtt(scope,NC_GLOBAL,'data_mode',mode);
nc_title=['OceanSITES ' OS_mooring ' in-situ data'];
netcdf.putAtt(scope,NC_GLOBAL,'title',nc_title);
netcdf.putAtt(scope,NC_GLOBAL,'summary',strcat(l0a,' ',l0b));
netcdf.putAtt(scope,NC_GLOBAL,'naming_authority','OceanSITES');
%netcdf.putAtt(scope,NC_GLOBAL,'data_type','OceanSITES time-series data');
id_len=length(OS_name)-3;
id_in=OS_name(1:id_len);
netcdf.putAtt(scope,NC_GLOBAL,'id',id_in);
netcdf.putAtt(scope,NC_GLOBAL,'name',id_in);
netcdf.putAtt(scope,NC_GLOBAL,'wmo_platform_code',wmo_platform_code);
netcdf.putAtt(scope,NC_GLOBAL,'source','Mooring observation');
if exist('pi_name')netcdf.putAtt(scope,NC_GLOBAL,'principal_investigator',pi_name);          end;
if exist('pi_email') netcdf.putAtt(scope,NC_GLOBAL,'principal_investigator_email',pi_email); end;
if exist('pi_url') netcdf.putAtt(scope,NC_GLOBAL,'principal_investigator_url',pi_url);     end;
netcdf.putAtt(scope,NC_GLOBAL,'institution',source_institution);
if exist('sdn_edmo_code') netcdf.putAtt(scope,NC_GLOBAL,'sdn_edmo_code',sdn_edmo_code);      end
if exist('project') netcdf.putAtt(scope,NC_GLOBAL,'project',project);                        end;
if exist('os_array') netcdf.putAtt(scope,NC_GLOBAL,'array',os_array);         	             end;
if exist('os_network') netcdf.putAtt(scope,NC_GLOBAL,'network',os_network);
else netcdf.putAtt(scope,NC_GLOBAL,network,'FixO3' );
end
if exist('keywords_vocabulary')
 netcdf.putAtt(scope,NC_GLOBAL,'keywords_vocabulary',keywords_vocabulary);  
 netcdf.putAtt(scope,NC_GLOBAL,'keywords',keywords);   
end;
netcdf.putAtt(scope,NC_GLOBAL,'comment',comment_in);


%%%%%%%%%%%%%WHERE
if exist('data_area')<1 netcdf.putAtt(scope,NC_GLOBAL,'area','North Atlantic Ocean'); 
else                    netcdf.putAtt(scope,NC_GLOBAL,'area',data_area);
end
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lat_min',num2str(moor_lat_min));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lat_max',num2str(moor_lat_max));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lat_units','degree_north');
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lon_min',num2str(moor_long_min));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lon_max',num2str(moor_long_max));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_lon_units','degree_east');
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_vertical_min',num2str(v(1)));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_vertical_max',num2str(v(nvar)));
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_vertical_positive','down');
netcdf.putAtt(scope,NC_GLOBAL,'geospatial_vertical_units','meter');
netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_start',[datestr(DateTime(1,1),29) 'T' datestr(DateTime(1,1),13) 'Z']);
netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_end',[datestr(DateTime(end,1),29) 'T' datestr(DateTime(end,1),13) 'Z']);
if exist('time_coverage_duration')
   netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_duration','time_coverage_duration'); 
else
   day_dur=floor(DateTime(end,1)-DateTime(1,1));
   netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_duration',['P' num2str(day_dur) 'D']); 
end;
if exist('time_coverage_resolution')
   netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_resolution','time_coverage_resolution'); 
else
   time_res=(DateTime(2,1)-DateTime(1,1))*(24*60);
   netcdf.putAtt(scope,NC_GLOBAL,'time_coverage_resolution',['PT' num2str(time_res) 'M']); 
end;

netcdf.putAtt(scope,NC_GLOBAL,'cdm_data_type','Station');

if exist('featureType')<1
	netcdf.putAtt(scope,NC_GLOBAL,'featureType','timeSeries');
else
	netcdf.putAtt(scope,NC_GLOBAL,'featureType',featureType);
end

netcdf.putAtt(scope,NC_GLOBAL,'data_type','OceanSITES time-series data');

%%%%%%%%%%conventions
netcdf.putAtt(scope,NC_GLOBAL,'format_version',os_format_version);
netcdf.putAtt(scope,NC_GLOBAL,'Conventions',os_conventions);
netcdf.putAtt(scope,NC_GLOBAL,'netcdf_version',netcdf_version);

%%%%%%%%%%%publication info

if exist('publisher_name')
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_name',publisher_name);
else
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_name',author);
end;
if exist('publisher_email')
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_email',publisher_email);
else
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_email',contacts_email);
end;
if exist('publisher_url')
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_url',publisher_url);
else
  netcdf.putAtt(scope,NC_GLOBAL,'publisher_url',author);
end;

netcdf.putAtt(scope,NC_GLOBAL,'references',references);
netcdf.putAtt(scope,NC_GLOBAL,'institution_references',institution_references);
netcdf.putAtt(scope,NC_GLOBAL,'data_assembly_center',data_assembly_center);
netcdf.putAtt(scope,NC_GLOBAL,'update_interval',update_interval);

if ~exist('useLicense') 
 useLicense=['Follows CLIVAR (Climate Varibility and Predictability) standards, cf. http://www.clivar.org/data/data_policy.php. Data available free of charge. User assumes all risk for use of data. User must display citation in any publication or product using data. User must contact PI prior to any commercial use of data.'];
end;
netcdf.putAtt(scope,NC_GLOBAL,'license',useLicense);
    
if ~exist('citation') 
 citation=['These data were collected and made freely available by the EuroSITES and OceanSITES project and the national programs that contribute to it.'];
end;
netcdf.putAtt(scope,NC_GLOBAL,'citation',citation);

if ~exist('acknowledgement') 
 if exist('citation') 
 	acknowledgement=citation;
 else
 	acknowledgement='';
end;
end;
netcdf.putAtt(scope,NC_GLOBAL,'acknowledgement',acknowledgement);


%%%%%%%%%%%%%provenance
date_created=[datestr(now,29) 'T' datestr(now,13) 'Z'];
netcdf.putAtt(scope,NC_GLOBAL,'date_created',date_created);
if exist('date_modified') 
 netcdf.putAtt(scope,NC_GLOBAL,'date_modified',date_modified);
else
 netcdf.putAtt(scope,NC_GLOBAL,'date_modified',date_created);
end
netcdf.putAtt(scope,NC_GLOBAL,'history',history_in);
if exist('processing_level')
 netcdf.putAtt(scope,NC_GLOBAL,'processing_level',processing_level);
end;	
if exist('global_qcProcLevel')
 netcdf.putAtt(scope,NC_GLOBAL,'processing_level',global_qcProcLevel{:});
end;	
if exist('quality_control_indicator')
 netcdf.putAtt(scope,NC_GLOBAL,'QC_indicator',quality_control_indicator);
else
 netcdf.putAtt(scope,NC_GLOBAL,'QC_indicator','unknown');
end;	

if exist('contributor_name')
 netcdf.putAtt(scope,NC_GLOBAL,'contributor_name',[contributor_name]);
else
 netcdf.putAtt(scope,NC_GLOBAL,'contributor_name',[institution_references]);
end
if exist('contributor_role')
 netcdf.putAtt(scope,NC_GLOBAL,'contributor_role',[contributor_role]);
end
if exist('contributor_email')
 netcdf.putAtt(scope,NC_GLOBAL,'contributor_name',[contributor_email]);
end


% 1.3 only by parameter/variable
%netcdf.putAtt(scope,NC_GLOBAL,'quality_index',quality_index);

%%%%%%%%% DIMENSIONS

dimidT = netcdf.defDim(scope,'TIME',size_DateTime);
dimidD = netcdf.defDim(scope,'DEPTH',nvar);
LAT=lat
LON=long


varid=netcdf.defVar(scope,'TIME','NC_DOUBLE',[dimidT]);
netcdf.putAtt(scope,varid,'description','Date and Time from Matlab');
netcdf.putAtt(scope,varid,'long_name','time');
netcdf.putAtt(scope,varid,'standard_name','time');
netcdf.putAtt(scope,varid,'units','days since 1950-01-01T00:00:00Z' );
netcdf.putAtt(scope,varid,'conventions','Relative julian days with decimal part (as parts of the day)' );
netcdf.putAtt(scope,varid,'valid_min',0.0);
netcdf.putAtt(scope,varid,'valid_max',90000.0);
netcdf.putAtt(scope,varid,'QC_indicator',time_qc_indicator{:});
netcdf.putAtt(scope,varid,'processing_level',time_qc_procedure{:});
netcdf.putAtt(scope,varid,'uncertainty',time_uncertainty);
netcdf.putAtt(scope,varid,'axis','T' );
netcdf.endDef(scope);
netcdf.putVar(scope,varid,DateTime_nc(:,1));
netcdf.reDef(scope);

varid=netcdf.defVar(scope,'DEPTH','NC_FLOAT',[dimidD]);
netcdf.putAtt(scope,varid,'long_name','Depth of each measurement');
netcdf.putAtt(scope,varid,'standard_name','depth');
netcdf.putAtt(scope,varid,'units','meters');
netcdf.putAtt(scope,varid,'positive','down');
netcdf.putAtt(scope,varid,'valid_min',0.0);
netcdf.putAtt(scope,varid,'valid_max',12000.0);
if exist('P') netcdf.putAtt(scope,varid,'comment', 'These are nominal values. Use PRES to derive time-varying depths of instruments, as the mooring may tilt in ambient currents.'); end
if exist('D') netcdf.putAtt(scope,varid,'comment', 'These are nominal values. Use DEPTH to derive time-varying depths of instruments, as the mooring may tilt in ambient currents.'); end
netcdf.putAtt(scope,varid,'QC_indicator',depth_qc_indicator{:});
netcdf.putAtt(scope,varid,'processing_level',depth_qc_procedure{:});
netcdf.putAtt(scope,varid,'uncertainty','0');
netcdf.putAtt(scope,varid,'axis','Z');
netcdf.putAtt(scope,varid,'reference','sea_level');
netcdf.putAtt(scope,varid,'coordinate_reference_frame','urn:ogc:def:crs:EPSG::5831');
netcdf.endDef(scope);
netcdf.putVar(scope,varid,v(1,1:nvar));
netcdf.reDef(scope);


if (exist('LAT') && exist('LONG'))
	dimidLat = netcdf.defDim(scope,'LATITUDE',size(DateTime,1));
	dimidLon = netcdf.defDim(scope,'LONGITUDE',size(DateTime,1));
else
	dimidLat = netcdf.defDim(scope,'LATITUDE',1);
	dimidLon = netcdf.defDim(scope,'LONGITUDE',1);
%	dimidPos = netcdf.defDim(scope,'POSITION',1);
end

varidlat=netcdf.defVar(scope,'LATITUDE','NC_FLOAT',[dimidLat]);
varidlon=netcdf.defVar(scope,'LONGITUDE','NC_FLOAT',[dimidLon]);

netcdf.putAtt(scope,varidlat,'QC_indicator',lat_qc_indicator{:});
netcdf.putAtt(scope,varidlat,'processing_level',lat_qc_procedure{:});
netcdf.putAtt(scope,varidlat,'long_name','Latitude of each location');
netcdf.putAtt(scope,varidlat,'standard_name','latitude');
netcdf.putAtt(scope,varidlat,'units','degrees_north');
netcdf.putAtt(scope,varidlat,'valid_min', (-90.0));
netcdf.putAtt(scope,varidlat,'valid_max',(90.0));
netcdf.putAtt(scope,varidlat,'comment',['LATITUDE Latitude for each point']);
netcdf.putAtt(scope,varidlat,'ancillary_variables','LATITUDE_QC');
if (lat_uncertainty<999) 	netcdf.putAtt(scope,varidlat,'uncertainty',lat_uncertainty);	end
if (lat_accuracy<999)  		netcdf.putAtt(scope,varidlat,'accuracy',lat_accuracy); 		    end
if (lat_precision<999) 		netcdf.putAtt(scope,varidlat,'precision',lat_precision); 		end
if (lat_resolution<999)		netcdf.putAtt(scope,varidlat,'resolution',lat_resolution);		end
netcdf.putAtt(scope,varidlat,'axis','Y');
netcdf.putAtt(scope,varid,'reference','WGS84');
netcdf.putAtt(scope,varid,'coordinate_reference_frame','urn:ogc:def:crs:EPSG::4326');

netcdf.putAtt(scope,varidlon,'QC_indicator',long_qc_indicator{:});
netcdf.putAtt(scope,varidlon,'procedding_level',long_qc_procedure{:});
netcdf.putAtt(scope,varidlon,'long_name','Longitude of each location');
netcdf.putAtt(scope,varidlon,'standard_name','longitude');
netcdf.putAtt(scope,varidlon,'units','degrees_east');
netcdf.putAtt(scope,varidlon,'valid_min', (-180));
netcdf.putAtt(scope,varidlon,'valid_max', (180));
netcdf.putAtt(scope,varidlon,'comment',['LONGITUDE Longitude for each point']);
netcdf.putAtt(scope,varidlon,'ancillary_variables','LONGITUDE_QC');
if (long_uncertainty<999) 	netcdf.putAtt(scope,varidlon,'uncertainty',long_uncertainty);	end
if (long_accuracy<999)  	netcdf.putAtt(scope,varidlon,'accuracy',long_accuracy); 		end
if (long_precision<999) 	netcdf.putAtt(scope,varidlon,'precision',long_precision); 		end
if (long_resolution<999)	netcdf.putAtt(scope,varidlon,'resolution',long_resolution);		end
netcdf.putAtt(scope,varidlon,'axis','X');
netcdf.putAtt(scope,varid,'reference','WGS84');
netcdf.putAtt(scope,varid,'coordinate_reference_frame','urn:ogc:def:crs:EPSG::4326');

netcdf.endDef(scope);
if (exist('LAT') && exist('LONG'))
	netcdf.putVar(scope,varidlat,LAT);
	netcdf.putVar(scope,varidlon,LONG);
else
	netcdf.putVar(scope,varidlat,lat);
	netcdf.putVar(scope,varidlon,long);
end
netcdf.reDef(scope);

if (exist('pos'))
	varidpos=netcdf.defVar(scope,'POSITION','NC_FLOAT',[dimidPos]);
	netcdf.putVar(scope,varidpos,pos);

%easterly will be positive, westerly, negative
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%20140207 1200
% removed temporarily 11-Apr-14 Is this still needed?
%if (exist('POSN_QC'))
%	varid=netcdf.defVar(scope,'POSN_QC','double',[dimidPos]);       
%	nc('POSITION')=size(DateTime,1);;
%	nc{'POSITION'}=ncbyte('POSITION');
%	nc{'POSITION_QC'}=ncbyte('POSITION');
%	nc{'POSITION_QC'}(:)=POSN_QC;		
%	netcdf.putAtt(scope,varid,'long_name','quality flag');
%	netcdf.putAtt(scope,varid,'conventions','OceanSITES reference table 2');
%	netcdf.putAtt(scope,varid,'comment',['Quality Marker for each position, latitude and longitude pair']);
%	netcdf.defVarFill(scope,varid,'FillValue',false,fillValue);
%	nc{'POSITION_QC'}.valid_min= ncint(0);
%	nc{'POSITION_QC'}.valid_max= ncint(9);
%end
%%%%%%%%%%%%%% can I write a routine to do each variable?

clear gdac_meta;

gdac_metadata_form1;
gdac_metadata=gdac_form_1;

gdac_metadata_form2;
gdac_metadata=strvcat(gdac_metadata,gdac_form_2);

coordinates='TIME DEPTH LATITUDE LONGITUDE'
fillValue=99999.0
varStr='T';
if (exist(varStr))
    var=T;
    varname='TEMP';
    valid_min=2.0;
    valid_max=100.0;
    long_name='Temperature';
    standard_name='sea_water_temperature';
    units='degree_Celsius';
    var_qcName=strcat(varname, '_QC');
    var_qc=TQ;
    var_uncertainty=temp_uncertainty;
    var_accuracy=temp_accuracy;
    var_precision=temp_precision;
    var_resolution=temp_resolution;
    var_cell_methods=temp_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;
    var_comment=['Temperature in Degrees Celsius at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end


varStr='C';
if (exist(varStr))
    var=C;
    varname='CNDC';
    valid_min=25.0;
    valid_max=45.0;
    long_name='sea water electrical conductivity';
    standard_name='sea_water_electrical_conductivity';
    units='mS/cm';
    var_qcName=[varname '_QC'];
    var_qc=CQ;
    var_uncertainty=cond_uncertainty;
    var_accuracy=cond_accuracy;
    var_precision=cond_precision;
    var_resolution=cond_resolution;
    var_cell_methods=cond_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;
    var_comment=['Conductivity in mS/cm at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
    
end


varStr='S';
if (exist(varStr))

    var=S;
    varname='PSAL';
    valid_min=29.0;
    valid_max=40.00;
    long_name='sea water salinity';
    standard_name='sea_water_practical_salinity';
    units='1';
    var_qcName=[varname '_QC'];
    var_qc=SQ;
    var_uncertainty=press_uncertainty;
    var_accuracy=press_accuracy;
    var_precision=press_precision;
    var_resolution=press_resolution;
    var_cell_methods=press_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;    
    var_comment=['Practical PSAL Units for each nominal depth(s) of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end

varStr='P';
if (exist(varStr))
    var=P;
    varname='PRES';
    valid_min=0.0;
    valid_max=6000.00;
    long_name='sea_water_pressure';
    standard_name='sea_water_pressure';
    units='decibar';
    var_qcName=[varname '_QC'];
    var_qc=PQ;
    var_uncertainty=press_uncertainty;
    var_accuracy=press_accuracy;
    var_precision=press_precision;
    var_resolution=press_resolution;
    var_cell_methods=press_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;  
    var_axis='Z';
    var_positive='down';
    var_comment=['PRES (dbar) at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end

varStr='Oxm';    %for Seabird microcat with oxygen
if (exist(varStr))
    var=Oxm;
    varname='DOXM';
    valid_min=1.0;
    valid_max=10.00;
    long_name='moles_of_oxygen_per_unit_mass_in_sea_water';
    standard_name='moles_of_oxygen_per_unit_mass_in_sea_water';
    units='micromole/kg';
    var_qcName=[varname '_QC'];
    var_qc=OxmQ;
    var_uncertainty=doxy_uncertainty;
    var_accuracy=doxy_accuracy;
    var_precision=doxy_precision;
    var_resolution=doxy_resolution;
    var_cell_methods=doxy_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;  
    var_axis='Z';
    var_positive='down';
    var_comment=['Oxygen measured in ml/l converted to micromole/kg at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end

varStr='OxA';  % for Aanderaa
if (exist(varStr))
    var=Ox;
    varname='DOXM';
    valid_min=1.0;
    valid_max=10.00;
    long_name='moles_of_oxygen_per_unit_mass_in_sea_water';
    standard_name='moles_of_oxygen_per_unit_mass_in_sea_water';
    units='microMol';
    var_qcName=[varname '_QC'];
    var_qc=PQ;
    var_uncertainty=doxy_uncertainty;
    var_accuracy=doxy_accuracy;
    var_precision=doxy_precision;
    var_resolution=doxy_resolution;
    var_cell_methods=doxy_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;  
    var_axis='Z';
    var_positive='down';
    var_comment=['Oxygen (dbar) at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end

varStr='D';
if (exist(varStr))
    var=D;
    varname='DEPTH';
    valid_min=0.0;
    valid_max=6000.00;
    long_name='depth of instrument in seawater';
    standard_name='depth';
    units='decibar';
    var_qcName=[varname '_QC'];
    var_qc=DQ;
    var_uncertainty=press_uncertainty;
    var_accuracy=press_accuracy;
    var_precision=press_precision;
    var_resolution=press_resolution;
    var_cell_methods=press_cell_methods;
    var_Sensor_Vendor=mc_Sensor_Vendor;
    var_Sensor_part_no=mc_Sensor_part_no;  
    var_sensor_serial_number=mc_sensor_serial_number;
    var_sensor_depth=int2str(mc_Sensor_Depth);
    var_sensor_mount=mc_sensor_mount;
    var_sensor_orientation=mc_sensor_orientation;    
    var_axis='z';
    var_positive='down';
    var_comment=['DEPTH (dbar) at nominal depths of ' int2str(v) ' meter(s)'];
    
    microcat_var_v1_3;
    gdac_metadata_form3_v1_3;    
    gdac_metadata=strvcat(gdac_metadata,gdac_form_3);
    clear gdac_form_3;
end

gdac_form_3a_0a=[' '];
gdac_form_3a_0b=['3. OceanSites Paramenter and Sensor Information ' ];
gdac_form_3a_0c=[' '];
gdac_form_3a_0d=lsensor;
gdac_form_3a_0e=lsensor2;
gdac_form_3a_1=['Sensor Vendor: ' mc_Sensor_Vendor];
gdac_form_3a_2=['Sensor Sampling Period: '  mc_Sensor_Sampling_Period];
gdac_form_3a_3=['Sensor Sampling Frequency: ' mc_Sensor_Sampling_Frequency ];
gdac_form_3a_4=['Sensor Reporting Time: ' mc_Sensor_Reporting_Time];

gdac_metadata=strvcat(gdac_metadata,gdac_form_3a_0a,gdac_form_3a_0b,gdac_form_3a_0c,gdac_form_3a_0d,gdac_form_3a_0e,gdac_form_3a_1,gdac_form_3a_2,gdac_form_3a_3,gdac_form_3a_4);

netcdf.close(scope);

cd /noc/users/animate/animate_matlab

%gdac_mc_metadata;  now embedded in code above

