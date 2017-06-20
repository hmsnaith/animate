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


nvar=9;
Pvar(nvar)=zeros;
v(1)=25;  Pvar(1)=1;	Wvar(1)=0;	serial_no(1,:)='N/K1';
v(2)=42;  Pvar(2)=1;	Wvar(2)=0;	serial_no(2,:)='N/K2';
v(3)=67;  		Wvar(3)=2;	serial_no(3,:)='N/K3';
v(4)=107; 		Wvar(4)=5;	serial_no(4,:)='N/K4';
v(5)=152; Pvar(5)=1;	Wvar(5)=-999;	serial_no(5,:)='N/K5';
v(6)=252; 		Wvar(6)=5;	serial_no(6,:)='N/K6';
v(7)=403;		Wvar(7)=8;	serial_no(7,:)='N/K7';
v(8)=603; Pvar(8)=1;	Wvar(8)=0;	serial_no(8,:)='N/K8';
v(9)=803;		Wvar(9)=8;	serial_no(9,:)='N/K9';
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
mooring='PAP4';
spmooring=[' ' mooring];
mooring_no='2';
mooringlc='pap';
startdate='22-Jun-2004';
enddate='';
lat=49;
long=16.5;
mode='R';

s1='SELECT * FROM PAP4_data';
s2=' left join PAP4_qc on';
s3=' ((PAP4_data.mn = PAP4_qc.mn_qc) and (PAP4_data.bid = PAP4_qc.bid_qc))';
s4=' or PAP4_qc.mn_qc IS NULL';
s5=' where ((mn > 250) or (mn = 250 and bid = 0))';
s6=' and (temp25 < 999) and (temp252 < 999) order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

microcat_netcdf;

exit;
FIN

