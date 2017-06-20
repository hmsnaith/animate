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


nvar=9;
Pvar(nvar)=zeros;
v(1)=10;  
v(2)=25;  Pvar(2)=1;
v(3)=40;  Pvar(3)=1;
v(4)=60; 
v(5)=80; 
v(6)=150; Pvar(6)=1;
v(7)=400; 
v(8)=600; 
v(9)=800; Pvar(9)=1;
mooring=' PAP';
lcmooring3='pap';
startdate='07-Oct-2002';
enddate='10-Dec-2002';
lat=49;
long=16.5;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where (mn >= 65) and (mn < 447) and not ((mn=446)and(bid=0)) ';
s6=' and (temp10 < 999) and (temp150 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

microcat_netcdf;

exit;
FIN

