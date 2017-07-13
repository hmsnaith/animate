#!/usr/bin/perl
#!/nerc/packages/perl/bin/perl

# perl program to read a directory of filenames and create an email for each
# 17 Jul 2007 data problems so will change to accept microcat data at odd hours
# to use these must do more validation checks on sensor id and depth
# use send time if sensor time is day 1 2000.
# and make real use of gradient change
# Set the perl libraries to use
use DBI;
use CGI;
use File::stat;
use Time::Local;
use lib "/noc/users/animate/lib";
use lib "/noc/users/animate/lib/animate";
use quality_control_v3;

# Establish link to animate MySQL tables
$dbh = DBI->connect("DBI:mysql:animate:mysql","animate_admin","an1mate9876") || die "Can't open $database";

# Set server the accept "out of range" values - so NaNs, and incorrectly received data (stupid numbers) set to max of field rather than send error
$sql="SET sql_mode = ''";
$sel = $dbh->prepare($sql);
$sel->execute() || die "SQL mode setting: $sql failed";

# Depths of sbe now read from file
#@Depths_sbe=('30','31');
#@sbe_depth{9999}=$Depths_sbe[0];
#@sbe_depth{9030}=$Depths_sbe[1];
#$nv_sbe=2;

$nightly=1;   # attempting to run once a night to mop any missed data. but possibly nolonger required now running from concatenated files.

# Set the serial nunmbers of the various instruments

#$oc1_sn="DI70287";  #
#$oc2_sn="DI70287";  #
#$oc3_sn="DI70226";  #

$gps_range=-1;
$gps_range_test=200;  # mred 21Jul2009
$mooring="PAP201704";
$mooring_lc=lc($mooring);
$output_dir="/noc/users/animate/pap/".$mooring_lc;
$last_access_file="/noc/users/animate/pap/".$mooring_lc."/last_access_".$mooring_lc.".dat";
$transmitter="pap_dep2017";  # Name of deployment on remotetel disk
$file_dir0="/noc/ote/remotetel/ascdata/PAP/".$transmitter."/"; # Input file locations

$in_t_std=3;
$in_c_std=3;

$sbe_qc_Date_Time = 0;

# Set up email notification specification
$mailprog='/usr/lib/sendmail';
$from_address="Iridium_System\@noc.soton.ac.uk";
#$to_address="bodcnocs\@bodc.ac.uk,joc\@campbelloceandata.com";
$to_address="bodcnocs\@bodc.ac.uk";

# Save current date, time, year, month and day & print month
$nowunix = time();
@now=gmtime(time);
$nowdate=sprintf("%04d-%02d-%02d %02d:%02d:%02d", @now[5]+1900,@now[4]+1,@now[3],@now[2],@now[1],@now[0]);
$nowyyyy=@now[5]+1900;
$nowmon = @now[4] + 1;
$nowddd=sprintf("%03u",@now[7]+1);
print("\n---------------------------\n");
print("Running pap_iridium_201704.pl on $nowdate\n");
print "   MONTH  $nowmon $now\n";

# Open last read event file on stream 'DATE'
print("Reading last access file $last_access_file\n");
open (DATE, "< $last_access_file"); #!!!!!!!!!!!!!!!!file name also used in write at end of run !!
# First line of file is date processing last run
$last_run=<DATE>;
$loop_time=$last_run;
$unix_last_run=$last_run;

# Print out info on last run - save year and day
@tm=gmtime($last_run);
$yyyy=@tm[5]+1900;
$ddd=sprintf("%03u",@tm[7]+1);
print " Last Run $last_run ----";
printf(" %04d-%02d-%02d %02d:%02d:%02d\n", @tm[5]+1900, @tm[4]+1, @tm[3], @tm[2], @tm[1], @tm[0] );

# Read next line of input file - should be # of sbe variables; read record for each
$input=<DATE>;
chomp($input);
($vtype, $nv)=split(/ /,$input,2);
print("Last access file var 1: $vtype $nv \n");
if ($vtype == "sbe") {
  $nvar = $nv;
  $j=0;
  while($j<$nv) {
    $in=<DATE>;
    chomp($in);
    ($Depths_sbe[$j],$sn_sbe[$j],$st_sec_sbe[$j])=split(/ /,$in);
    print("$j :: $in :: Serial no $sn_sbe[$j] Depth $Depths_sbe[$j] Start Sec $st_sec_sbe[$j]\n");
    $j++;
  }
}
# Read next line of input file - should be # of sbo variables; read record for each
$input=<DATE>;
chomp($input);
($vtype, $nv)=split(/ /,$input,2);
print("Last access file var 2: $vtype $nv \n");
if ($vtype == "sbo") {
  $nv_sbo = $nv;
  $j=0;
  while($j<$nv) {
    $in=<DATE>;
    chomp($in);
    ($Depths_sbo[$j],$sn_sbo[$j],$st_sec_sbo[$j])=split(/ /,$in);
    print("$j :: $in :: Serial no $sn_sbo[$j] Depth $Depths_sbo[$j] Start Sec $st_sec_sbo[$j]\n");
    $j++;
  }
}
# Read next line of input file - should be # of fet variables; read record for each
$input=<DATE>;
chomp($input);
($vtype, $nv)=split(/ /,$input,2);
print("Last access file var 3: $vtype $nv \n");
if ($vtype == "fet") {
  $nv_fet = $nv;
  $j=0;
  while($j<$nv) {
    $in=<DATE>;
    chomp($in);
    ($Depths_fet[$j],$sn_fet[$j],$st_sec_fet[$j])=split(/ /,$in);
    print("$j :: $in :: Serial no $sn_fet[$j] Depth $Depths_fet[$j] Start Sec $st_sec_fet[$j]\n");
    $j++;
  }
}

close(DATE);

# Save current date, time, year, month and day & print month
#$nowunix = time();
#@now=gmtime(time);
#$nowdate=sprintf("%04d-%02d-%02d %02d:%02d:%02d", @now[5]+1900,@now[4]+1,@now[3],@now[2],@now[1],@now[0]);
#$nowyyyy=@now[5]+1900;
#$nowmon = @now[4] + 1;
#print "MONTH  $nowmon $now\n";
#$nowddd=sprintf("%03u",@now[7]+1);

# Do one loop / day for daily files
$no_loops=int( ($nowunix-$last_run) / 86400);
# If we are running nightly from concatenated files, set to a single loop
if ($nightly>0) {
# $loop_time=$loop_time-86400;  removed to stop double run when running from concat
  $no_loops=1;
}

print("Reading from root directory $file_dir0\n");

print(" TIMES $yyyy:$ddd :: $nowyyyy:$nowddd :: \n");


# while (($yyyy < $nowyyyy) or (($yyyy == $nowyyyy) &($ddd <= $nowddd ))) {
# For daily files - start with directory for last date read
if ($nightly <1) {
  $file_dir=$file_dir0.$yyyy."/Day".$ddd;
# For concatenated files, just use concat directory already set
} else {
  $file_dir=$file_dir0."concat/";
}
print("Reading files in $file_dir\n");

# if the search directory exists
if (opendir(DIRHANDLE, $file_dir)) {

# Get a file listing and loop over all files in the directory
  while ( defined($filename = readdir(DIRHANDLE) ) ) {
    # Find time file last updated - only process for catenated files, or if updated since last read
    $inode = stat("$file_dir/$filename");
    $mtime = $inode->mtime;
    ($fn,$ext)=split(/\./,$filename,2);
    $ext = lc($ext);
    $fn_len=length($fn);
    if ($fn_len<11) {
      $process=0;
    } elsif ($fn_len==11 and ($ext eq "fet" or $ext eq "sbe" or $ext eq "sbo")) {
      print("Not processing merged $ext file $filename\n");
      $process=0;
    } elsif (substr($filename,0,11) eq "PAP_Apr2017") {
      $process=1;
    }
    # if ((($mtime > $last_run ) or ($nightly>0)) and  ((substr($filename,0,1) ne ".") and (substr($filename,4,8) ne "June2014_test") and (substr($filename,4,8) ne "Apr_2013")))
    if ((($mtime > $last_run ) or ($nightly>0)) and  $process==1) {
    # In 2017 deployment, we have individual and combined sbe, sbo and fet files
      # Print information on filetype and last modified time

      @tm=gmtime($mtime);
      print "Reading file: $filename  File extension: $ext Last Update: $mtime - ";
      printf("%04d-%02d-%02d %02d:%02d:%02d\n", @tm[5]+1900,@tm[4]+1,@tm[3],@tm[2],@tm[1],@tm[0]);

      # Open data file
      $file_contents="";
      open(DATA, "$file_dir/$filename");

      # Read data and cut into words
      while (<DATA>) {
        $file_contents.=$_;
        # If we have numeric content
        if( /^[0-9]/ ) {
          # print "DATA0 $_ \n";
          chop($record=$_);

#########################################################
#         Add filename to email message to send
# &data_email($from_address,$to_address,$record,$filename);
#########################################################
#         Now file type specific processing
###########################################################
# hub/frame pitch and roll, and accelerometer data
          if ($ext eq "att") {
            ($message_year,$message_time,$seconds,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$max_g_X,$min_g_X,$ave_g_X,$max_g_Y,$min_g_Y,$ave_g_Y,$max_g_Z,$min_g_Z,$ave_g_Z,$time_diff)=split(/\s+/,$record,22);
            # print ("ATT0  $message_time,$seconds,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$max_g_X,$min_g_X,$ave_g_X,$max_g_Y,$min_g_Y,$ave_g_Y,$max_g_Z,$min_g_Z,$ave_g_Z,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "ATT2 $rec_date_time \n";

            # Search for existing records in the database for this time
            $sqlsel="SELECT *  FROM ".$mooring."_att WHERE Date_Time = '".$rec_date_time."'";
            #print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute() || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            # Unless we already have this record - add new record
            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_att SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert: $sql failed";
            }

            # Update table values
            $sqlupd="UPDATE ".$mooring."_att SET  seconds='".$seconds."', ";
            $sqlupd.="max_pitch='".$max_pitch."',";
            $sqlupd.="min_pitch='".$min_pitch."',";
            $sqlupd.="ave_pitch='".$ave_pitch."',";
            $sqlupd.="max_roll='".$max_roll."',";
            $sqlupd.="min_roll='".$min_roll."',";
            $sqlupd.="ave_roll='".$ave_roll."',";
            $sqlupd.="max_mag_heading='".$max_mag_heading."',";
            $sqlupd.="min_mag_heading='".$min_mag_heading."',";
            $sqlupd.="ave_mag_heading='".$ave_mag_heading."',";
            $sqlupd.="max_g_X='".$max_g_X."',";
            $sqlupd.="min_g_X='".$min_g_X."',";
            $sqlupd.="ave_g_X='".$ave_g_X."',";
            $sqlupd.="max_g_Y='".$max_g_Y."',";
            $sqlupd.="min_g_Y='".$min_g_Y."',";
            $sqlupd.="ave_g_Y='".$ave_g_Y."',";
            $sqlupd.="max_g_Z='".$max_g_Z."',";
            $sqlupd.="min_g_Z='".$min_g_Z."',";
            $sqlupd.="ave_g_Z='".$ave_g_Z."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("ATTsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
###########################################################
# Buoy pitch and roll, and accelerometer data
          elsif ($ext eq "btt") {
            ($message_year,$message_time,$seconds,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$max_g_X,$min_g_X,$ave_g_X,$max_g_Y,$min_g_Y,$ave_g_Y,$max_g_Z,$min_g_Z,$ave_g_Z,$time_diff)=split(/\s+/,$record,22);
            # print ("BTT0  $message_time,$seconds,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$max_g_X,$min_g_X,$ave_g_X,$max_g_Y,$min_g_Y,$ave_g_Y,$max_g_Z,$min_g_Z,$ave_g_Z,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "BTT2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_btt WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_btt SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_btt SET  seconds='".$seconds."', ";
            $sqlupd.="max_pitch='".$max_pitch."',";
            $sqlupd.="min_pitch='".$min_pitch."',";
            $sqlupd.="ave_pitch='".$ave_pitch."',";
            $sqlupd.="max_roll='".$max_roll."',";
            $sqlupd.="min_roll='".$min_roll."',";
            $sqlupd.="ave_roll='".$ave_roll."',";
            $sqlupd.="max_mag_heading='".$max_mag_heading."',";
            $sqlupd.="min_mag_heading='".$min_mag_heading."',";
            $sqlupd.="ave_mag_heading='".$ave_mag_heading."',";
            $sqlupd.="max_g_X='".$max_g_X."',";
            $sqlupd.="min_g_X='".$min_g_X."',";
            $sqlupd.="ave_g_X='".$ave_g_X."',";
            $sqlupd.="max_g_Y='".$max_g_Y."',";
            $sqlupd.="min_g_Y='".$min_g_Y."',";
            $sqlupd.="ave_g_Y='".$ave_g_Y."',";
            $sqlupd.="max_g_Z='".$max_g_Z."',";
            $sqlupd.="min_g_Z='".$min_g_Z."',";
            $sqlupd.="ave_g_Z='".$ave_g_Z."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("BTTsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
###########################################################
#ProOceanus CO2-Pro sensor
          elsif ($ext eq "co2") {
            ($message_year,$message_time,$pro_o_K_seconds,$pro_o_K_conc,$pro_o_K_AZPC,$pro_o_K_raw_co2,$pro_o_K_cell_temp,$pro_o_K_gas_temp,$pro_o_K_gas_humid,$pro_o_K_gas_press,$time_diff)=split(/\s+/,$record,11);
            # print ("CO20  $message_year,$message_time,$pro_o_K_seconds,$pro_o_K_conc,$pro_o_K_AZPC,$pro_o_K_raw_co2,$pro_o_K_cell_temp,$pro_o_K_gas_temp,$pro_o_K_gas_humid,$pro_o_K_gas_press,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "CO22 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_co2 WHERE Date_Time = '".$rec_date_time."'";

            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_co2 SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_co2 SET  pro_o_K_seconds='".$pro_o_K_seconds."', ";
            $sqlupd.="pro_o_K_conc='".$pro_o_K_conc."',";
            # $sqlupd.="pro_o_K_tdgp='".$pro_o_K_tdgp."',";
            $sqlupd.="pro_o_K_AZPC='".$pro_o_K_AZPC."',";
            $sqlupd.="pro_o_K_raw_co2='".$pro_o_K_raw_co2."',";
            $sqlupd.="pro_o_K_cell_temp='".$pro_o_K_cell_temp."',";
            $sqlupd.="pro_o_K_gas_temp='".$pro_o_K_gas_temp."',";
            $sqlupd.="pro_o_K_gas_humid='".$pro_o_K_gas_humid."',";
            $sqlupd.="pro_o_K_gas_press='".$pro_o_K_gas_press."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("co2sql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
###########################################################
# FET - Satlantic SeaFET pH sensor
          elsif ($ext eq "fet" and $fn_len>11) {
            ($message_year,$message_time,$sensor_year,$sensor_time, $SeaFET_serial_no,$FET_INT_pH,$FET_EXT_pH,$FET_temp,$FET_INT_v,$FET_EXT_v,$therm_v,$supply_v,$supply_a,$FET_hum,$int_v,$int_isolated_v,$time_diff)=split(/\s+/,$record,17);
            # print ("FET0 $record\n $message_year $message_time :$SeaFET_serial_no: $FET_INT_pH \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            if ($int_isolated_v == "NaN") { $int_isolated_v = 999.999; }
            if ($supply_v == "NaN") { $supply_v = 999.999; }
            if ($therm_v >= 1000) { $therm_v = 9999.999999; }
            # $time_diff=($message_time-$sensor_time)*86400; # 201304 OK in incoming data

            #find if serial no is known
            $j=0;
            $nom_depth=0;
            while($j < $nv_fet) {
              if ($sn_fet[$j] == $SeaFET_serial_no) {
                $nom_depth=$Depths_fet[$j];   # relates to names in dbase
                $st_sec_offset=$st_sec_fet[$j];
                $sub=$j+1;
                $j=$nv_fet;
              } else {
                $j++;
              }
            }
            $db_ext=$ext."_$sub";
            # print "FET1 $SeaFET_serial_no :: $nom_depth :: $st_sec_offset\n";
            # print "FET2 $rec_date_time $sensor_rec_date_time $time_diff\n";

            $sqlsel="SELECT *  FROM ".$mooring."_".$db_ext." WHERE Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_".$db_ext." SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_".$db_ext." SET FET_INT_pH='".$FET_INT_pH."',";
            $sqlupd.="FET_EXT_pH='".$FET_EXT_pH."',";
            $sqlupd.="FET_temp='".$FET_temp."',";
            $sqlupd.="FET_INT_v='".$FET_INT_v."',";
            $sqlupd.="FET_EXT_v='".$FET_EXT_v."',";
            $sqlupd.="therm_v='".$therm_v."',";
            $sqlupd.="supply_v='".$supply_v."',";
            $sqlupd.="supply_amp='".$supply_a."',";
            $sqlupd.="FET_hum='".$FET_hum."',";
            $sqlupd.="int_v='".$int_v."',";
            $sqlupd.="int_isolated_v='".$int_isolated_v."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print ("FETsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
          elsif ($ext eq "fet") {
            print("Not processing merged fet file\n");
          }
###########################################################
# FET - Satlantic SeaFET pH sensor corrected files
          elsif (($ext eq "fetcorr") or ($ext eq "fet corr") or ($ext eq "fet_corr")) {
            ($message_year,$message_time,$sensor_year,$sensor_time, $SeaFET_serial_no,$FET_INT_pH,$FET_EXT_pH,$FET_temp,$FET_INT_v,$FET_EXT_v,$therm_v,$supply_v,$supply_a,$FET_hum,$int_v,$int_isolated_v,$time_diff,$new1,$new2,$new3,$new4)=split(/\s+/,$record,21);
            # print ("FET0 $record\n $message_year $message_time :$SeaFET_serial_no: $FET_INT_pH \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # 201304 OK in incoming data                $time_diff=($message_time-$sensor_time)*86400;

            #find if serial no is known
            $j=0;
            $nom_depth=0;
            $sub=0;
            while($j < $nv_fet) {
            if ($sn_fet[$j] == $SeaFET_serial_no) {
                $nom_depth=$Depths_fet[$j];   # relates to names in dbase
                $st_sec_offset=$st_sec_fet[$j];
                $sub=$j+1;
                $j=$nv_fet;
              } else {
                $j++;
              }
            }
            # print "FET1 $SeaFET_serial_no :: $nom_depth :: $st_sec_offset\n";

            $db_ext=$ext."_$sub";
            # print "FETCORR db $db_ext\n";
            # print "FET2 $rec_date_time $sensor_rec_date_time $time_diff\n";

            $sqlsel="SELECT *  FROM ".$mooring."_".$db_ext." WHERE Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_".$db_ext." SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_".$db_ext." SET FET_INT_pH='".$FET_INT_pH."',";
            $sqlupd.="FET_EXT_pH='".$FET_EXT_pH."',";
            $sqlupd.="FET_temp='".$FET_temp."',";
            $sqlupd.="FET_INT_v='".$FET_INT_v."',";
            $sqlupd.="FET_EXT_v='".$FET_EXT_v."',";
            $sqlupd.="therm_v='".$therm_v."',";
            $sqlupd.="supply_v='".$supply_v."',";
            $sqlupd.="supply_amp='".$supply_a."',";
            $sqlupd.="FET_hum='".$FET_hum."',";
            $sqlupd.="int_v='".$int_v."',";
            $sqlupd.="int_isolated_v='".$int_isolated_v."',";
            $sqlupd.="TforCorr='".$new1."',";
            $sqlupd.="SforCorr='".$new2."',";
            $sqlupd.="FET_INT_corr='".$new3."',";
            $sqlupd.="FET_EXT_corr='".$new4."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print ("FETsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
###########################################################
#Pro-Oceanus Logging CO2-Pro
          elsif ($ext eq "gas") {
            ($message_year,$message_time,$pro_o_conc, $pro_o_AZPC,$pro_o_raw_co2,$pro_o_cell_temp,$pro_o_gas_temp,$pro_o_gas_humid,$pro_o_gas_press, $xx, $yy, $time_diff)=split(/\s+/,$record,12);
            # print ("GAS0 $record\n $message_year $message_time :: $pro_o_conc \n");
            # find time from hub
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "GAS2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_gas WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();
            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_gas SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_gas SET  pro_o_conc='".$pro_o_conc."',";
            $sqlupd.="pro_o_AZPC='".$pro_o_AZPC."',";
            $sqlupd.="pro_o_raw_co2='".$pro_o_raw_co2."',";
            $sqlupd.="pro_o_cell_temp='".$pro_o_cell_temp."',";
            $sqlupd.="pro_o_gas_temp='".$pro_o_gas_temp."',";
            $sqlupd.="pro_o_gas_humid='".$pro_o_gas_humid."',";
            $sqlupd.="pro_o_gas_press='".$pro_o_gas_press."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("GASsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#############################################################
# Telemetry GPS
          elsif ($ext eq "gps") {
            ($message_year,$message_time,$latitude, $longitude,$distance,$bearing,$jon3)=split(/\s+/,$record,7);
            # print ("GPS0 $distance $record\n $message_year $message_time :: $latitude, $longitude \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "GPS2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_gps WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_gps SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_gps SET  Latitude='".$latitude."', ";
            $sqlupd.="Longitude='".$longitude."',";
            $sqlupd.="distance='".$distance."',";
            $sqlupd.="bearing='".$bearing."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("GPS sql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
##########################################################
# Pro-Oceanus Gas Tension sensor
          elsif ($ext eq "gtd") {
            ($message_year,$message_time,$tdgp,$time_diff)=split(/\s+/,$record,4);
            # print ("GTD0 $record\n $message_year $message_time :: $tdgp_n \n");

            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "GTD2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_gtd WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_gtd SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
            $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_gtd SET tdgp='".$tdgp."', ";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("GTDsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
############################################
# hub monitors
          elsif ($ext eq "hub") {
            ($message_year,$message_time,$diff_hub_gps,$space,$cmp,$acc,$co2,$gtd,$sea,$nas,$ocr1,$ocr2,$ocr3,$wet,$isus,$hub_volt,$hub_hum,$hub_temp,$time_diff)=split(/\s+/,$record,19);
            # print ("HUB0  $message_time,$diff_hub_gps,$space,$cmp,$acc,$co2,$gtd,$sea,$nas,$ocr1,$ocr2,$ocr3,$wet,$isus,$hub_volt,$hub_hum,$hub_temp,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "HUB2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_hub WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_hub SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_hub SET  diff_hub_gps='".$diff_hub_gps."', ";
            $sqlupd.="space='".$space."',";
            $sqlupd.="cmp='".$cmp."',";
            $sqlupd.="acc='".$acc."',";
            $sqlupd.="co2='".$co2."',";
            $sqlupd.="gtd='".$gtd."',";
            $sqlupd.="sea='".$sea."',";
            $sqlupd.="nas='".$nas."',";
            $sqlupd.="ocr1='".$ocr1."',";
            $sqlupd.="ocr2='".$ocr2."',";
            $sqlupd.="ocr3='".$ocr3."',";
            $sqlupd.="wet='".$wet."',";
            $sqlupd.="isus='".$isus."',";
            $sqlupd.="hub_volt='".$hub_volt."',";
            $sqlupd.="hub_hum='".$hub_hum."',";
            $sqlupd.="hub_temp='".$hub_temp."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("HUBsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#############################################################
# Telemetry Iridium
          elsif ($ext eq "ird") {
            ($message_year,$message_time,$seconds_on,$wait,$bytes,$attempt,$status,$time_diff)=split(/\s+/,$record,8);
            # print ("IRD0   $seconds_on,$wait,$bytes,$attempt,$status,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "IRD2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_ird WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_ird SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_ird SET  seconds_on='".$seconds_on."', ";
            $sqlupd.="wait='".$wait."',";
            $sqlupd.="bytes='".$bytes."',";
            $sqlupd.="attempt='".$attempt."',";
            $sqlupd.="status='".$status."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("IRDsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#############################################################
# Satlantic OCR-507 ICSW irradiance
          elsif (($ext eq "oc1") or ($ext eq "oc2") or ($ext eq "oc3")) {
            ($message_year,$message_time,$seconds, $rec_type, $channel_1, $channel_2, $channel_3, $channel_4, $channel_5, $channel_6, $channel_7, $supply_v, $analogue_v, $int_temp, $jon)=split(/\s+/,$record,15);
            $dbtab=$mooring."_".$ext;
            #if (($rec_type eq $oc1_sn)&($message_year > 2008)) {
              # find time
              $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
              $rec_time=$basedate+int( ($message_time-1)  * 86400);
              ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
              $rec_date_time=sprintf("%04u-%02u-% 02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

              $sqlsel="SELECT *  FROM ".$dbtab." WHERE Date_Time = '$rec_date_time'";
              # print("$sqlsel\n");
              $sel = $dbh->prepare($sqlsel);
              $sel->execute();
              # || die "select: $sqlsel failed";

              @rowh=$sel->fetchrow_array();

              unless (@rowh) {
                $sql="INSERT INTO ".$dbtab." SET Date_Time='".$rec_date_time."'";
                # print("$sql\n");
                $ins = $dbh->prepare($sql);
                $ins->execute()  || die "insert $sql failed";
              }

              $sqlupd="UPDATE ".$dbtab." SET  seconds='".$seconds."', ";
              $sqlupd.=" channel_1='".$channel_1."', ";
              $sqlupd.=" channel_2='".$channel_2."', ";
              $sqlupd.=" channel_3='".$channel_3."', ";
              $sqlupd.=" channel_4='".$channel_4."', ";
              $sqlupd.=" channel_5='".$channel_5."', ";
              $sqlupd.=" channel_6='".$channel_6."', ";
              $sqlupd.=" channel_7='".$channel_7."', ";
              $sqlupd.=" supply_v='".$supply_v."', ";
              $sqlupd.=" analogue_v='".$analogue_v."', ";
              $sqlupd.=" int_temp='".$int_temp."', ";
              $sqlupd.=" add_dat  ='".$nowdate."' ";
              $sqlupd.=" where Date_Time = '".$rec_date_time."'";
              # print("$sqlupd\n");

              $ins = $dbh->prepare($sqlupd);
              $ins->execute()|| die "update: $sqlupd failed";

              # $rec_date_time=0;
            #}
          }
#############################################################
# Satlantic OCR-507 R10W radiance
          #elsif ($ext eq "oc2") {
            #($message_year,$message_time,$seconds, $rec_type, $channel_1, $channel_2, $channel_3, $channel_4, $channel_5, $channel_6, $channel_7, $supply_v, $analogue_v, $int_temp, $jon)=split(/\s+/,$record,15);
            ## print ("OC20 $record\n $message_year $message_time :: \n");
            #if (($rec_type eq $oc2_sn)&($message_year > 2008)) {
              ## find time
              #$basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
              #$rec_time=$basedate+int( ($message_time-1)  * 86400);
              #($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
              #$rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
#
              #$sqlsel="SELECT *  FROM ".$mooring."_oc2 WHERE Date_Time = '$rec_date_time'";
              ## print("$sqlsel\n");
              #$sel = $dbh->prepare($sqlsel);
              #$sel->execute();
              ## || die "select: $sqlsel failed";
#
              #@rowh=$sel->fetchrow_array();
              #unless (@rowh) {
                #$sql="INSERT INTO ".$mooring."_oc2 SET Date_Time='".$rec_date_time."'";
                #$ins = $dbh->prepare($sql);
                #$ins->execute()  || die "insert $sql failed";
              #}
#
              #$sqlupd="UPDATE ".$mooring."_oc2 SET  seconds='".$seconds."', ";
              #$sqlupd.=" channel_1='".$channel_1."', ";
              #$sqlupd.=" channel_2='".$channel_2."', ";
              #$sqlupd.=" channel_3='".$channel_3."', ";
              #$sqlupd.=" channel_4='".$channel_4."', ";
              #$sqlupd.=" channel_5='".$channel_5."', ";
              #$sqlupd.=" channel_6='".$channel_6."', ";
              #$sqlupd.=" channel_7='".$channel_7."', ";
              #$sqlupd.=" supply_v='".$supply_v."', ";
              #$sqlupd.=" analogue_v='".$analogue_v."', ";
              #$sqlupd.=" int_temp='".$int_temp."', ";
              #$sqlupd.=" add_dat  ='".$nowdate."' ";
              #$sqlupd.=" where Date_Time = '".$rec_date_time."'";
              ## print("$sqlupd\n");
#
              #$ins = $dbh->prepare($sqlupd);
              #$ins->execute()|| die "update: $sqlupd failed";
#
              ## $rec_date_time=0;
            #}
          #}
#############################################################
# Satlantic OCR-507 ICSA (buoy)
#          elsif ($ext eq "oc3") {
#            ($message_year,$message_time,$seconds, $rec_type, $channel_1, $channel_2, $channel_3, $channel_4, $channel_5, $channel_6, $channel_7, $supply_v, $analogue_v, $int_temp, $jon)=split(/\s+/,$record,15);
#            #print ("OC30 $record\n $message_year $message_time ::$rec_type, $channel_1\n");
#            if (($rec_type eq $oc3_sn)&($message_year > 2008)) {
#              # find time
#              $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
#              $rec_time=$basedate+int( ($message_time-1)  * 86400);
#              ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
#              $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
#
#              $sqlsel="SELECT *  FROM ".$mooring."_oc3 WHERE Date_Time = '$rec_date_time'";
#              # print("$sqlsel\n");
#              $sel = $dbh->prepare($sqlsel);
#              $sel->execute();
#              # || die "select: $sqlsel failed";
#
#              @rowh=$sel->fetchrow_array();
#              unless (@rowh) {
#                $sql="INSERT INTO ".$mooring."_oc3 SET Date_Time='".$rec_date_time."'";
#                $ins = $dbh->prepare($sql);
#                $ins->execute()  || die "insert $sql failed";
#              }
#
#              $sqlupd="UPDATE ".$mooring."_oc3 SET  seconds='".$seconds."', ";
#              $sqlupd.=" channel_1='".$channel_1."', ";
#              $sqlupd.=" channel_2='".$channel_2."', ";
#              $sqlupd.=" channel_3='".$channel_3."', ";
#              $sqlupd.=" channel_4='".$channel_4."', ";
#              $sqlupd.=" channel_5='".$channel_5."', ";
#              $sqlupd.=" channel_6='".$channel_6."', ";
#              $sqlupd.=" channel_7='".$channel_7."', ";
#              $sqlupd.=" supply_v='".$supply_v."', ";
#              $sqlupd.=" analogue_v='".$analogue_v."', ";
#              $sqlupd.=" int_temp='".$int_temp."', ";
#              $sqlupd.=" add_dat  ='".$nowdate."' ";
#              $sqlupd.=" where Date_Time = '".$rec_date_time."'";
#              # print("$sqlupd\n");
#
#              $ins = $dbh->prepare($sqlupd);
#              $ins->execute()|| die "update: $sqlupd failed";
#
          #    # $rec_date_time=0;
          #  }
          #}
#############################################################
# SP101 Melchor Gonzalez
          elsif ($ext eq "ph1") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $ind, $pH, $pH_error, $temp, $psal, $time_diff, $rest)=split(/\s+/,$record,11);
            # $serial_no,
            # print ("PH10 $message_year,$message_time,$sensor_year,$sensor_time, $ind, $pH, $pH_error, $temp, $psal  \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # $time_diff=($message_time-$sensor_time)*86400;
            # print "PH12 $rec_date_time $sensor_rec_date_time $time_diff\n";

            $sqlsel="SELECT *  FROM ".$mooring."_ph1 WHERE Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_ph1 SET Date_Time='".$sensor_rec_date_time."'";
              # print "PH1 sql $sql \n";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_ph1 SET ind='".$ind."',";
            $sqlupd.="pH='".$pH."',";
            $sqlupd.="pH_error='".$pH_error."',";
            $sqlupd.="temp='".$temp."',";
            $sqlupd.="psal='".$psal."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print ("PH1sql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
###########################################################
# WETLabs Cycle Phosphate sensor
          elsif ($ext eq "po4") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $run_count,$CAPO4,$VAPO4,$VAS,$state,$flush1,$amb_min,$cal_min, $rem_samp,$diag1,$diag2,$supply_v,$time_diff)=split(/\s+/,$record,17);
            # print ("PO40 $record\n $message_year $message_time ::  \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            # print "PO42 $rec_date_time $sensor_rec_date_time $time_diff\n";
            if (abs($time_diff)< 8000) {
              $sqlsel="SELECT *  FROM ".$mooring."_po4 WHERE Date_Time = '".$sensor_rec_date_time."'";

              # print("$sqlsel\n");
              $sel = $dbh->prepare($sqlsel);
              $sel->execute();
              # || die "select: $sqlsel failed";

              @rowh=$sel->fetchrow_array();

              unless (@rowh) {
                $sql="INSERT INTO ".$mooring."_po4 SET Date_Time='".$sensor_rec_date_time."'";
                $ins = $dbh->prepare($sql);
                $ins->execute()  || die "insert $sql failed";
              }

              $sqlupd="UPDATE ".$mooring."_po4 SET run_count='".$run_count."',";
              $sqlupd.="CAPO4='".$CAPO4."',";
              $sqlupd.="VAPO4='".$VAPO4."',";
              $sqlupd.="VAS='".$VAS."',";
              $sqlupd.="state='".$state."',";
              $sqlupd.="flush1='".$flush1."',";
              $sqlupd.="amb_min='".$amb_min."',";
              $sqlupd.="cal_min='".$cal_min."',";
              $sqlupd.="rem_samp='".$rem_samp."',";
              $sqlupd.="diag1='".$diag1."',";
              $sqlupd.="diag2='".$diag2."',";
              $sqlupd.="supply_v='".$supply_v."',";
              $sqlupd.="time_diff='".$time_diff."',";
              $sqlupd.=" add_dat='".$nowdate."' ";
              $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
              # print ("PO4sql $sqlupd \n");
              $ins = $dbh->prepare($sqlupd);
              $ins->execute()|| die "update: $sqlupd failed";
            }
          }
######################################################################
# Telemetry Power
          elsif ($ext eq "pwr") {
            ($message_year,$message_time,$batt_volt, $current_batt,$current_hub,$batt_power,$housing_hum,$housing_temp,$time_diff)=split(/\s+/,$record,9);
            # print ("PWR0 $message_year,$message_time,$batt_volt, $current_batt,$current_hub,$batt_power,$housing_hum,$housing_temp,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "PWR2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_pwr WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_pwr SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }
            $sqlupd="UPDATE ".$mooring."_pwr SET batt_volt='".$batt_volt."', " ;
            $sqlupd.="current_batt='".$current_batt."',";
            $sqlupd.="current_hub='".$current_hub."',";
            $sqlupd.="batt_power='".$batt_power."',";
            $sqlupd.="housing_hum='".$housing_hum."',";
            $sqlupd.="housing_temp='".$housing_temp."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("PWR sql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
##########################################################################
# SeaBird SBE-37IMP-ODO MicroCAT
          elsif ($ext eq "sbe") {
#             ($message_year,$message_time,$sensor_year,$sensor_time, $sensor_sn, $sbe_temp, $sbe_press, $sbe_cond,$jon)=split(/\s+/,$record,9);
#             # print ("SBE0 $record\n $message_year $message_time $sensor_sn::::$sbe:temp::$sbe_press\n");
#
#             if (($sensor_year == 2000) & ($sensor_time < 2)) {
#               $sensor_year = $message_year;
#               $sensor_time = $message_time - 0.018;
#             }    # Guess at about 20 minutes earlier and then take nearest hour
#
#             #find if serial no is known
#             $j=0;
#             $nom_depth=0;
#             while($j < $nv_sbe) {
#               if ($sn_sbe[$j] eq $sensor_sn) {
#                 $nom_depth=$Depths_sbe[$j];   # relates to names in dbase
#                 $st_sec_offset=$st_sec_sbe[$j];
#                 $j=$nv_sbe;
#               # } elsif($sn_sbe[$j] eq 9999) {
#                 # $sn_sbe[$j]=$sensor_sn;
#                 # $j=$nv_sbe;
#               } else {
#                 $j++;
#               }
#             }
#             # print "SBE1$sensor_sn :: $nom_depth :: $st_sec_offset\n";
#
#             # basic validation after data problem 2007-Jul-10
#             # tests for sensible message year, serial number and depth
#             if ( (abs($message_year-$sensor_year) <= 1 ) and ($nom_depth ne 0) ) {
#               # and (abs($nom_depth - $sbe_press)< ($nom_depth/5)) )
#               $basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
#               $rec_time=$basedate+int( ($sensor_time-1)  * 86400);    # record time in unix
#               ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
#
#               # find time
#               $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
#               if ($sbe_qc_Date_Time < 1) { $sbe_qc_Date_Time=$rec_date_time;}
#               if ($sbe_qc_Date_Time ne $rec_date_time) {
#                 # print("QC CALL 1\n");
#                 $Date_Time=$sbe_qc_Date_Time;
#                 # qc_call();
#                 $sbe_qc_Date_Time=$rec_date_time;
#               }
#
#               # $sqlsel="SELECT *  FROM ".$mooring."_data WHERE Date_Time = '".$rec_date_time."'";
#               $sqlsel="SELECT *  FROM ".$mooring."_data WHERE ABS(TIMEDIFF(Date_Time,'".$rec_date_time."'))<5";
#               # print("$sqlsel\n");
#               $sel = $dbh->prepare($sqlsel);
#               $sel->execute();
#               # || die "select: $sqlsel failed";
#
#               @rowh=$sel->fetchrow_array();
#
#               unless (@rowh) {
#                 $sql="INSERT INTO ".$mooring."_data SET Date_Time='".$rec_date_time."'";
#                 $ins = $dbh->prepare($sql);
#                 $ins->execute()  || die "insert $sql failed";
#               }
#
#               $sbe_cond=$sbe_cond*10;
#               $sqlupd="UPDATE ".$mooring."_data SET  temp".$nom_depth." = $sbe_temp, ";
#               $sqlupd.="cond".$nom_depth." = $sbe_cond, ";
#               $sqlupd.="press".$nom_depth." = $sbe_press, ";
#               # $sqlupd.="time_dif".$nom_depth." = $secs_diff, ";
#               $sqlupd.="add_dat='".$nowdate."' ";
#               # $sqlupd.=" where Date_Time = '".$rec_date_time."'";
#               $sqlupd.=" WHERE ABS(TIMEDIFF(Date_Time,'".$rec_date_time."'))<5";
#               #print ("SBE sql $sqlupd \n");
#
#               $ins = $dbh->prepare($sqlupd);
#               $ins->execute()|| die "update: $sqlupd failed";
#             }
            print("Not using .sbe file for this deployment\n");
          }
#########################################################
# SeaBird SBE-37IMP-ODO MicroCAT
          elsif ($ext eq "sbo" and $fn_len>11) {
            ($message_year,$message_time,$sensor_year,$sensor_time, $sensor_sn, $sbo_temp, $sbo_press, $sbo_cond, $sbo_ox, $jon, %$jon1)=split(/\s+/,$record,11);
            # print ("SBO0 $record\n $message_year $message_time $sensor_sn::::$sbo:temp::$sbo_press::$sbo_ox\n");

            if (($sensor_year == 2000) & ($sensor_time < 2)) {
              $sensor_year = $message_year;
              $sensor_time = $message_time - 0.018;
            }    # Guess at about 20 minutes earlier and then take nearest hour
            # for testing sensortime apears stuck so use message time
            if (($sensor_year == 2015) & ($sensor_time < 180)) {
              $sensor_year = $message_year;
              $sensor_time = $message_time - 0.018;
            }    # Guess at about 20 minutes earlier and then take nearest hour

            #find if serial no is known
            $j=0;
            $nom_depth=0;
            while($j < $nv_sbo) {
              if ($sn_sbo[$j] eq $sensor_sn) {
                $nom_depth=$Depths_sbo[$j];   # relates to names in dbase
                $st_sec_offset=$st_sec_sbe[$j];
                $sub=$j+1;
                $j=$nv_sbo;
              } else {
                $j++;
              }
            }
            # print "SBO1$sensor_sn :: $nom_depth :: $st_sec_offset\n";

            $db_ext=$ext."_".$sub;

            # basic validation after data problem 2007-Jul-10
            # tests for sensible message year, serial number and depth
            # and (abs($nom_depth - $sbo_press)< ($nom_depth/5)) )
            if ( (abs($message_year-$sensor_year) <= 1 ) and ($nom_depth ne 0) ) {
              $basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
              $rec_time=$basedate+int( ($sensor_time-1)  * 86400);    # record time in unix
              ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);

              $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
              if ($sbo_qc_Date_Time < 1) { $sbo_qc_Date_Time=$rec_date_time;}
              if ($sbo_qc_Date_Time ne $rec_date_time) {
                # print("QC CALL 1\n");
                $Date_Time=$sbo_qc_Date_Time;
                # qc_call();
                $sbo_qc_Date_Time=$rec_date_time;
              }

              # $sqlsel="SELECT *  FROM ".$mooring."_".$db_ext." WHERE Date_Time = '".$rec_date_time."'";
              $sqlsel="SELECT *  FROM ".$mooring."_".$db_ext." WHERE ABS(TIMEDIFF(Date_Time,'".$rec_date_time."'))<5";
              # print("$sqlsel\n");
              $sel = $dbh->prepare($sqlsel);
              $sel->execute();
              # || die "select: $sqlsel failed";

              @rowh=$sel->fetchrow_array();

              unless (@rowh) {
                $sql="INSERT INTO ".$mooring."_".$db_ext." SET Date_Time='".$rec_date_time."'";
                $ins = $dbh->prepare($sql);
                $ins->execute()  || die "insert $sql failed";
              }

              $sbo_cond=$sbo_cond*10;
              $sqlupd="UPDATE ".$mooring."_".$db_ext." SET sbo_temp = $sbo_temp, ";
              $sqlupd.="sbo_cond = $sbo_cond, ";
              $sqlupd.="sbo_press = $sbo_press, ";
              $sqlupd.="sbo_ox = $sbo_ox, ";
              # $sqlupd.="time_dif1 = $secs_diff, ";
              # SBO_2 cond sensor not recording correctly from 2016-01-31 21:00:59
              if (($db_ext eq "sbo_2") && (($rec_date_time gt "2016-01-31") && ($rec_date_time lt "2016-04-25") ) ){
                $sqlupd.="sbo_cond_qc = 4, ";
              }
              $sqlupd.="add_dat='".$nowdate."' ";
              # $sqlupd.=" where Date_Time = '".$rec_date_time."'";
              $sqlupd.=" WHERE ABS(TIMEDIFF(Date_Time,'".$rec_date_time."'))<5";
              #print ("SBO sql $sqlupd \n");

              $ins = $dbh->prepare($sqlupd);
              $ins->execute()|| die "update: $sqlupd failed";
            }
          }
          elsif ($ext eq "sbo") {
            print("Not processing merged sbo file\n");
          }
######################################################################
# Aanderaa 4430H Seaguard
          elsif ($ext eq "sea") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $sample_no,
            $batt_voltage, $memory_used, $time_int,
            $clock_correction,
            $cyclops_chl,
            $Aa_ox_microM, $Aa_ox_air_sat, $Aa_ox_temp, $Aa_ox_cal_phase, $Aa_ox_tcphase,
            $Aa_ox_c1_r_ph,$Aa_ox_c2_r_ph,$Aa_ox_c1_a,$Aa_ox_c2_a, $Aa_ox_raw_temp,
            $rcm_speed, $rcm_dir, $rcm_n, $rcm_e, $heading_mag, $tilt_x, $tilt_y,
            $sp_std, $sig_strength,$ping_count,
            $abs_tilt, $max_tilt, $std_tilt,
            #$o_conc, $o_sat, $o_sea_temp,
            $jon)=split(/\s+/,$record,34);
            # print ("SEA0 $record\n $message_year $message_time ::$o_conc, $o_sat, $o_sea_temp \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate+int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_sea WHERE Date_Time = '$sensor_rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_sea SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_sea SET  sample_no='".$sample_no."', ";
            $sqlupd.=" batt_voltage='".$batt_voltage."', ";
            $sqlupd.=" memory_used='".$memory_used."', ";
            $sqlupd.=" time_int='".$time_int."', ";
            $sqlupd.=" cyclops_chl='".$cyclops_chl."', ";
            $sqlupd.=" Aa_ox_microM='".$Aa_ox_microM."', ";
            $sqlupd.=" Aa_ox_air_sat='".$Aa_ox_air_sat."', ";
            $sqlupd.=" Aa_ox_temp='".$Aa_ox_temp."', ";
            $sqlupd.=" Aa_ox_cal_phase='".$Aa_ox_cal_phase."', ";
            $sqlupd.=" Aa_ox_tcphase='".$Aa_ox_tcphase."', ";
            $sqlupd.=" Aa_ox_c1_r_ph='".$Aa_ox_c1_r_ph."', ";
            $sqlupd.=" Aa_ox_c2_r_ph='".$Aa_ox_c2_r_ph."', ";
            $sqlupd.=" Aa_ox_c1_a='".$Aa_ox_c1_a."', ";
            $sqlupd.=" Aa_ox_c2_a='".$Aa_ox_c2_a."', ";
            $sqlupd.=" Aa_ox_raw_temp='".$Aa_ox_raw_temp."', ";
            $sqlupd.=" rcm_speed='".$rcm_speed."', ";
            $sqlupd.=" rcm_dir='".$rcm_dir."', ";
            $sqlupd.=" rcm_n='".$rcm_n."', ";
            $sqlupd.=" rcm_e='".$rcm_e."', ";
            $sqlupd.=" heading_mag='".$heading_mag."', ";
            $sqlupd.=" tilt_x='".$tilt_x."', ";
            $sqlupd.=" tilt_y='".$tilt_y."', ";
            $sqlupd.=" sp_std='".$sp_std."', ";
            $sqlupd.=" sig_strength='".$sig_strength."', ";
            $sqlupd.=" ping_count='".$ping_count."', ";
            $sqlupd.=" abs_tilt='".$abs_tilt."', ";
            $sqlupd.=" max_tilt='".$max_tilt."', ";
            $sqlupd.=" std_tilt='".$std_tilt."', ";
            $sqlupd.=" time_diff='".$time_diff."', ";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
            # $rec_date_time=0;
            # $sensor_rec_date_time=0;
            # $time_diff=99999;
          }
######################################################################
# Aanderaa 4430H Seaguard - corrected
          elsif ($ext eq "seacorr") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $sample_no,
            $batt_voltage, $memory_used, $time_int,
            $clock_correction,
            $cyclops_chl,
            $Aa_ox_microM, $Aa_ox_air_sat, $Aa_ox_temp, $Aa_ox_cal_phase, $Aa_ox_tcphase,
            $Aa_ox_c1_r_ph,$Aa_ox_c2_r_ph,$Aa_ox_c1_a,$Aa_ox_c2_a, $Aa_ox_raw_temp,
            $rcm_speed, $rcm_dir, $rcm_n, $rcm_e, $heading_mag, $tilt_x, $tilt_y,
            $sp_std, $sig_strength,$ping_count,
            $abs_tilt, $max_tilt, $std_tilt,
            $jon,$O_corr,$PforCorr,$SforCorr)=split(/\s+/,$record,37);
            # print ("SEA0 $record\n $message_year $message_time ::$o_conc, $o_sat, $o_sea_temp,$jon,$O_corr,$PforCorr,$SforCorr \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate+int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_".$ext." WHERE Date_Time = '$sensor_rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_".$ext."  SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_".$ext."  SET  sample_no='".$sample_no."', ";
            $sqlupd.=" batt_voltage='".$batt_voltage."', ";
            $sqlupd.=" memory_used='".$memory_used."', ";
            $sqlupd.=" time_int='".$time_int."', ";
            $sqlupd.=" cyclops_chl='".$cyclops_chl."', ";
            $sqlupd.=" Aa_ox_microM='".$Aa_ox_microM."', ";
            $sqlupd.=" Aa_ox_air_sat='".$Aa_ox_air_sat."', ";
            $sqlupd.=" Aa_ox_temp='".$Aa_ox_temp."', ";
            $sqlupd.=" Aa_ox_cal_phase='".$Aa_ox_cal_phase."', ";
            $sqlupd.=" Aa_ox_tcphase='".$Aa_ox_tcphase."', ";
            $sqlupd.=" Aa_ox_c1_r_ph='".$Aa_ox_c1_r_ph."', ";
            $sqlupd.=" Aa_ox_c2_r_ph='".$Aa_ox_c2_r_ph."', ";
            $sqlupd.=" Aa_ox_c1_a='".$Aa_ox_c1_a."', ";
            $sqlupd.=" Aa_ox_c2_a='".$Aa_ox_c2_a."', ";
            $sqlupd.=" Aa_ox_raw_temp='".$Aa_ox_raw_temp."', ";
            $sqlupd.=" rcm_speed='".$rcm_speed."', ";
            $sqlupd.=" rcm_dir='".$rcm_dir."', ";
            $sqlupd.=" rcm_n='".$rcm_n."', ";
            $sqlupd.=" rcm_e='".$rcm_e."', ";
            $sqlupd.=" heading_mag='".$heading_mag."', ";
            $sqlupd.=" tilt_x='".$tilt_x."', ";
            $sqlupd.=" tilt_y='".$tilt_y."', ";
            $sqlupd.=" sp_std='".$sp_std."', ";
            $sqlupd.=" sig_strength='".$sig_strength."', ";
            $sqlupd.=" ping_count='".$ping_count."', ";
            $sqlupd.=" abs_tilt='".$abs_tilt."', ";
            $sqlupd.=" max_tilt='".$max_tilt."', ";
            $sqlupd.=" std_tilt='".$std_tilt."', ";
            $sqlupd.=" time_diff='".$time_diff."', ";
            $sqlupd.=" O_corr='".$O_corr."', ";
            $sqlupd.=" PforCorr='".$PforCorr."', ";
            $sqlupd.=" SforCorr='".$SforCorr."', ";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
            # $rec_date_time=0;
            # $sensor_rec_date_time=0;
            # $time_diff=99999;
          }
#############################################################
# Telemetry Motion Control
          elsif ($ext eq "st1") {
            ($message_year,$message_time,$diff_gps_pers,$space_left,$gps_fixes,$comp_messages,$accel_messages,$ocr3_messages,$co2_messages,$seafet_messages,$guest_messages,$time_diff)=split(/\s+/,$record,12);
            # print ("ST10  $message_year,$message_time,$diff_gps_pers,$space_left,$gps_fixes,$comp_messages,$accel_messages,$ocr3_messages,$co2_messages,$seafet_messages,$guest_messages,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "ST12 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_ST1 WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_ST1 SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }


            $sqlupd="UPDATE ".$mooring."_ST1 SET  diff_gps_pers='".$diff_gps_pers."', ";
            $sqlupd.="space_left='".$space_left."',";
            $sqlupd.="gps_fixes='".$gps_fixes."',";
            $sqlupd.="comp_messages='".$comp_messages."',";
            $sqlupd.="accel_messages='".$accel_messages."',";
            $sqlupd.="ocr3_messages='".$ocr3_messages."',";
            $sqlupd.="co2_messages='".$co2_messages."',";
            $sqlupd.="seafet_messages='".$seafet_messages."',";
            $sqlupd.="guest_messages='".$guest_messages."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("ST1sql $sqlupd \n");
            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#############################################################
# Satlantic SUNA V2
          elsif ($ext eq "sun") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $serial_no, $n_mM, $n_mg_l, $abs_254, $abs_350, $bromide, $rmse, $time_diff, $rest)=split(/\s+/,$record,13);
            # print ("SUN0 $record\n $message_year $message_time ::  \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;
            # print "SUN2 $rec_date_time $sensor_rec_date_time $time_diff\n";

            $sqlsel="SELECT *  FROM ".$mooring."_sun WHERE Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_sun SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_sun SET n_mM='".$n_mM."',";
            $sqlupd.="n_mg_l='".$n_mg_l."',";
            $sqlupd.="abs_254='".$abs_254."',";
            $sqlupd.="abs_350='".$abs_350."',";
            $sqlupd.="bromide='".$bromide."',";
            $sqlupd.="rmse='".$rmse."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print ("SUNsql $sqlupd \n");
            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
# WETLabs FLNTUSB Fluorometer
          elsif ($ext eq "wet") {
            #changed to use hub time 4-aug-2010
            # if(($message_year>=2009)&($message_time > 197)) {
            ($message_year,$message_time,$sensor_year,$sensor_time, $rec_type, $fl_chl_ref,$fl_chl, $fl_ntu_ref,$fl_ntu,  $fl_thermistor, $fl_pressure,$time_diff2)=split(/\s+/,$record,12);
            # } else {
            #   ($message_year,$message_time,$sensor_year,$sensor_time, $fl_chl_ref,$fl_chl, $fl_ntu_ref,$fl_ntu,  $fl_thermistor, $fl_pressure,$time_diff2)=split(/\s+/,$record,11);
            # }
            # print ("WET0 $record\n $message_year $message_time :: $fl_pressure2\n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate+int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            if($sensor_year>0) {$sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900); }
            else {$sensor_basedate=timegm(0,0,0,1,1-1,$message_year - 1900);}
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_wet WHERE Date_Time = '$rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_wet SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_wet SET  fl_chl_ref='".$fl_chl_ref."', ";
            $sqlupd.=" fl_chl='".$fl_chl."', ";
            $sqlupd.=" fl_ntu_ref='".$fl_ntu_ref."', ";
            $sqlupd.=" fl_ntu='".$fl_ntu."', ";
            $sqlupd.=" fl_thermistor='".$fl_thermistor."', ";
            $sqlupd.=" fl_pressure='".$fl_pressure."', ";
            $sqlupd.=" time_diff='".$time_diff."', ";
            $sqlupd.=" time_diff2='".$time_diff2."', ";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
# From here - not expecting in this deployment
#########################################################
# buoy pitch and roll data
          elsif ($ext eq "cmp") {
            ($message_year,$message_time,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$time_diff)=split(/\s+/,$record,12);
            # print ("CMP0  $message_time,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "CMP2 $rec_date_time\n";

            $sqlsel="SELECT *  FROM ".$mooring."_cmp WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_cmp SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_cmp SET  max_pitch='".$max_pitch."', ";
            $sqlupd.="min_pitch='".$min_pitch."',";
            $sqlupd.="ave_pitch='".$ave_pitch."',";
            $sqlupd.="max_roll='".$max_roll."',";
            $sqlupd.="min_roll='".$min_roll."',";
            $sqlupd.="ave_roll='".$ave_roll."',";
            $sqlupd.="max_mag_heading='".$max_mag_heading."',";
            $sqlupd.="min_mag_heading='".$min_mag_heading."',";
            $sqlupd.="ave_mag_heading='".$ave_mag_heading."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("CMPsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
# buoy pitch and roll data
          elsif ($ext eq "ez3") {
            ($message_year,$message_time,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$time_diff)=split(/\s+/,$record,12);
            # print ("EZ30  $message_time,$max_pitch,$min_pitch,$ave_pitch,$max_roll,$min_roll,$ave_roll,$max_mag_heading,$min_mag_heading,$ave_mag_heading,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "EZ32 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_ez3 WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_ez3 SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_ez3 SET  max_pitch='".$max_pitch."', ";
            $sqlupd.="min_pitch='".$min_pitch."',";
            $sqlupd.="ave_pitch='".$ave_pitch."',";
            $sqlupd.="max_roll='".$max_roll."',";
            $sqlupd.="min_roll='".$min_roll."',";
            $sqlupd.="ave_roll='".$ave_roll."',";
            $sqlupd.="max_mag_heading='".$max_mag_heading."',";
            $sqlupd.="min_mag_heading='".$min_mag_heading."',";
            $sqlupd.="ave_mag_heading='".$ave_mag_heading."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("EZ3sql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
          elsif ($ext eq "iss") {
            ($message_year,$message_time,$sensor_year,$sensor_time, $isus_serial_no,$isus_n,$isus_n_rms,$isus_temp1,$isus_humidity,$isus_volt,$isus_dark_calc,$isus_average,$jon)=split(/\s+/,$record,13);
            # print ("ISS0 $record\n $message_year $message_time :: $isus_n \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;
            # print "ISS2 $rec_date_time $sensor_rec_date_time $time_diff\n";

            $sqlsel="SELECT *  FROM ".$mooring."_iss WHERE Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_iss SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_iss SET isus_n='".$isus_n."',";
            $sqlupd.="isus_n_rms='".$isus_n_rms."',";
            $sqlupd.="isus_temp1='".$isus_temp1."',";
            $sqlupd.="isus_humidity='".$isus_humidity."',";
            $sqlupd.="isus_volt='".$isus_volt."',";
            $sqlupd.="isus_dark_calc='".$isus_dark_calc."',";
            $sqlupd.="isus_average='".$isus_average."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print ("MONsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
# engineering data
          elsif ($ext eq "mon") {
            ($message_year,$message_time,$solar_panel_v,$supply_v,$battery_v,$solar_panel_mA,$consumed_mA,$battery_mA,$temperature_bottom,$temperature_top,$temperature_middle,$time_diff)=split(/\s+/,$record,12);
            # print ("MON0   $solar_panel_v,$supply_v,$battery_v,$solar_panel_mA,$consumed_mA,$battery_mA,$temperature_bottom,$temperature_top,$temperature_middle,$time_diff \n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate + int( ($message_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            # print "MON2 $rec_date_time \n";

            $sqlsel="SELECT *  FROM ".$mooring."_engineering WHERE Date_Time = '".$rec_date_time."'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_engineering SET Date_Time='".$rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_engineering SET  solar_panel_v='".$solar_panel_v."', ";
            $sqlupd.="supply_v='".$supply_v."',";
            $sqlupd.="battery_v='".$battery_v."',";
            $sqlupd.="solar_panel_mA='".$solar_panel_mA."',";
            $sqlupd.="consumed_mA='".$consumed_mA."',";
            $sqlupd.="battery_mA='".$battery_mA."',";
            $sqlupd.="temperature_top='".$temperature_top."',";
            $sqlupd.="temperature_bottom='".$temperature_bottom."',";
            $sqlupd.="temperature_middle='".$temperature_middle."',";
            $sqlupd.="time_diff='".$time_diff."',";
            $sqlupd.=" add_dat='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$rec_date_time."'";
            # print ("MONsql $sqlupd \n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";
          }
#########################################################
          elsif ($ext eq "nas") {
            ($message_year,$message_time,$sensor_year,$sensor_time,$x1, $rec_type, $nas_batt_v, $nas_light_in, $nas_light_out, $time_diff)=split(/\s+/,$record,11);
            # print ("NAZ0 $record\n $message_year, $message_time :: $rec_type, $nas_batt_v, $nas_light_in, $nas_light_out, $time_diff\n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate+int( ($message_time-1)  * 86400);;
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_naz WHERE Date_Time = '$sensor_rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_naz SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_naz SET  sample_no='".$sample_no."', ";
            $sqlupd.=" rec_type ='".$rec_type."', ";
            $sqlupd.=" nas_batt_v='".$nas_batt_v."', ";
            $sqlupd.=" nas_light_in='".$nas_light_in."', ";
            $sqlupd.=" nas_light_out='".$nas_light_out."', ";
            $sqlupd.=" time_diff='".$time_diff."', ";
            $sqlupd.=" add_dat  ='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";

            # $rec_date_time=0;
            # $sensor_rec_date_time=0;
            # $time_diff=99999;
          }
#########################################################
# Derived NO3
          elsif ($ext eq "nax") {
            ($message_year,$message_time,$sensor_year,$sensor_time,$sample_no, $rec_type, $channel_w, $channel_x, $channel_y, $channel_z,$jon)=split(/\s+/,$record,11);
            # print ("NAX0 $record\n $message_year, $message_time ::$sample_no, $rec_type, $channel_w, $channel_x, $channel_y, $channel_z\n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$message_year - 1900);
            $rec_time=$basedate+int( ($message_time-1)  * 86400);;
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($rec_time);
            $rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_nax WHERE Date_Time = '$sensor_rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_nax SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_nax SET  sample_no='".$sample_no."', ";
            $sqlupd.=" rec_type ='".$rec_type."', ";
            $sqlupd.=" channel_w='".$channel_w."', ";
            $sqlupd.=" channel_x='".$channel_x."', ";
            $sqlupd.=" channel_y='".$channel_y."', ";
            $sqlupd.=" channel_z='".$channel_z."', ";
            $sqlupd.=" time_diff='".$time_diff."', ";
            $sqlupd.=" add_dat  ='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";

            # $rec_date_time=0;
            # $sensor_rec_date_time=0;
            # $time_diff=99999;
          }
#########################################################
# Derived NO3
# mred 27Sep2010   was code nax for buoy6 May2010
          elsif ($ext eq "no3") {
            ($sensor_year,$sensor_time, $rec_type, $working,$N_conc, $absorbance, $std_a, $std_b)=split(/\s+/,$record,8);
            # print ("NO3 $record\n $sensor_year,$sensor_time, $rec_type, $working,$N_conc, $absorbance, $std_a, $std_b\n");

            # find time
            $basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);

            # find sensor time
            $sensor_basedate=timegm(0,0,0,1,1-1,$sensor_year - 1900);
            $sensor_rec_time=$sensor_basedate + int( ($sensor_time-1)  * 86400);
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime($sensor_rec_time);
            $sensor_rec_date_time=sprintf("%04u-%02u-%02u %02u:%02u:%02u",$year+1900,$mon+1,$mday,$hour,$min,$sec);
            $time_diff=($message_time-$sensor_time)*86400;

            $sqlsel="SELECT *  FROM ".$mooring."_nax WHERE Date_Time = '$sensor_rec_date_time'";
            # print("$sqlsel\n");
            $sel = $dbh->prepare($sqlsel);
            $sel->execute();
            # || die "select: $sqlsel failed";

            @rowh=$sel->fetchrow_array();

            unless (@rowh) {
              $sql="INSERT INTO ".$mooring."_nax SET Date_Time='".$sensor_rec_date_time."'";
              $ins = $dbh->prepare($sql);
              $ins->execute()  || die "insert $sql failed";
            }

            $sqlupd="UPDATE ".$mooring."_nax SET  working='".$working."', ";
            $sqlupd.=" N_conc ='".$N_conc."', ";
            $sqlupd.=" absorbance='".$absorbance."', ";
            $sqlupd.=" std_a='".$std_a."', ";
            $sqlupd.=" std_b='".$std_b."', ";
            $sqlupd.=" add_dat  ='".$nowdate."' ";
            $sqlupd.=" where Date_Time = '".$sensor_rec_date_time."'";
            # print("$sqlupd\n");

            $ins = $dbh->prepare($sqlupd);
            $ins->execute()|| die "update: $sqlupd failed";

            # $rec_date_time=0;
            # $sensor_rec_date_time=0;
            # $time_diff=99999;
          }
#########################################################
# Completed insertion into MySQL database tables
        } else {print("Unknown extension $ext - file ignored\n");} # End of 'if numeric content exists' loop
###########################################################################
      }  # End of 'while DATA' loop
#########################################################
# change $rec_date_time into unix and add data to email message
      if (length($rec_date_time) >16) {
        $unix_rec_date_time=timegm(substr($rec_date_time,17,2),substr($rec_date_time,14,2),substr($rec_date_time,11,2),substr($rec_date_time,8,2),(substr($rec_date_time,5,2)-1),(substr($rec_date_time,0,4)-1900));
        if ($unix_rec_date_time > $unix_last_run) {
          # &data_email($from_address,$to_address,$record,$filename);
          #print("  Send data email for $filename -last rec $rec_date_time\n$file_contents");
          print("  Send data email for $filename - last record $rec_date_time\n");
        }
      } else {
        print("  SHORT DATE: $ext:$rec_date_time \n");
      }
#########################################################
      # Apply QC to MicroCats
      if ($ext eq "sbe") {
        if ($sbe_qc_Date_Time < 1) {$sbe_qc_Date_Time=$rec_date_time;}

        # print("QC CALL 2\n");
        $Date_Time=$sbe_qc_Date_Time;
        # qc_call();
        $sbe_qc_Date_Time=0;
      }
#########################################################
      #removed from individual ext type code and put here after the email output
      $rec_date_time=0;
      $sensor_rec_date_time=0;
      $time_diff=99999;

      # Close input Data File
      close(DATA);
#########################################################
# Write output to csv files
      # write all data (not append as running full file each time)
      $a=$ext."_data_$nowmon";
      open(DATASAVE,  ">$output_dir/$mooring_lc"."_$a.dat");
      print DATASAVE  "$file_contents";

      close(DATASAVE);
    } # End of 'file updated and of correct name' loop
  } # End of while files still exist

  # If GPS location is outside defined range - email an alert
  if ($gps_range > $gps_range_test) {  # mrp 2009Jul21
    &alert_email($from_address,$to_address,$file_contents,$filename);
    # print ("MAIL $gps_range\n");
    $gps_range=-1;
  }
  $ext="";

######################################################################
# Finished processing files
  # Close open directory
  closedir(DIRHANDLE);

} else {
  print("     Couldn't open $file_dir : $!\n");
} # End of if opendir

# look at next day - not being used now as using concat file mred 20100920
$loop_time=$loop_time + 86400;
@tm=gmtime($loop_time);
$ddd=sprintf("%03u",@tm[7]+1);
$yyyy=@tm[5]+1900;
#print ("LOOP $yyyy  $ddd NOW $nowyyyy $nowddd \n");
#} # End of while year<thisyear or year=thisyear and day<=today

# Open 'latest_date file
open (DATE, "> $last_access_file");

# to pick up next time any received during this run
$nowunix=$nowunix-300;
print DATE "$nowunix\n";
#print DATE "$nv_sbe\n";

$j=0;
print DATE "sbe $nv_sbe\n";
while($j<$nv_sbe) {
  print DATE "$Depths_sbe[$j] $sn_sbe[$j] $st_sec_sbe[$j]\n";
  $j++;
}
$j=0;
print DATE "sbo $nv_sbo\n";
while($j<$nv_sbo) {
  print DATE "$Depths_sbo[$j] $sn_sbo[$j] $st_sec_sbo[$j]\n";
  print("$j :: Serial no $sn_sbe[$j] Depth $Depths_sbe[$j] Start Sec $st_sec_sbe[$j]\n");
  $j++;
}
$j=0;
print DATE "fet $nv_fet\n";
while($j<$nv_fet) {
  print DATE "$Depths_fet[$j] $sn_fet[$j] $st_sec_fet[$j]\n";
  print("$j :: Serial no $sn_fet[$j] Depth $Depths_fet[$j] Start Sec $st_sec_fet[$j]\n");
  $j++;
}

close(DATE);

# End of processing
######################################################################
# subroutines
######################################################################
sub alert_email {

$from_address=$_[0];
$to_address=$_[1];
$file_contents=$_[2];
$filename=$_[3];

$mailprog='/usr/lib/sendmail';

open( MAIL, "|$mailprog $to_address") or die "Can't open sendmail \n";

print MAIL <<"EOF";
Reply-to: $from_address
From: $from_address
To: $to_address
Subject: Iridium Alert $mooring $filename RANGE ERROR
$file_contents
EOF

close(MAIL);

} # End of subroutine alert_email
######################################################################
sub data_email {

$from_address=$_[0];
$to_address=$_[1];
$file_contents=$_[2];
$filename=$_[3];
$ext=substr($filename,-3);

$mailprog='/usr/lib/sendmail';

open( MAIL, "|$mailprog $to_address") or die "Can't open sendmail \n";

print MAIL <<"EOF";
Reply-to: $from_address
From: $from_address
To: $to_address
Subject: Iridium Data $mooring $filename
$file_contents
EOF

close(MAIL);

} # End of subroutine data_email
######################################################################
sub raw_to_ftp($) {
# copy data to ftp server
# buoy5 PAP 2007 so not to bodc
if ($transmitter ne 'buoy5') {

  $in_file=$file_dir."/".$filename;
  $to_ftp="/noc/itg/pubread/bodc/rapid/".$transmitter."/".$filename;
  `cp  $in_file $to_ftp`;
  `chmod 755 $to_ftp`;
}

unlink("$file_dir/$filename") or die "Cannot delete $filename : $!\n";

} # End of subroutine raw_to_ftp
######################################################################
sub qc_call($) {
# quality control for microcat
# make assumption that microcats will time progress in each file
# but allow for several records within each file do qc on change and on last
# store which Date_Times have been accessed read back and run across all microcats
# else gradient not checkable
# data qc'd needs to be in $DBtemp?? form for all variables
# $Date_Time="$rdyear-$rdmon-$rdmday $rdhour:$rdmin:$rdsec";
# $in_t_std=3;
# $in_c_std=3;

$sqlsel="SELECT * FROM ".$mooring."_data WHERE Date_Time = '$rec_date_time'";
$sel = $dbh->prepare($sqlsel);
$sel->execute();
# || die "select: $sqlsel failed";

@rowqc=$sel->fetchrow_array();

if (@rowqc) {
  # print ("QC DB :: $rec_date_time :: ");
  $j=2;
  for ($i=0 ; $i < $nv_sbe ; $i++) {
    $xvart="DBtemp".$Depths_sbe[$i];
    $xvarc="DBcond".$Depths_sbe[$i];
    $xvarp="DBpress".$Depths_sbe[$i];
    $$xvart=$rowqc[$j];
    $j++;
    $$xvarc=$rowqc[$j];
    $j++;
    $$xvarp=$rowqc[$j];
    $j=$j+2;
    # print (" $xvart, $$xvart ::  $xvarc, $$xvarc ::  $xvarp, $$xvarp ::");  # still part of QC DB
  }

  # print (" \n"); # still part of QC DB

  # print("Pap_Iridium  QUALITY CONTROL SUSPENDED for trialing \n");
  quality_control_v3("".$mooring."",$sbe_qc_Date_Time,$in_t_std,$in_c_std,@Depths);
  #
}

} # End of subroutine qc_call
######################################################################
