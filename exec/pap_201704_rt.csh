#!/bin/csh
# Script to process and create graphs for PAP near real time data

# Set deployment name
set mooring = 'pap'
set deploy = '201704'
set dep_raw_dir = 'pap_2017_apr'

# Set web directory for pap webiste (web_dir) and oceansites (web_dir2)
set web_dir = '/noc/itg/www/apps/pap/' $dep_raw_dir
set web_dir2 = '/data/ncs/www/eurosites/pap/' $dep_raw_dir

# Date used to label log file
set date=`date +%y%m%d_%H%M`

# Run perl script to read data from ascdat files on remotetel
## Can we sensibly pass parameters to this!
#/noc/users/animate/exec/pap_iridium_201704.pl > /noc/users/animate/logs/pap_irid_thalassa_$date.log

# Setup matlab
alias matlab /nerc/packages/matlab/2015b/bin/matlab
cd /noc/users/animate/animate/matlab

# Run matlab script to generate OceanSITES and ascii data files from database
matlab -nodesktop -nosplash -nodisplay -logfile /noc/users/animate/logs/${mooring}_${deploy}_matlab_os_${date}.log <<FIN
mooring = 'pap';
deploy = '201704';
dsets = {'CTDO'};
for i=1:length(dsets)
  ds = dsets{i};
  oceansites_rt(mooring, deploy, ds);
end
quit;
FIN

echo "Closed matlab for oceanSITES files"

# Run matlab script to generate graphs from data in database
#matlab -nodesktop -nosplash -nodisplay -logfile /noc/users/animate/logs/$deploy_matlab_graphs_$date.log <<FIN
#disp('Opened matlab')
#process_nrt;
#disp('finished matlab')
#quit;
#FIN

#echo "Closed matlab for graphs"

#Ensure read permissions set
#chmod 664 /noc/itg/pubread/animate/oceansites/microcat/*.nc
#chmod 664 /noc/itg/pubread/animate/oceansites/microcat/*.txt
#cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_${deploy}*.nc /noc/itg/pubread/animate/oceansites_update
#cp /noc/itg/pubread/animate/oceansites/microcat/OS_PAP-1_${deploy}*.txt /noc/itg/pubread/animate/oceansites_update
chmod 664 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_${deploy}*.nc
chmod 664 /noc/itg/pubread/animate/oceansites_update/OS_PAP-1_${deploy}*.txt
#chmod 664 $web_dir/*.png
