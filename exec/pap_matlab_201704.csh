#!/bin/csh
# Script to run NRT processsing for PAP 201704 deployment
# Runs matlab script process_nrt to create graphs in webapps directory
#  from data held in animate database (run after pap_iridium_201704.pl)
# Ensures output graphs have 664 permissions set

# Set deployment name
set mooring = 'pap'
set deploy = '201704'
# Change to use $deploy!
set dep_dir = ${mooring}_2017_apr'

# Set web directory for pap website (webdir) and eurosites (webdir2)
set webdir = '/noc/itg/www/apps/${mooring}/' $deploy
set webdir2 = '/data/ncs/www/eurosites/${mooring}/' $deploy

# Date used to label log file
set date=`date +%y%m%d_%H%M`

# Run matlab script
alias matlab /nerc/packages/matlab/2015b/bin/matlab

cd /noc/users/animate/animate/matlab
matlab -nodesktop -nosplash -nodisplay -logfile /noc/users/animate/logs/${mooring}_matlab_${deploy}_$date.log <<FIN
disp('Opened matlab')
deploy = '$deploy';
webdir = '$webdir';
process_nrt;
disp('finished matlab')
quit;
FIN

echo "Closed matlab"

chmod 664 $webdir/*.png

# remove comment on copy when this deployment is live
#cp $webdir/*.png  $webdir2
#cp /noc/users/animate/animate_data/${mooring}/$dep_dir/monthly/*.csv /noc/itg/pubread/animate/animate_data/${mooring}/$dep_dir/monthly/
