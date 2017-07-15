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
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

DIR=cdout1;
cd(DIR);

dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');


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
