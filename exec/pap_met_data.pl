#!/nerc/packages/perl/bin/perl

# perl program to read PAP BUOY format message 3-Jun-2010

use DBI;
use CGI;
use File::stat;
use Time::Local;
use lib "/noc/users/animate/lib";
use quality_control_v3;

$dbh = DBI->connect("DBI:mysql:animate:mysql","animate_admin","an1mate9876") || die "Can't open $database";

$wmo=62442;
$mailprog='/usr/lib/sendmail';
$from_address="MET.DATA\@noc.soton.ac.uk";
$to_address="bodcnocs\@bodc.ac.uk";
$mooring="PAP201704";   # hms May 2017

@now=gmtime(time);
$nowmon = @now[4] + 1;
$nowyear = @now[5]+1900;
print "MONTH  $nowmon $now\n";

$nowunix = time();
@now = gmtime();
$nowdate=sprintf("%04d-%02d-%02d %02d:%02d:%02d", @now[5]+1900,@now[4]+1,@now[3],@now[2],@now[1],@now[0]);

$nowyyyy=@now[5]+1900;
$nowddd=sprintf("%03u",@now[7]+1);
$no_loops=int( ($nowunix-$last_run) / 86400);
$dir_in="/noc/users/animate/pap";
$dir_out="/noc/users/animate/pap";

open(DATEIN,   "<$dir_in/pap_date.dat");
chop($dat0 = <DATEIN>);
close(DATEIN);

open(DATAOUT,   " >> $dir_out/pap_met_data_$nowmon.dat");
open(RAWOUT,    " >> $dir_out/pap_met_data_".$nowmon."_raw.dat");


print ("DATES\n $dat0\n");    #this is start date
($dat1,$input_period_days)=split(/,/,$dat0,2);
$input_period=$input_period_days*60*60*24;
$last_year=substr($dat1,0,4);
$last_mon=substr($dat1,5,2);
$last_day=substr($dat1,8,2);
# using dates will allow last day of month and year to get sorted out
#if ($last_year >0)
#	{$tm1=gmtime(timegm(0,0,0,$last_day,$last_mon-1,$last_year-1900));}
#else 	{print("Error no startdate!\n"); exit;}

print("TEST DATE $last_year $last_mon $last_day $input_period :::\n");

#find files with today and yesterdays date
$file_dir="/noc/users/animate/pap/met_data/";
print("FILE_DIR $file_dir \n");
opendir(DIRHANDLE, $file_dir) or die "Couldn't open $file_dir : $!";

while ( defined($filename = readdir(DIRHANDLE) ) )
	{
	$inode = stat("$file_dir/$filename");  # left for completeness but I can just use filename mrp 03jun2010
	$mtime = $inode->mtime;                # modifies time is better as ftp keeps data for 10 or more days
	$filesize=$inode->size;
	$filetime=gmtime($mtime);
	$fileyear=$filetime[5]+1900;        # but may need for end of year code

#	print("FILE $file_dir/$filename YEAR $fileyear  $last_year \n");
# SIVF42_EGRR_030300_00005030.DAT
	$file_day       =substr $filename,12,2;
	$file_name_fixed=substr $filename,2,10;
	$time_diff=$nowunix-$mtime;
	print ("TEST0 filename $filename day:$file_day fixed: $file_name_fixed ::$nowunix-$mtime=$time_diff\n");
	if ( ($file_name_fixed eq "VF42_EGRR_")  &&  ( $time_diff < $input_period)  )
		{
		print ("TEST01 IN LOOP   $time_diff lt $input_period              \n");
		open(FILEIN,   "<$file_dir$filename");
		$file_1 = <FILEIN>;
		$file_2 = <FILEIN>;

		$file_start=substr($file_2,0,4);
		if ($file_start eq "BBXX")		#SHIP format
			{
#		print ("TEST1 file_format $file_start\n");
			while($message=<FILEIN>)
				{
				chomp($message);
#print("TEST91:$message\n");
				unless ($message=~ m/=/)
				 {
				 $message0 = <FILEIN>;
				 chomp($message0);
#print("TEST92:$message0\n");
				 }

				$mstart=substr($message,0,5);
				$fixed=substr($message,10,16);
#				print("WMO1:$mstart::FIXED:$fixed: \n");
				# and($message=~m?4 99490 70164 46?)
				if ($mstart eq 62442)
				{
#				print("WMO2:$mstart::FIXED:$fixed: \n");
				$mess_dom=substr($message,6,2);
				$mess_hour=substr($message,8,2);

				$mess_lat_ind=substr($message,12,2);
				$mess_lat=substr($message,14,3);
				$mess_lon_ind=substr($message,18,1);
				$mess_lon=substr($message,19,4);
				if ($mess_lat_ind eq 99)
				   {$met_lat=$mess_lat/10.;}
				else {$met_lat = 999;}
				if ($mess_lon_ind eq 7)   # specific for PAP as segment indicator
				   {$met_lon=$mess_lon/10.;}
				else {$met_lon = 999;}


				$wind_dir=substr($message,31,2)*10;
				$wind_speed=substr($message,33,2);
#				print("TEST3$message\n");
			#	print("TEST4:::$mess_dom:$mess_hour\n");

				$gid1=substr($message,36,1);
				$sign1=substr($message,37,1);
				if ($sign1 ne "/")
					{
					if($sign1==0){$sign1=1;}else{$sign1=-1;}
					$air_t=substr($message,38,3)/10*$sign1;
					}
				else
					{$air_t=999.9;}
				$gid2=substr($message,42,1);
				$sign2=substr($message,43,1);
				if($sign2 ne "/")
					{
					if($sign2==0){$sign2=1;}else{$sign2=-1;}
					 $dew_t=substr($message,44,3)/10*$sign2;
					}
				else
					{$dew_t=999.9;}

				$gid4=substr($message,48,1);
				$press=substr($message,49,4)/10;
				if ($press ne  "//")
					{
					if($press<500){$press=$press+1000;}
					}
				else	{$press=999.9;}

				$gid5=substr($message,54,1);
				$press_dir=substr($message,55,1);
				if ($press_dir ne  "//")
					{$press_ch=substr($message,56,3)/10;
					}
				else	{$press_dir=9;
					 $press_ch=999.9;}

				$gid00=substr($message0,0,1);
				$sign00=substr($message0,1,1);
				if($sign00 ne "/")
					{if($sign00==0){$sign00=1;}else{$sign00=-1;}
					 $sea_t=substr($message0,2,3)/10*$sign00;
					}
				else
					{$sea_t=999.9;}

				$gid01=substr($message0,6,1);
				$wave_p=substr($message0,7,2);
				if ($wave_p ne  "//")
					{$wave_h=substr($message0,9,2)*0.5;
					}
				else	{$wave_p=99;
					$wave_h=999.9}

				$gid070=substr($message0,12,2);
				$wave_height=substr($message0,14,3);
				if ($wave_height ne  "///")
					{$wave_height=$wave_height/10;
					}
				else	{$wave_height=99.9;}

				$wind_gust=999;
				if ((substr($message0,18,3)==333) and (substr($message0,22,1)==9) and ((substr($message0,28,3)==910) or (substr($message0,28,3)==911)) )
					{$wind_gust=substr($message0,31,2);
					 if (($wind_gust==99) and (substr($message0,28,3)==911))
						{$wind_gust=100+substr($message0,31,2);
						}
					}
				#
				if (($gid1==1)&($gid2==2)&($gid4==4)&($gid5==5)&($gid00==0)&($gid01==1)&($gid070==70))
					{
#					print ("MESS2 $mess_dom, $mess_hour, $wind_dir, $wind_speed, $wave_p, $wave_h \n");

# find time
 					$mess_mon=@now[4];
 					$rec_date_year=$nowyear;
 					if ($mess_dom > @now[3])
                                        	{ if (@now[4]==0)
                                        	       {$mess_mon=11;
                                        	        $rec_date_year=$rec_date_year-1;}
                                        	  else {$mess_mon=@now[4]-1;}
                                        	}
				        $rec_time=timegm(0,$mess_hour,0,$mess_dom,$mess_mon,@now[5]);
					$rec_date_time=sprintf("%04u-%02u-%02u  %02u:%02u:%02u",$rec_date_year,$mess_mon+1,$mess_dom,$mess_hour,0,0);

					$sqlsel="SELECT *  FROM ".$mooring."_met WHERE Date_Time = '".$rec_date_time."'";

#					print("$sqlsel\n");
					$sel = $dbh->prepare($sqlsel);
					$sel->execute();
			#		|| die "Update $sql failed";

					@rowh=$sel->fetchrow_array();
					unless (@rowh)
						{
						$sql="INSERT INTO ".$mooring."_met SET Date_Time='".$rec_date_time."'";
						$ins = $dbh->prepare($sql);
						$ins->execute()  || die "insert $sql failed";
						print ("INSERT\n");
						}

					$sqlupd="UPDATE ".$mooring."_met SET  sea_temp='".$sea_t."', ";
					$sqlupd.="wind_dir='".$wind_dir."',";
					$sqlupd.="wind_speed='".$wind_speed."',";
					$sqlupd.="wave_period='".$wave_p."',";
					$sqlupd.="wave_ht='".$wave_h."',";
					$sqlupd.="air_temp='".$air_t."',";
					$sqlupd.="dew_temp='".$dew_t."',";
					$sqlupd.="air_press='".$press."',";
					$sqlupd.="press_dir='".$press_dir."',";
					$sqlupd.="press_ch='".$press_ch."',";
					$sqlupd.="wave_height='".$wave_height."',";
					if ($wind_gust<999) {$sqlupd.="wind_gust='".$wind_gust."',";}
					$sqlupd.="met_lat='".$met_lat."',";
					$sqlupd.="met_lon='".$met_lon."',";
					$sqlupd.=" add_dat='".$nowdate."' ";
					$sqlupd.=" where Date_Time = '".$rec_date_time."'";
		#			print ("METsql $sqlupd \n");
					$ins = $dbh->prepare($sqlupd);
					$ins->execute()|| die "Update $sql failed";
					printf DATAOUT "$rec_date_time,$sea_t,$wind_dir,$wind_speed,$wave_p,$wave_h,$air_t,$dew_t,$press,$press_dir,$press_ch,$wave_height,$wind_gust:::$gid1:$gid2:$gid4:$gid5:$gid00:$gid01:$gid070\n";
					printf RAWOUT "$file_1$file_2$message$message0";

					} # identifiers not as expected
					else
					{
						$wave_p=99;
						$wave_h=999.9;
						$wave_height=99.9;

						$wind_gust=999;
					if (substr($message0,6,3)==333)
						{
						if ( (substr($message0,10,1)==9) and ((substr($message0,16,3)==910) or (substr($message0,16,3)==911)) )
							{$wind_gust=substr($message0,19,2);
					 		if (($wind_gust==99) and (substr($message0,16,3)==911))
								{$wind_gust=100+substr($message0,19,2);}
							}
						} #333
						print ("MESS333 $mess_dom, $mess_hour, $wind_dir, $wind_speed, $wave_p, $wave_h, $wind_gust \n");

	# find time
	 					$mess_mon=@now[4];
	 					$rec_date_year=$nowyear;
	 					if ($mess_dom > @now[3])
	                                        	{ if (@now[4]==0)
	                                        	       {$mess_mon=11;
	                                        	       $rec_date_year=$rec_date_year-1;}
	                                        	  else {$mess_mon=@now[4]-1;}
	                                        	}
					        $rec_time=timegm(0,$mess_hour,0,$mess_dom,$mess_mon,@now[5]);
						$rec_date_time=sprintf("%04u-%02u-%02u  %02u:%02u:%02u",$rec_date_year,$mess_mon+1,$mess_dom,$mess_hour,0,0);

						$sqlsel="SELECT *  FROM ".$mooring."_met WHERE Date_Time = '".$rec_date_time."'";

	#					print("$sqlsel\n");
						$sel = $dbh->prepare($sqlsel);
						$sel->execute();
				#		|| die "Update $sql failed";

						@rowh=$sel->fetchrow_array();
						unless (@rowh)
							{
							$sql="INSERT INTO ".$mooring."_met SET Date_Time='".$rec_date_time."'";
							$ins = $dbh->prepare($sql);
							$ins->execute()  || die "insert $sql failed";
							print ("INSERT\n");
							}

						$sqlupd="UPDATE ".$mooring."_met SET  sea_temp='".$sea_t."', ";
						$sqlupd.="wind_dir='".$wind_dir."',";
						$sqlupd.="wind_speed='".$wind_speed."',";
						$sqlupd.="wave_period='".$wave_p."',";
						$sqlupd.="wave_ht='".$wave_h."',";
						$sqlupd.="air_temp='".$air_t."',";
						$sqlupd.="dew_temp='".$dew_t."',";
						$sqlupd.="air_press='".$press."',";
						$sqlupd.="press_dir='".$press_dir."',";
						$sqlupd.="press_ch='".$press_ch."',";
						$sqlupd.="wave_height='".$wave_height."',";
						if ($wind_gust<999) {$sqlupd.="wind_gust='".$wind_gust."',";}
						$sqlupd.="met_lat='".$met_lat."',";
						$sqlupd.="met_lon='".$met_lon."',";
						$sqlupd.=" add_dat='".$nowdate."' ";
						$sqlupd.=" where Date_Time = '".$rec_date_time."'";
			#			print ("METsql $sqlupd \n");
						$ins = $dbh->prepare($sqlupd);
						$ins->execute()|| die "Update $sql failed";
						printf DATAOUT "$rec_date_time,$sea_t,$wind_dir,$wind_speed,$wave_p,$wave_h,$air_t,$dew_t,$press,$press_dir,$press_ch,$wave_height,$wind_gust:::$gid1:$gid2:$gid4:$gid5:$gid00:$gid01:$gid070\n";
						printf RAWOUT "$file_1$file_2$message$message0";
						}

				}  #end of $mstart=62442
				$message="";
				$message0="";
				}

			}
		close FILEIN;
		}
	}

close DATAOUT;
close RAWOUT;
print "end of run";

