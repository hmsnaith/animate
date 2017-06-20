#!/bin/csh
cd /users/itg/animate/netcdf/microcat;
setup matlab
setenv DISPLAY 139.166.241.111:0
matlab -nodesktop -nosplash <<FIN

pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/matlab',path);
toolbox_area = '/nerc/packages/satprogs/matlab';
path(path, fullfile( toolbox_area, 'netcdf', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'nctype', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'ncutility', ''));
addpath /users/itg/animate/exec;

nvar=5;
Pvar(nvar)=zeros;
v(1)=25;  Pvar(1)=1;	Wvar(1)=0;	serial_no(1,:)='N/K1';
v(2)=48;  Pvar(2)=1;	Wvar(2)=0;	serial_no(2,:)='N/K2';
v(3)=68;  		Wvar(3)=2;	serial_no(3,:)='N/K3';
v(4)=98; 		Wvar(4)=2;	serial_no(4,:)='N/K4';
v(5)=148; Pvar(5)=1;	Wvar(5)=0;	serial_no(5,:)='N/K5';
sensor1='Seabird SBE 37-IM                     ';
sensor2='Seabird SBE 37-IM with pressure sensor';
for j=1:nvar;
 if (Wvar(j) > 0)
    sensor_type(j,:)=sensor1;
 else
    sensor_type(j,:)=sensor2;
 end 
end

deploy='4th_deployment';
mooring=' ESTOC4';
mooringlc='estoc';
spmooring=[' ' mooring];
startdate='23-Apr-2004';
enddate='';
lat=29.2;
long=15.8;
mode='R';       %R = real-time  D=delayed-mode

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where  (temp25 < 999)  order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5);

microcat_netcdf;

exit;
FIN

