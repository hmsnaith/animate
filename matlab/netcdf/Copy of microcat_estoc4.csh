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

nvar=5;
Pvar(nvar)=zeros;
v(1)=25;  Pvar(1)=1;
v(2)=48;  Pvar(2)=1;
v(3)=68;  
v(4)=98; 
v(5)=148; Pvar(5)=1;
deploy='4th_deployment';
mooring=' ESTOC4';
lcmooring3='estoc';
startdate='23-Apr-2004';
enddate='';
lat=29.2;
long=15.8;

s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where  (temp25 < 999)  order by Date_Time ASC';
sqlstr=strcat(s1,s2,s3,s4,s5);

microcat_netcdf;

exit;
FIN

