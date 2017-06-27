#!/bin/csh
# near real time data

cd /noc/users/animate/animate_matlab;
setup v2012a matlab

matlab -nodesktop -nosplash -display tethys:147 <<FIN

% input from mysql
pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/satmat/mysql',path);
cd /noc/users/animate/animate_matlab;
addpath /noc/users/animate/lib
addpath /noc/users/animate/lib/seawater

ncVerNo=3;
mooring='PAP';
global mooringlc;
mooringlc='pap';
deploy='201507';
project='FixO3    ';
history_in='Near real-time processed quality controlled at DAC';
deploy_voy='RSS Discovery DY032';
comment_in='no comment';
pi_name='Richard Lampitt';
source_institution='NOC';
update_interval='daily';
institution_references=[' http://noc.ac.uk'];
data_area='North Atlantic Ocean';
mc_Sensor_Sampling_Frequency='Every 30 minutes';
mc_Sensor_Reporting_Time='No comment';
mode='R';
os_format_version='1.3';
%license='';
%citation='';
%acknowledgement='';
contributor_name='Maureen Pagnani';
contributor_role='Editor';
contributor_email='M.Pagnani at bodc.ac.uk';
principal_investigator_email='Richard.Lampitt at noc.ac.uk';
principal_investigator_url='http://noc.ac.uk/people/rsl';

keywords_vocabulary='SeaDataNet Parameter Discovery Vocabulary';
keywords='WC_Temp, WC_Sal,http://vocab.nerc.ac.uk/collection/P02/current/TEMP/,http://vocab.nerc.ac.uk/collection/P02/current/PSAL/,http://vocab.nerc.ac.uk/collection/P02/current/DOXY/';


disp 'entering microcat_v1_3_params_fixo3_native'
QC_indicator=1; %ref table 2 code (subscript will be this +1) for variable with no <PARM>_QC

microcat_v1_3_params_fixo3;
qcProcLevel=ref_tab_3(2);

os_namer='CTDO'
cdout_os='/noc/itg/pubread/animate/oceansites/microcat/';
cdout=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/sbo/'];
cdout1=['/noc/itg/pubread/animate/animate_data/' mooringlc '/' deploy '/sbo/'];
in_dir=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/sbo/processed/'];
in_file1='';
in_file2='';

nvar=2;
sample_period=30;   % for roc qc (minutes)
decSamplePeriod=sample_period/(60*24);   % to detect missing timesteps

rt_sample_period_text='every 30 minutes';   % time between transmissions
% note data only sent 
%
%Wvar 0, sensor has pressure, non zero is number of sensor to use to calculate pressure
% stype 1=MC, 2=MC + pressure, 3=TDlogger  7=MC with pump  8=MC with pump and pressure 10 = SBE-37IMP-IDO 11 = SBE-37IMP-ODO 

serial_no(1)=13397;	v(1)=1;  	Wvar(1)=0; 		stype(1)=10; 	qc_var(1)=0;		skip(1)=0;
serial_no(2)=10535;	v(2)=30;  	Wvar(2)=0; 		stype(2)=11; 	qc_var(2)=0;		skip(2)=0;

ox_Sensor_Vendor='Seabird';
ox_Sensor_part_no='SBE-37IMP-IDO';
%ox_Sensor_Depth=;   % same as mc depth and serial no
%ox_sensor_serial_number=;

spmooring=[' ' mooring];
StartDate='2015-07-01 12:30:00';
EndDate='2025-01-01 00:00:00';
startdate='01-jul-2015 12:30:00';
x_lab='Date (2015)';
%enddate='';     % subsequent code puts in current
enddate_num=now;
startdate_num=datenum(startdate);
long=-16.31896;
lat=49.02946;

moor_lat_min=48;
moor_lat_max=50;
moor_long_min=-16;
moor_long_max=-17;
M_legend=['S/N  13397','S/N 10535'];
%P_legend=[['S/N' , serial_no(1)],['S/N ', serial_no(2)]];
P_legend=M_legend;
clear moor_nr;
moor_nr=ones(1,nvar);

mooring_number=1;
mooring_no='1';

s1=['SELECT * FROM PAP' deploy '_sbo_1'];
s2=[' where  Date_Time > "' StartDate '"  order by Date_Time DESC'];
sqlstr=strcat(s1,s2);
mysql('open','mysql','animate','an1mate9','animate');
DATA1=mysql(sqlstr);
mysql close;
date(1:19)=getfield(DATA1,{1,1},'Date_Time');
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
DateTimeTemp=datenum(ddd(1:19));   %last time
rowsCorr=round((DateTimeTemp-startdate_num)/decSamplePeriod)+1;

%[rows,cols]=size(DATA);

DateTime=zeros(rowsCorr,nvar);
T=zeros(rowsCorr,nvar);
P=zeros(rowsCorr,nvar);
C=zeros(rowsCorr,nvar);
S=zeros(rowsCorr,nvar);
St=zeros(rowsCorr,nvar);
Ox=zeros(rowsCorr,nvar);
TQ=ones(rowsCorr,nvar);
PQ=ones(rowsCorr,nvar);
CQ=ones(rowsCorr,nvar);
SQ=ones(rowsCorr,nvar);
StQ=ones(rowsCorr,nvar);
OxQ=ones(rowsCorr,nvar);


%  The 2 sensors are on the same time regime, and so can be added to an array. MRP 20140722
% however timestamps are missing from both data streams so that needs to be fixed MRP 20150806
%%%%%%%%%%%%%% read msql
for j=1:nvar;

s1=['SELECT * FROM PAP' deploy '_sbo_' int2str(j)];
s2=[' where  Date_Time > "' StartDate '"  order by Date_Time ASC'];
sqlstr=strcat(s1,s2);
mysql('open','mysql','animate','an1mate9','animate');
DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);
   
i=0;   %line counter to allow for additional data lines    
for  im = 1:rows;
    i=i+1;
    date(1:19)=getfield(DATA,{im,1},'Date_Time');
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
    DateTimeTemp=datenum(ddd(1:19));

    if (im>1)
      timeDiff=DateTimeTemp-DateTime(i-1,j);
      loop=round(timeDiff/decSamplePeriod);
      if loop > 1
        for iz=2:loop
            DateTime(i,j)=DateTime(i-1,j)+((iz-1)*decSamplePeriod);
            T(i,j)=NaN;
            P(i,j)=NaN;
            C(i,j)=NaN;
            S(i,j)=NaN;
            St(i,j)=NaN;
            Ox(i,j)=NaN;
            TQ(i,j)=9;
            CQ(i,j)=9;
            PQ(i,j)=9;
            SQ(i,j)=9;
            StQ(i,j)=9;
            OxQ(i,j)=9;
            i=i+1;
        end
      end
    else
        DateTime(1,j)=DateTimeTemp;   
    end
    DateTime(i,j)=DateTimeTemp;   

% for microcats	
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
          x=(getfield(DATA,{im,1},['sbo_temp']));
	  T(i,j) = x;
	  x =getfield(DATA,{im,1},['sbo_temp_qc']);
	    if (isempty(x)) 
			  TQ(i,j) = 1; 
	    else 
			  TQ(i,j) = x; 
	    end;

          x=(getfield(DATA,{im,1},['sbo_cond']));
	  C(i,j) = x; 
      	  x =getfield(DATA,{im,1},['sbo_cond_qc']);
	      if (isempty(x)) 
		    	CQ(i,j) = 1; 
	      else 
			CQ(i,j) = x; 
              end;
                
    

%pressure
%%%%%%%%%%%%%%%%%%%%%    
        clear depth_str;
    	  depth_str=int2str(v(j));    	  
	x=getfield(DATA,{im,1},['sbo_press']);
    	P(i,j) =  x; 
    x =getfield(DATA,{im,1},['sbo_press_qc']);
    if (isempty(x)) 
		PQ(i,j) = 1; 
    else 
		PQ(i,j) = x; 
    end;
 
 
         clear depth_str;
     	  depth_str=int2str(v(j));    	  
 	 x=getfield(DATA,{im,1},['sbo_ox']);
     	Ox(i,j) =  x; 
     x =getfield(DATA,{im,1},['sbo_ox_qc']);
     if (isempty(x)) 
 		OxQ(i,j) = 1; 
     else 
 		OxQ(i,j) = x; 
     end;

%111111111111111111111
 
 
 
	    if ((P(i,j) > 1800) | (P(i,j) < 1) | (PQ(i,j) > 1) )
	        P(i,j) = NaN;
	        PQ(i,j)=9;
	     end;
        if  (T(i,j) > 99) | (T(i,j) < 0.1 )
            TQ(i,j) = 9;
        end;
        if  (C(i,j) > 99) | (C(i,j) < 0.1 )
            CQ(i,j) = 9;
            C(i,j) = NaN;            
        end;
        if  (TQ(i,j) > 1)
            T(i,j) = NaN;
            C(i,j) = NaN;
        end;
        if  (OxQ(i,j) > 1)
            sbo_Ox(i,j) = NaN;
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

dens=sw_dens(S,T,P);
Oxm=Ox.*44.661.*dens./1000;  % convert ml/l to micromol/kg
OxmQ=OxQ;

%%%%%%%%%%%%%% end of read
microcat_graphs;   

microcat_ox_graphs;

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

clear kkk;
kkk=find((OxQ==9)|isnan(Ox));
Ox(kkk)=99999.0;


%QC as at data acquisition for RT %%%%%%%%%%%%%%%%%
%quality_control_indicator='unknown';
%quality_index='B';
%time_qc_indicator=ref_tab_2{2);
%pos_qc_indicator=ref_tab_2{2);

for j=1:nvar
	if (Wvar(j)>0) PQ(:,j)=8; end;
end

disp 'entering microcat_rt_1_3_native'
microcat_rt_1_3;

exit;
FIN

chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.nc
chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.txt
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.nc /noc/itg/pubread/animate/oceansites_update
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.txt /noc/itg/pubread/animate/oceansites_update
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.nc
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.txt
