#!/bin/csh
cd /users/itg/animate/netcdf;
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


nvar=7;
Pvar(nvar)=zeros;
v(1)=32; 	Pvar(1)=1;
v(2)=57;  
v(3)=70;  
v(4)=162;	Pvar(4)=1; 
v(5)=217; 	
v(6)=289; 
v(7)=367;	Pvar(7)=1;
mooring=' PAP2';
lcmooring3='pap';
deploy='2nd_deployment';
startdate='12-July-2003';
enddate='16-Nov-2003';
lat=49;
long=16.5;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=['(' mooring '_data.Date_Time = ' mooring '_qc.Date_Time_qc)'];
s4=[' or ' mooring '_qc.Date_Time_qc IS NULL'];
s5=' where (press367 > 300)  ';
s6=' and (temp32 < 999) and (temp367 < 999) order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

microcat_netcdf;

exit;
FIN

