#!/bin/csh
# output from pap_iridium.pl

# Set deployment name
set deploy = 'pap_2017_apr'
set dep_dir = '201704'

# Set web directory for pap website (web_dir) and eurosites (web_dir2)
set web_dir = '/noc/itg/www/apps/pap/' $deploy
set web_dir2 = '/data/ncs/www/eurosites/pap/' $deploy

# Date used to label log file
set date=`date +%y%m%d_%H%M`

# Run matlab script
alias matlab /nerc/packages/matlab/2015b/bin/matlab

cd /noc/users/animate/animate/matlab
matlab -nodesktop -nosplash -nodisplay -logfile /noc/users/animate/logs/pap_matlab_201704_$date.log <<FIN
disp('Opened matlab')
process_nrt;
disp('finished matlab')
quit;
FIN

echo "Closed matlab"

chmod 664 $web_dir/*.png

# remove comment on copy when this deployment is live
#cp $web_dir/*.png  $web_dir2
#cp $web_dir/*.png  /noc/itg/www/apps/pap/graphs/
#cp $web_dir2/*.png /data/ncs/www/eurosites/pap/
#cp /noc/users/animate/animate_data/pap/$dep_dir/monthly/*.csv /noc/itg/pubread/animate/animate_data/pap/$dep_dir/monthly/
