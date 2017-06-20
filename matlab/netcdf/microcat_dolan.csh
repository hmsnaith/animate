#!/bin/csh
cd /users/itg/animate/netcdf/microcat;
setup matlab
setenv DISPLAY 139.166.244.161:0
matlab -nodesktop -nosplash <<FIN

pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/satmat/mysql',path);
toolbox_area = '/nerc/packages/satprogs/satmat/mysql';
path(path, fullfile( toolbox_area, 'netcdf', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'nctype', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'ncutility', ''));
addpath /users/itg/animate/exec;

nvar=1;
Pvar(nvar)=zeros;
v(1)=10;  Pvar(1)=0;
P(1)=10;
deploy='3rd_deployment';
mooring=' DOLAN';
lcmooring3='dolan';
startdate='13-Jun-2003';
enddate='';
lat=29.2;
long=15.9;

s1=['SELECT * FROM ' mooring '_mc'];
s2=[' left join ' mooring '_mc_qc on'];
s3=[' (' mooring '_mc.Date_Time = ' mooring '_mc_qc.Date_Time_qc) '];
s4=[' or ' mooring '_mc_qc.Date_Time_qc IS NULL'];
s5=' and (temp10 < 999)  order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5);

microcat_netcdf;

exit;
FIN
