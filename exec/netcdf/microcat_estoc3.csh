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

nvar=8;
Pvar(nvar)=zeros;
v(1)=7;  Pvar(1)=1;
v(2)=60;  Pvar(2)=1;
v(3)=90;  Pvar(3)=1;
v(4)=150; 
v(5)=240;
v(6)=400; Pvar(6)=1;
v(7)=650;
v(8)=945; 
deploy='3rd_deployment';
mooring=' ESTOC3';
lcmooring3='estoc';
spmooring=[' ' mooring];
startdate='01-Nov-2003';
enddate='';
lat=29.2;
long=15.8;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where  (temp7 < 999) and (temp240 < 999) order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5);

microcat_netcdf;

exit;
FIN

