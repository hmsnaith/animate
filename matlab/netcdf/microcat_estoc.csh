#!/bin/csh
cd /users/itg/animate/netcdf/microcat
setup matlab
setenv DISPLAY hyperion:0
matlab -nodesktop -nosplash <<FIN

pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/matlab',path);
toolbox_area = '/nerc/packages/satprogs/matlab';
path(path, fullfile( toolbox_area, 'netcdf', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'nctype', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'ncutility', ''));
addpath /users/itg/animate/animate_matlab/
addpath /users/itg/animate/lib/


nvar=8;
Pvar(nvar)=zeros;
v(1)=10;  		Wvar(1)=2;	serial_no(1,:)='2261';
v(2)=20;  Pvar(2)=1;	Wvar(2)=0;	serial_no(2,:)='2269';
v(3)=50;  		Wvar(3)=2;	serial_no(3,:)='2260';
v(4)=100; Pvar(4)=1;	Wvar(4)=0;	serial_no(4,:)='2270';
v(5)=180; 		Wvar(5)=4;	serial_no(5,:)='N/K5';
v(6)=380; Pvar(6)=1;	Wvar(6)=0;	serial_no(6,:)='N/K6';
v(7)=650; 		Wvar(7)=6;	serial_no(7,:)='N/K7';
v(8)=920; Pvar(8)=1;	Wvar(8)=0;	serial_no(8,:)='N/K8';
sensor1='Seabird SBE 37-IM                     ';
sensor2='Seabird SBE 37-IM with pressure sensor';
for j=1:nvar;
 if (Wvar(j) > 0)
    sensor_type(j,:)=sensor1;
 else
    sensor_type(j,:)=sensor2;
 end 
end

deploy='1st_deployment';
mooring='ESTOC';
spmooring=[' ' mooring];
lcmooring3='estoc';
mooringlc='estoc';
startdate='16-Apr-2002';
enddate='21-May-2002';
lat=29.2;
long=15.8;
mode='R';       %R = real-time  D=delayed-mode

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=[' where (mn >= 382)  and Date_Time < "2002-05-21 17:00:00" and '];
s6=' ((buoyb > 40000) and (buoyb < 50000))';
s7=' and (temp10 < 999) and (temp180 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6,s7);

microcat_netcdf;

exit;
FIN

