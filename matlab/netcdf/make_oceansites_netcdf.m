function make_oceansites_netcdf(ffn,g,d,v,dat,ncVerNo)
% make_oceansites_netcdf(ffn,g,d,v,dat)
Create OceanSITES netCDF file
%
% ffn: Filename - including path
% g: Global Attributes
% d: Dimensions
% v: Variable definitions and Attributes
% dat: Variable data arrays
% ncVerNo: (optional) netCDF version to use [default 3.5]

disp('in make_oceansites_netcdf');
%% Setup netCDF variables
NC_GLOBAL=netcdf.getConstant('NC_GLOBAL');

%% Variables
size_DateTime=size(DateTime,1)

%% Metadata setup - should be in an earlier function
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

%% Create netcdf file
[OS_dir, fn, ft] = fileparts(ffn);
OS_name = [fn ft];
if exist(OS_dir,'dir')
  cd(OS_dir);
else
  error(['OceanSITES directory ' OS_dir ' does not exist']);
end

% Set netcdf version to use
if ncVerNo >3
  ncVer='NETCDF4';
  netcdf_version='4.0';
else
  ncVer='CLASSIC_MODEL';
  netcdf_version='3.5';
end
  
if exist(OS_name,'file')
  disp(['Overwriting netcdf file ' OS_name ' in ' OS_dir]);
  ncMode = netcdf.getConstant(ncVer);
  ncMode = bitor(ncMode,netcdf.getConstant('NC_CLOBBER'));
  scope = netcdf.create(OS_name,ncMode);
else
  disp(['Creating netcdf file ' OS_name ' in ' OS_dir]);
  ncMode = netcdf.getConstant(ncVer);
  scope = netcdf.create(OS_name,ncMode);
end

%% Write Global Attributes
attNames = fieldnames(g);
for i=1:length(attNames)
  attName = attNames{i};
  netcdf.putAtt(scope,NC_GLOBAL,'summary',g.(attName));
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

