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
v(2)=37;  	Pvar(2)=1;
v(3)=87;  
v(4)=142; 	Pvar(4)=1;
v(5)=221; 
v(6)=302; 
v(7)=402;  	Pvar(7)=1;
v(8)=552;
v(9)=702; 	Pvar(9)=1;
v(10)=853;
v(11)=1002; 	Pvar(11)=1;
deploy='1st_deployment';
mooring=' CIS';
lcmooring3='cis';
startdate='21-Aug-2002';
enddate='05-Feb-2003';
lat=49;
long=16.5;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s6=' and (temp10 < 999) and (temp402 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s6);

microcat_netcdf;

exit;
FIN

