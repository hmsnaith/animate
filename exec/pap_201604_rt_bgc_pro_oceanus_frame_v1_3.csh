#!/bin/csh
# near real time data
cd /noc/users/animate/animate_matlab;
setup v2013a matlab

matlab -nodesktop -nosplash -display tethys:147 <<FIN

% input from mysql
pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/satmat/mysql',path);
cd /noc/users/animate/animate_matlab;
addpath /noc/users/animate/lib

ncVerNo=3;
mooring='PAP';
global mooringlc;
mooringlc='pap';
deploy='201507';
project='FixO3    ';
history_in='Near real-time processed quality controlled at DAC';
deploy_voy='RRD Discovery DY032';
comment_in='no comment';
recover_voy='';
pi_name='Richard Lampitt';
source_institution='NOC';
update_interval='daily';
institution_references=[' http://noc.ac.uk'];
data_area='North Atlantic Ocean';
mc_Sensor_Sampling_Frequency='Every 30 minutes';
mc_Sensor_Reporting_Time='No comment';
Sensor_Sampling_Frequency='Variable';
Sensor_Reporting_Time='Variable';
os_format_version='1.3';
mode='R';

QC_indicator=1; %ref table 2 code (subscript will be this +1) for variable with no <PARM>_QC
microcat_v1_3_params_fixo3;
qcProcLevel=ref_tab_3(2);


mc_lsensor='';
mc_lsensor2='';
%os_namer='PCO2_30m';
OS_name='PCO2';
os_partx='PCO2_30m';
cdout_os='/noc/itg/pubread/animate/oceansites/biogeochem/';
cdout=['/noc/users/animate/animate_data/pap/' deploy '/pro_o/'];
cdout1=['/noc/itg/pubread/animate/animate_data/pap/' deploy '/pro_o/'];
%in_dir=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/microcat/processed/'];  %??????????????????????
in_file1='';
in_file2='';

keel_mc=[0];   % MRP 20131206 
sensor_frame_mc=[1]; % number in sequence
nvar_sf=1;           % number of microcats in sensor frame
n_pro_o=1;           % number of pro_oceanus sensors
n_pro_o_std=3;      % for comments, number of points included in calulation of Standard deviation
bgc_v=[1];           % nominal depth of microcat on keel
% beacause reusing graph generation routine
db_table='PAP201507';
webdir='/noc/itg/www/apps/pap/pap_2015_jul';
comment_in=['Processing notes: The sensor is set up to gradually stabilise the readings. '...
' The standard deviation of the '...
'last' int2str(n_pro_o_std) 'readings is included as an indicator of convergence to a final reading. '...
'The time of reading is for the last reading. The sequence of readings having been made at one minute intervals.'];


nvar=1;
sample_period=30;   % for roc qc (minutes)
rt_sample_period_text='every 6 hours';   %platform_reporting_frequency
%
%Wvar 0, sensor has pressure, non zero is number of sensor to use to calculate pressure
% stype 1=MC, 2=MC + pressure, 3=TDlogger  4=MC with pump  5=MC with pump and pressure
%qc_var 0-do all qc   1=do not do roc   3=set to 3   4=set to 4 

mc_sensor_serial_no(1)=6904;	mc_v(1)=30;  	Wvar(1)=0; 		mc_stype(1)=5; 	qc_var(1)=-1;		
sensor_serial_str='34-200-45';
sensor_serial_no(1)=3420045;
sensor_type='Pro-Oceanus CO2-Pro';	


spmooring=[' ' mooring];
StartDate='2015-07-01 12:30:00';
EndDate='2025-01-01 00:00:00';
startdate=datestr(StartDate);
%startdate='15-jul-2014 09:45:00';
%enddate='03-Jul-2012 13:16:00';
x_lab='Date (2015)';
if exist('enddate')<1 
	enddate_num=now; 
	enddate=datestr(enddate_num,'dd-mmm-yyyy HH:MM:SS');
end
startdate_num=datenum(startdate);
long=-16.31896;
lat=49.02946;


moor_lat_min=48;
moor_lat_max=50;
moor_long_min=-16;
moor_long_max=-17;
M_legend=['Nom. 30m'];
P_legend=['Nom. 30m'];

clear moor_nr;
moor_nr=ones(1,nvar);

mooring_number=1;
mooring_no='1';
% letter=''; % for sensor frame
letter=''
table_ext='gas'
reading_repeat=3;

%%%%%%%%%%%%%% read msql

s1=['SELECT * FROM ' mooring deploy '_' table_ext ];
s7=[' WHERE ' mooring deploy '_' table_ext '.Date_Time  > "' StartDate '" order by Date_Time ASC'];
%s5=[' where  Date_Time > "' StartDate '"  order by Date_Time ASC'];
sqlstr=strcat(s1,s7);
mysql('open','mysql','animate','an1mate9','animate');
DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);

all_DateTime=zeros(rows,1);
all_PCO2_ppm=zeros(rows,n_pro_o);
all_PCO2_mu_atms=zeros(rows,n_pro_o);
%all_TDGP=zeros(rows,n_pro_o);
    
for  i = 1:rows;
 for j=1:n_pro_o
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
    all_DateTime(i,1)=datenum(ddd(1:19));

% for Pro O
    x=(getfield(DATA,{i,1},['pro_o' letter '_conc']));
    if (isempty(x)) 
	  all_PCO2_ppm(i,j) = NaN; 
    else 
	  all_PCO2_ppm(i,j) = x; 
    end;
    
%    x=(getfield(DATA,{i,1},['pro_o' letter '_tdgp']));
%    if (isempty(x))
%	  all_TDGP(i,j) = NaN; 
%    else 
%	  all_TDGP(i,j) = x; 
%    end;

    x=(getfield(DATA,{i,1},['pro_o' letter '_cell_temp']));
    if (isempty(x)) 
	  all_cell_temp(i,j) = NaN; 
    else 
	  all_cell_temp(i,j) = x; 
    end;

    x=(getfield(DATA,{i,1},['pro_o' letter '_gas_temp']));
    if (isempty(x)) 
	  all_gas_temp(i,j) = NaN; 
    else 
	  all_gas_temp(i,j) = x; 
    end;

    x=(getfield(DATA,{i,1},['pro_o' letter '_gas_humid']));
    if (isempty(x)) 
	  all_gas_humid(i,j) = NaN; 
    else 
	  all_gas_humid(i,j) = x; 
    end;

    x=(getfield(DATA,{i,1},['pro_o' letter '_gas_press']));
    if (isempty(x)) 
	  all_gas_press(i,j) = NaN; 
    else 
	  all_gas_press(i,j) = x; 
    end;
 end;  

end;

%DERIVED!!!
all_PCO2_mu_atms=all_PCO2_ppm.*(all_gas_press/1013.25);
%sp=size(all_pCO2);
%diff=all_pCO2(1:(sp(2)-1))-all_pCO2(2:sp(2));
all_time_diff=all_DateTime(1:(rows-1))-all_DateTime(2:rows);

startdate=datestr(all_DateTime(1,1),1);
%enddate=datestr(all_DateTime(rows,1),1);
%enddate_num=datestr(enddate,1);
disp 'end of read'
%%%%%%%%%%%%%% end of read
%microcat_graphs;   



kq=find(all_time_diff<-((5*60)/(24*60*60)));
%kq=kq-1;  % to point at final value of sampling
% construct means and stds based on only these times.

i=1;  % could be loop for 2 microcats
DateTime=all_DateTime(kq,1);
mc_depth=num2str(mc_v(i));
mc_time_range=16; % closest time nb pro oceanus is variable but mostly 6 hours, MCs should be every 30 minues, but some missing

TQ=ones(size(kq));
SQ=ones(size(kq));
PQ=ones(size(kq));
CQ=ones(size(kq));

disp 'size of kq '
sz_kq=size(kq)

for jj=1:sz_kq(1,1)
    PCO2_mu_atms_std(jj,1)=nanstd(all_PCO2_mu_atms(((kq(jj)-reading_repeat):kq(jj)),n_pro_o));
    if ((mc_stype(nvar)>9) &(mc_stype(nvar)<12)) 
    	    s1=['SELECT avg(sbo_temp) as avg_temp, avg(sbo_cond) as avg_cond, avg(sbo_press) as avg_press, max(sbo_temp_qc) as avg_temp_qc, max(sbo_cond_qc) as avg_cond_qc, max(sbo_press_qc) as avg_pres_qc FROM '  mooring deploy '_sbo_1 ' ];
            s2=[' WHERE ' mooring deploy '_sbo_1.Date_Time  <= timestampadd(minute,' num2str(mc_time_range) ',"' datestr(DateTime(jj),31) '") and '];
            s3=[' ' mooring deploy '_sbo_1.Date_Time  >= timestampadd(minute,' num2str(-1 * mc_time_range) ',"' datestr(DateTime(jj),31), '")'];
            s4=[' order by Date_Time ASC'];
            sqlstr=strcat(s1,s2,s3,s4);
     
    else
           s1=['SELECT avg(temp' mc_depth ') as avg_temp, avg(cond' mc_depth ') as avg_cond, avg(press' mc_depth ') as avg_press FROM '  mooring deploy '_data ' ];
           s2=[' WHERE ' mooring deploy '_data.Date_Time  <= timestampadd(minute,' num2str(mc_time_range) ',"' datestr(DateTime(jj),31) '") and '];
           s3=[' ' mooring deploy '_data.Date_Time  >= timestampadd(minute,' num2str(-1 * mc_time_range) ',"' datestr(DateTime(jj),31), '")'];
           s4=[' order by Date_Time ASC'];
           sqlstr=strcat(s1,s2,s3,s4); 
    
           ss1=['SELECT max(temp' mc_depth '_qc) as max_temp_qc, max(cond' mc_depth '_qc) as max_cond_qc, max(press' mc_depth '_qc) as max_press_qc FROM '  mooring deploy '_qc '];
           ss2=[' WHERE ' mooring deploy '_qc.Date_Time_qc  <= timestampadd(minute,' num2str(mc_time_range) ',"' datestr(DateTime(jj),31), '") and '];
           ss3=[' ' mooring deploy '_qc.Date_Time_qc  >= timestampadd(minute,' num2str(-1 * mc_time_range) ',"' datestr(DateTime(jj),31), '")'];
           ss4=[' order by Date_Time_qc ASC'];
           sqlstr_qc=strcat(ss1,ss2,ss3,ss4); 
	    mysql('open','mysql','animate','an1mate9','animate');
	    DATA_mc_qc=mysql(sqlstr_qc);    
	    mysql close;
	    [rows_mc_qc,cols_mc_qc]=size(DATA_mc_qc);
	    x=(getfield(DATA_mc_qc,{1,1},['max_temp_qc']));

	    if (isempty(x)) 
		  TQ(jj,i) = 0; 
	    else 
		  TQ(jj,i) = x; 
	    end;
	    x=(getfield(DATA_mc_qc,{1,1},['max_cond_qc']));
	    if (isempty(x)) 
		  CQ(jj,i) = 0; 
	    else 
		  CQ(jj,i) = x; 
	    end;
	    x=(getfield(DATA_mc_qc,{1,1},['max_press_qc']));
	    if (isempty(x)) 
		  PQ(jj,i) = 0; 
	    else 
		  PQ(jj,i) = x; 
	    end
    end
    mysql('open','mysql','animate','an1mate9','animate');
    DATA_mc=mysql(sqlstr);    
    mysql close;
    [rows_mc,cols_mc]=size(DATA_mc);

	    x=(getfield(DATA_mc,{1,1},['avg_temp']));
	    if (isempty(x)) 
		  T(jj,i) = NaN; 
	    else 
		  T(jj,i) = x; 
	    end;
	    x=(getfield(DATA_mc,{1,1},['avg_cond']));
	    if (isempty(x)) 
		  C(jj,i) = NaN; 
	    else 
		  C(jj,i) = x; 
	    end;
	    x=(getfield(DATA_mc,{1,1},['avg_press']));
	    if (isempty(x)) 
		  P(jj,i) = NaN; 
	    else 
		  P(jj,i) = x; 
	    end

    end


S(:,i)=salinity(P(:,i),T(:,i),C(:,i));

PCO2_mu_atms=all_PCO2_mu_atms(kq,n_pro_o);
PCO2_ppm=all_PCO2_ppm(kq,n_pro_o);
PCO2_cell_temp=all_cell_temp(kq,n_pro_o);
PCO2_gas_temp=all_gas_temp(kq,n_pro_o);
PCO2_gas_humid=all_gas_humid(kq,n_pro_o);
PCO2_gas_press=all_gas_press(kq,n_pro_o);

kq_sz=size(kq);
PCO2_mu_atmsQ=ones(kq_sz(1),n_pro_o);

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

if exist('v')<1 ; v=mc_v; end
%microcat_qc;     removed 20150708
%
clear kkk;
kkk=find((PCO2_mu_atmsQ==9)|isnan(PCO2_mu_atms));
PCO2_mu_atms(kkk)=99999.0;
co2_qc;            


%QC as at data acquisition for RT
quality_control_indicator='1';
quality_index='B';

Sensor_Depth=[int2str(bgc_v) 'm nominal'];
Sensor_part_no='';
bgc_serial_no='Not Known';     
Sensor_Vendor='Pro-Oceanus';
Sensor_Sampling_Period='';
Sensor_Sampling_Frequency='Variable';
Sensor_Reporting_Time='Variable';

pco2_uncertainty=999;
pco2_accuracy=1;
pco2_precision=0.01;
pco2_resolution=999;
pco2_cell_methods='Time:point DEPTH:point LATITUDE:point LONGITUDE:point';

pco2_ppm_uncertainty=999;
pco2_ppm_accuracy=1;
pco2_ppm_precision=0.01;
pco2_ppm_resolution=999;
pco2_ppm_cell_methods='Time:point DEPTH:point LATITUDE:point LONGITUDE:point';
pco2_ppm_comments='Output directly by Pro-Oceanus CO2-PRO in ppm';


PCO2_mu_atms_uncertainty=999;
PCO2_mu_atms_accuracy=1;
PCO2_mu_atms_precision=0.01;
PCO2_mu_atms_resolution=999;
PCO2_mu_atms_cell_methods='Time:point DEPTH:point LATITUDE:point LONGITUDE:point';
PCO2_mu_atms_comments='Calculated from output of Pro-Oceanus CO2-PRO in microPa';

%tdgp_uncertainty=999;
%tdgp_accuracy=2;
%tdgp_precision=1;
%tdgp_resolution=999;
%tdgp_cell_methods='Time:point DEPTH:point LATITUDE:point LONGITUDE:point';
%tdgp_comments='Output directly by Pro-Oceanus CO2-PRO, used in calculation of pCO2 in microAtmospheres';


os_name_type=[mode '_PCO2'];
bodc_name='PCO2XXXX';
bgc_type='PCO2';
units='microPa';
sensor_type='Pro-Oceanus CO2-PRO';
Sensor_Depth=bgc_v;
Sensor_part_no='CO2-PRO';
sensor_serial_number='34-201-45';
Sensor_Vendor='ProOceanus';
Sensor_Sampling_Period='variable';
Sensor_Sampling_Frequency='No comment';
Sensor_Reporting_Time='variable';

long_name='partial_pressure_of_carbon_dioxide_in_water';
ancillary_mc_var='TEMP_ANCILLARY TEMP_QC_ANCILLARY PSAL_ANCILLARY PSAL_QC_ANCILLARY PRES_ANCILLARY PRES_QC_ANCILLARY';
%os_desc=['File of ' long_name ' plus associated temperature, conductivity and pressure data collected at',spmooring,' mooring number ',mooring_no,' at ',num2str(lat),' Degrees N ',num2str(long),' Degrees W',' Deployment between ',startdate,' and ',enddate];
os_description=['File of ',long_name...
' data collected at',spmooring,' mooring number ',mooring_no...
' at ',num2str(lat),' Degrees N ',num2str(long),' Degrees W'...
' Deployment between ',startdate,' and ',enddate...
' The data are averaged over the telemetered readings. '... 
' PCO2 calculated as CO2 concentration(ppm)*Total Dissolved Gas Pressure(ppm)/1035.25'];

bodc_name='PCO2XXXX';
disp 'entering biogeochem_rt_v1_3'
biogeochem_rt_v1_3;
%clear PCO2_ppm PCO2_mu_atms TDGP ;

exit;
FIN

chmod 775 /noc/itg/pubread/animate/oceansites/biogeochem/OS_PAP-1_201507*.nc
chmod 775 /noc/itg/pubread/animate/oceansites/biogeochem/OS_PAP-1_201507*.txt
cp /noc/itg/pubread/animate/oceansites/biogeochem/OS_PAP-1_201507*.nc /noc/itg/pubread/animate/oceansites_update
cp /noc/itg/pubread/animate/oceansites/biogeochem/OS_PAP-1_201507*.txt /noc/itg/pubread/animate/oceansites_update
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201507*.nc
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201507*.txt

