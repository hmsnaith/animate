#!/bin/csh
cd /users/itg/animate/netcdf;
setup matlab
setenv DISPLAY hyperion:0
matlab -nodesktop -nosplash <<FIN

pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/matlab',path);
toolbox_area = '/nerc/packages/satprogs/matlab';
path(path, fullfile( toolbox_area, 'netcdf', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'nctype', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'ncutility', ''));
addpath /users/itg/animate/exec;
addpath /users/itg/animate/lib;

% NB 2253 was lost when telemetry buoy broke free.
nvar=11;
Pvar=zeros(1,nvar);


serial_no(1)=2253;	v(1)=10;  			skip(1)=47;
serial_no(2)=2262;	v(2)=37;  	Pvar(2)=1;	skip(2)=57;
serial_no(3)=2257;	v(3)=87;  			skip(3)=47;
serial_no(4)=2263;	v(4)=142; 	Pvar(4)=1;	skip(4)=58;
serial_no(5)=2256;	v(5)=221; 			skip(5)=48;
serial_no(6)=2252;	v(6)=302; 			skip(6)=47;	
serial_no(7)=2271;	v(7)=402;  	Pvar(7)=1;	skip(7)=57;
serial_no(8)=2255;	v(8)=552;			skip(8)=47;	
serial_no(9)=2264;	v(9)=702; 	Pvar(9)=1;	skip(9)=57;
serial_no(10)=2254;	v(10)=853;			skip(10)=47;
serial_no(11)=2265;	v(11)=1002; 	Pvar(11)=1;	skip(11)=57;
mooring=' CIS';
lcmooring3='cis';
startdate='21-Aug-2002';
enddate='25-Jun-2003';
enddate_num=datenum([enddate ' 23:15:00']);
lat=49;
long=16.5;
cd /users/itg/animate;
load temp;
TIME=Time(:,11);
clear hh mm ss
cd /users/itg/animate/netcdf/microcat;
microcat_netcdf_dm;

exit;
FIN

