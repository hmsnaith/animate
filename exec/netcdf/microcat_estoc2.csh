#!/bin/csh
cd /users/itg/animate/netcdf
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

nvar=8;
Pvar(nvar)=zeros;
v(1)=30;  Pvar(1)=1;
v(2)=60;  Pvar(2)=1;
v(3)=90;  Pvar(3)=1;
v(4)=150; 
v(5)=240;
v(6)=400; Pvar(6)=1;
v(7)=650;
v(8)=945; 
mooring=' ESTOC2';
lcmooring3='estoc';
startdate='12-Apr-2003';
enddate='29-Oct-2003';
lat=29.2;
long=15.8;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where (mn >= 232)  and (mn <= 1404) and';
s6=' ((buoyb > 40000) and (buoyb < 50000))';
s7=' and (temp30 < 999) and (temp240 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6,s7);

microcat_netcdf;

exit;
FIN

