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

ncVerNo=3;
mooring='PAP';
long_site_name='PAP-SO (Porcupine Abyssal Plain - Sustained Observatory)';
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
%contributor_name='';
%contributor_role='';
%contributor_email='';


disp 'entering microcat_v1_3_params_fixo3_native'
QC_indicator=1; %ref table 2 code (subscript will be this +1) for variable with no <PARM>_QC

microcat_v1_3_params_fixo3;
qcProcLevel=ref_tab_3(2);

cdout_os='/noc/itg/pubread/animate/oceansites/microcat/';
cdout=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/microcat/'];
cdout1=['/noc/itg/pubread/animate/animate_data/' mooringlc '/' deploy '/microcat/'];
in_dir=['/noc/users/animate/animate_data/' mooringlc '/' deploy '/microcat/processed/'];
in_file1='';
in_file2='';

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
enddate_num=now;
startdate_num=datenum(startdate);
long=-16.27833;
lat=48.981667;

moor_lat_min=48;
moor_lat_max=50
moor_long_min=-16;
moor_long_max=-17
M_legend=['S/N 6915'];
P_legend=['S/N 6915'];

clear moor_nr;
moor_nr=ones(1,nvar);

mooring_number=1;
mooring_no='1';



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
microcat_graphs;   

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
microcat_rt_1_3;

exit;
FIN

chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.nc
chmod 775 /noc/itg/pubread/animate/oceansites/microcat/*.txt
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.nc /noc/itg/pubread/animate/oceansites_update
cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_201604*.txt /noc/itg/pubread/animate/oceansites_update
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.nc
chmod 744 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_201604*.txt
