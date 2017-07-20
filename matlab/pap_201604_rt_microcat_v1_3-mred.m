%A concatenated version of Maureen's code
% annotated with where now set
%
%% pap_201604_rt_microcat_v1_3.csh
%#!/bin/csh
%# near real time data

%cd /noc/users/animate/animate_matlab;
%setup v2012a matlab
%matlab -nodesktop -nosplash -display tethys:147 <<FIN

% input from mysql
%pcmd='lpr -s -r -h';
%path('/nerc/packages/satprogs/satmat/mysql',path);
%cd /noc/users/animate/animate_matlab;
%addpath /noc/users/animate/lib

ncVerNo=3; % meta.ncVerNo (oceansites_rt)
mooring='PAP'; % meta.os_site_code (setup_mooring)
long_site_name='PAP-SO (Porcupine Abyssal Plain - Sustained Observatory)'; % !not found elsewhere
global mooringlc; % just use lower(meta.os_site_code) when needed
mooringlc='pap';  % just use lower(meta.os_site_code) when needed
deploy='201507'; % !Input to oceansites_rt(mooring,deploy).m
project='FixO3    '; % meta.project (setup_mooring)
history_in='Near real-time processed and quality controlled at DAC'; % meta.history_in (oceansites_rt)
deploy_voy='RSS Discovery DY032'; % meta.deploy_voy - !used in make_microcat_sbo_netcdf_v1_3
comment_in='no comment'; % meta.comment_in (oceansites_rt)
pi_name='Richard Lampitt'; % meta.pi_name (setup_mooring)
source_institution='NOC'; % meta.source_institution (setup_mooring)
update_interval='daily';  % meta.update_interval (setup_mooring)
institution_references=[' http://noc.ac.uk'];  % meta.institution_references (setup_mooring)
data_area='North Atlantic Ocean';  % meta.data_area (setup_mooring)
mc_Sensor_Sampling_Frequency='Every 30 minutes';  % meta.mc_Sensor_Sampling_Frequency (def_pap_microcat) !where used
mc_Sensor_Reporting_Time='No comment';  % meta.mc_Sensor_Reporting_Time (def_pap_microcat) !where used?
mode='R';  % meta.mode (oceansites_rt)
os_format_version='1.3';  % meta.os_format_version (oceansites_rt)
%license='';
%citation='';
%acknowledgement='';
%contributor_name='';
%contributor_role='';
%contributor_email='';


disp 'entering microcat_v1_3_params_fixo3_native'
QC_indicator=1; %ref table 2 code (subscript will be this +1) for variable with no <PARM>_QC
% !Not set yet

%% microcat_v1_3_params_fixo3; % Mostly replaced by def_pap_microcat
% for FixO3
% should be in calling script
%20140514 cell methods removed LATITUDE LONGITUDE

[ref_tab_2, ref_tab_3] = oceansites_ref_tables; % Sets text for QC_Markers and QC_Proocedure_level


if   ~exist('institution_references','var') % Not needed
  institution_references='http://www.noc.soton.ac.uk';
end
author='Maureen Pagnani'; % meta.author (oceansites_rt)
publisher_name='Maureen Pagnani'; % meta.publisher_name (oceansites_rt)
publisher_email='m.pagnani at bodc.ac.uk'; % meta.publisher_email (oceansites_rt)
data_assembly_center='FixO3 DAC';  % meta.data_assembly_center (setup_mooring)
publisher_url='http://www.fixo3.eu'; % meta.publisher_url (setup_mooring)
contacts_email='noc-bodc@noc.soton.ac.uk' % meta.contacts_email (setup_mooring)

if ~exist('comment_in','var'), comment_in='no comment'; end; % Not needed

quality_control_indicator = ref_tab_2{QC_indicator+1}; 				%see Oceansites table 2.1
if ~exist('quality_index','var') quality_index='B'; end;    %see Oceansites manual global attibute depending on source B pre PI, A after PI

% currently only ????_QC ancillary_variables='';
references=' http://www.fixo3.eu, http://www.oceansites.org, http://www.coriolis.eu.org, http://www.eurosites.info';  % meta.references (setup_mooring)
update_interval='void'; % Already set to daily - should leave at that
time_uncertainty=0.000005;   % 2.3 mins per year  0.5 second a day ! Where used? 
if ~exist('qc_manual','var') % ! where used
	if (mode =='D')
	  qc_manual='Calibration of Physical Data Microcat, TD-Logger, ADCP, RCM by Johannes Karstensen, IFM-GEOMAR, January 2005';
  else
    %--Update to FixO3 reference?
	 qc_manual='MERSEA: In-situ real-time data quality control. Mersea-WP03-IFR-UMAN-001-02A, November 2005'; % ! set in oceansites_rt
	end
end
data_source='Mooring observation'; % meta.os_data_source (setup_mooring)
if ~exist('data_area','var') nc.area='North Atlantic Ocean';  % already set
else                    nc.area=data_area;
end
os_platform_category='Physical, Biogeochemical'; % meta.os_platform_category (setup_mooring)
os_data_type='Oceansites time-series'; % meta.os_data_type (oceansites_rt)
os_title='Oceanographic Data'; % meta.os_title (create_params) from mode, site_code, properties, data_area and num_depths
os_network='FixO3'; % meta.os_network (setup_mooring)
os_format_version='1.3'; % already set
os_conventions='CF-1.6'; % meta.os_conventions (oceansites_rt)
%, OceanSITES Manual 1.3';
mc_Sensor_Vendor='Seabird'; % meta.mc_Sensor_Vendor (def_pap_microcats)
mc_Sensor_Sampling_Period='instantaneous'; % !where used? meta.mc_Sensor_Sampling_Period (def_pap_microcats)
if (exist('mc_Sensor_Reporting_Time')<1) mc_Sensor_Reporting_Time='No comment'; end % Not needed - alreayd set
if (exist('rt_sample_period_text')<1) rt_sample_period_text='not applicable'; end % Not needed - alreayd set

keywords_vocabulary='SeaDataNet Parameter Discovery Vocabulary'; % meta.keywords_vocabulary (oceansites_rt)
keywords='WC_Temp, WC_Sal,http://vocab.nerc.ac.uk/collection/P02/current/TEMP/,http://vocab.nerc.ac.uk/collection/P02/current/PSAL/';% meta.keywprd (def_pap_microcats)


% 16Oct2009 QC required for GTS distribution ! - are we doing this?
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

% end of microcat_v1_3_params_fixo3;
%% Back to csh input
qcProcLevel=ref_tab_3(2);

% ! set this lot up in oceansitse_rt
cdout_os='/noc/itg/pubread/animate/oceansites/microcat/'; % oceansite netCDF for ftp pickup
cdout=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/microcat/']; % animate microcat data - local copy
cdout1=['/noc/itg/pubread/animate/animate_data/' mooringlc '/' deploy '/microcat/']; % animate microcat data - ftp copy
in_dir=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/microcat/processed/']; % animate microcat data - local copy
in_file1='';
in_file2='';

% ! this lot set in setup_mooring
nvar=1;
sample_period=15;   % for roc qc (minutes)
rt_sample_period_text='every 6 hours';   % time between transmissions
% note data only sent 
%
%Wvar 0, sensor has pressure, non zero is number of sensor to use to calculate pressure
% stype 1=MC, 2=MC + pressure, 3=TDlogger  7=MC with pump  8=MC with pump and pressure

serial_no(1)=6904;	v(1)=30;  	Wvar(1)=0; 		stype(1)=8; 	qc_var(1)=0;		skip(1)=0;
%serial_no(2)=6912;	v(2)=30;  	Wvar(2)=0; 		stype(2)=8; 	qc_var(2)=0;		skip(2)=0;


spmooring=[' ' mooring];
StartDate='2015-07-01 12:30:00';
EndDate='2025-01-01 00:00:00';
startdate='01-jul-2015 12:30:00';
x_lab='Date (2013)';
%enddate='';     % subsequent code puts in current
enddate_num=now; % only version of end date - as meta.end_date (setup_mooring)
startdate_num=datenum(startdate); % only version of start date - as meta.start_date (setup_mooring)
long=-16.27833; % meta.anchor_lon (setup_mooring)
lat=48.981667; % meta.anchor_lat (setup_mooring)

moor_lat_min=48;% meta.lat_min (setup_mooring)
moor_lat_max=50% meta.lat_max (setup_mooring)
moor_long_min=-16;% meta.lon_min (setup_mooring) ! check these are the right way round
moor_long_max=-17% meta.lon_max (setup_mooring)
M_legend=['S/N 6915']; % ! where used?
P_legend=['S/N 6915']; % ! where used?

clear moor_nr;
moor_nr=ones(1,nvar);

mooring_number=1;
mooring_no='1';


% ! From here - create new script read_animate_microcat
%%%%%%%%%%%%%% read msql

s1=['SELECT * FROM PAP' deploy '_data'];
s2=[' left join PAP' deploy '_qc on'];
s3=[' (PAP' deploy '_data.Date_Time = PAP' deploy '_qc.Date_Time_qc)'];
s4=[' or PAP' deploy '_qc.Date_Time_qc IS NULL'];
s5=[' where  Date_Time > "' StartDate '"  order by Date_Time ASC'];
sqlstr=strcat(s1,s2,s3,s4,s5);
mysql('open','mysql','animate','an1mate9','animate');
DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);

DateTime=zeros(rows,1);
T=zeros(rows,nvar);
P=zeros(rows,nvar);
C=zeros(rows,nvar);
S=zeros(rows,nvar);
St=zeros(rows,nvar);
TQ=ones(rows,nvar);
PQ=ones(rows,nvar);
CQ=ones(rows,nvar);
SQ=ones(rows,nvar);
StQ=ones(rows,nvar);

    
    
for  i = 1:rows;
    date(1:19)=getfield(DATA,{i,1},'Date_Time');
    ddd(1)=date(6);
    ddd(2)=date(7);
    ddd(3)=date(8);
    ddd(4)=date(9);
    ddd(5)=date(10);    
    ddd(6)=date(5);
    ddd(7)=date(1);
    ddd(8)=date(2);
    ddd(9)=date(3);
    ddd(10)=date(4);
    ddd(11:19)=date(11:19);
    DateTime(i,1)=datenum(ddd(1:19));


	
% for microcats	
    for j=1:nvar;
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
          x=(getfield(DATA,{i,1},['temp' depth_str]));
	  T(i,j) = x;
	  x =getfield(DATA,{i,1},['temp' depth_str '_qc']);
	    if (isempty(x)) 
			  TQ(i,j) = 1; 
	    else 
			  TQ(i,j) = x; 
	    end;

          x=(getfield(DATA,{i,1},['cond' depth_str]));
	  C(i,j) = x; 
      	  x =getfield(DATA,{i,1},['cond' depth_str '_qc']);
	      if (isempty(x)) 
		    	CQ(i,j) = 1; 
	      else 
			CQ(i,j) = x; 
              end;
                
    end;

%pressure
%%%%%%%%%%%%%%%%%%%%%    
for j=1:nvar;
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
	x=getfield(DATA,{i,1},['press' depth_str]);
    	P(i,j) =  x; 
    x =getfield(DATA,{i,1},['press' depth_str '_qc']);
    if (isempty(x)) 
		PQ(i,j) = 1; 
    else 
		PQ(i,j) = x; 
    end;
end  

%111111111111111111111
  
    
 %%%%%%%%%%% end of pressure 




    for j=1:nvar;
	    if ((P(i,j) > 1800) | (P(i,j) < 1) | (PQ(i,j) > 1) )
	        P(i,j) = NaN;
	        PQ(i,j)=9;
	     end;
        if (T(i,j) == 22.222) | (T(i,j) > 99) | (T(i,j) < 0.1 )
            TQ(i,j) = 9;
        end;
        if (C(i,j) == 22.222) | (C(i,j) > 99) | (C(i,j) < 0.1 )
            CQ(i,j) = 9;
            C(i,j) = NaN;            
        end;
        if (T(i,j) == 22.222) | (TQ(i,j) > 1)
            T(i,j) = NaN;
            C(i,j) = NaN;
        end;
        if (isnan(T(i,j)) | (CQ(i,j) > 1)) | (PQ(i,j) > 1)	     
            S(i,j)= NaN;
            St(i,j) = NaN;
            SQ(i,j)= 9;
            StQ(i,j) = 9;

        else
            Tsal=t90tot68(T(i,j));
            S(i,j)  =salinity(P(i,j), Tsal, C(i,j) );
  	    St(i,j) =sigmat(Tsal,S(i,j));
        end;
    end;
    

end;



startdate=datestr(DateTime(1,1),1);
enddate=datestr(DateTime(rows,1),1);

%%%%%%%%%%%%%% end of read
microcat_graphs;   % ! should we do this here? already in seperat graphing

% change Nans to Fill values

clear kkk;
kkk=find((TQ==9)|isnan(T));
T(kkk)=99999.0;

clear kkk;
kkk=find((CQ==9)|isnan(C));
C(kkk)=99999.0;

clear kkk;
kkk=find((PQ==9)|isnan(P));
P(kkk)=99999.0;

clear kkk;
kkk=find((SQ==9)|isnan(S));
S(kkk)=99999.0;

clear kkk;
kkk=find((StQ==9)|isnan(St));
St(kkk)=99999.0;

%QC as at data acquisition for RT %%%%%%%%%%%%%%%%%
%quality_control_indicator='unknown';
%quality_index='B';
%time_qc_indicator=ref_tab_2{2);
%pos_qc_indicator=ref_tab_2{2);

for j=1:nvar
	if (Wvar(j)>0) PQ(:,j)=8; end;
end

disp 'entering microcat_rt_1_3_native'
%% microcat_rt_1_3;
microcat_type; % oct 2010
sensor_type=mc_sensor_type;
[rows,cols]=size(T);
%	



%multiplier=3.29;
%for j=1:nvar;
% range by std does not work for temperature
%	iii=find(TQ(:,j)<2);
%	Tmn(j)=mean(T(iii,j));
%	Tstd(j)=std(T(iii,j));
%	kkk=find(abs(T(iii,j)-Tmn(j)) > (multiplier*Tstd(j)) ) ;
%	TQ(kkk,j)=3;
%        clear kkk;
%	clear iii;
%	iii=find(SQ(:,j)<2);
%	Smn(j)=mean(S(iii,j));
%	Sstd(j)=std(S(iii,j));
%	kkk=find(S(iii,j) < 35);
%	SQ(kkk,j)=3;
%	clear kkk;
%	clear iii;
%end;

startdate2=datestr(DateTime(1,1),29);
if isempty(enddate) 
	enddate2=date;
%	enddate='latest';  removed 20090615
else 	
	enddate2=datestr(DateTime(rows,1),29);
end;
startdate=startdate(1:11);
d1970=datenum('01-01-1970');
d1950=datenum('01-01-1950');
%DateTime_nc=(DateTime-d1970).*86400;
DateTime_nc=(DateTime-d1950);

DIR=cdout_os;

% create netcdf file
if ((stype(1) >= 10) & (stype(1) <= 11))  %has oxygen
      disp 'entering make_microcat_sbo_netcdf_v1_3'
   make_microcat_sbo_netcdf_v1_3;
%% make_microcat_sbo_netcdf_v1_3;
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

%% this section generates text for readme file later: - can be set from meta and / or g
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



%% end of make_microcat_sbo_netcdf_v1_3;
else
if os_format_version=='1.2'
      disp 'entering make_microcat_netcdf_v1_2'
   make_microcat_netcdf_v1_2;
elseif os_format_version=='1.3'
      disp 'entering make_microcat_netcdf_v1_3 native'
      make_microcat_netcdf_v1_3;
   else
      disp 'entering make_microcat_netcdf'
      make_microcat_netcdf;
end
end
DIR=cdout;
cd(DIR);
%% create space and comma delimited file
[yyyy,mon,day,hh,mm,ss]=datevec(DateTime);
clear kkk;
kkk=find(ss>=59.55);
DateTime(kkk,1)=DateTime(kkk,1)+(0.5/(24*60*60));
[yyyy,mon,day,hh,mm,ss]=datevec(DateTime(:,1));
clear kkk;
kkk=find(ss < 1);
ss(kkk)=0;


% Create matrix W of data:
% year month day hour min sec temp temp_qq conductivity cond_qc pressure
% press_qc salinity salinity_qc [oxygen oxygen_qc if we have them]
if (mode == 'R') & ((now-enddate_num)<30)
	enddate='latest';
else
	enddate=datestr(enddate_num,1);
end
if ((stype(1) >= 10) & (stype(1) <= 11))  %has oxygen
	W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ Ox OxQ] ;
else
	W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ] ;
end

%output data matrix W as an ascii and csv format file
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');

% Write text saved in readme_txt string to file
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

%writing same 3 files to different directory
DIR=cdout1;
cd(DIR);

dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

% Write the metadata form to txt file

[z1,z2]=size(OS_name);

dlmwrite(strcat(cdout_os,OS_name(1:z2-3),'_metadata_form.txt'),gdac_metadata,'');

% end of microcat_rt_1_3;
%% Back to csh input

exit;
FIN

chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.nc
chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.txt
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.nc /noc/itg/pubread/animate/oceansites_update
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.txt /noc/itg/pubread/animate/oceansites_update
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.nc
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.txt
