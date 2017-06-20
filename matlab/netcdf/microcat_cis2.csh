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


nvar=11;
Pvar(nvar)=zeros;
v(1)=10;  
v(2)=55;  	Pvar(2)=1;
v(3)=85;  
v(4)=125; 	Pvar(4)=1;
v(5)=153; 
v(6)=173; 
v(7)=253;  	Pvar(7)=1;
v(8)=378;
v(9)=553; 	Pvar(9)=1;
v(10)=754;
v(11)=1004; 	Pvar(11)=1;
mooring=' CIS2';
lcmooring3='cis';
startdate='17-Aug-2003';
enddate='04-Sep-2003';
lat=49;
long=16.5;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where (mn >= 198)  ';
s6=' and (temp10 < 999) and (temp253 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

microcat_netcdf;

exit;
FIN

