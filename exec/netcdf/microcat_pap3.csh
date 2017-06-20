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


nvar=7;
Pvar(nvar)=zeros;
v(1)=10;  
v(2)=25;  Pvar(2)=1;
v(3)=42;  Pvar(3)=1;
v(4)=112; 
v(5)=156; Pvar(5)=1;
v(6)=407; 
v(7)=1006;
deploy='3rd_deployment';
mooring=' PAP3';
lcmooring3='pap';
startdate='17-Nov-2003';
enddate='18-Jun-2004';
lat=49;
long=16.5;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where (mn >= 220)  ';
s6=' and (temp10 < 999) and (temp156 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

microcat_netcdf;

exit;
FIN

