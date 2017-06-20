
startdate2=datestr(datenum(startdate),29);
if isempty(enddate) 
	enddate=date; 
	enddate2=datestr(datenum(enddate),29);
	enddate='current';
else 	
	enddate2=datestr(datenum(enddate),29);
end;

d1970=datenum('01-01-1970');
DateTime=(DateTime-d1970).*86400;


DIR=strcat('/users/itg/animate/animate_data/',mooringlc,'/',deploy,'/microcat/');

% create netcdf file
cd /users/itg/animate/netcdf/microcat;
make_microcat_netcdf;

% create space and comma delimited file
[yyyy,mon,day,hh,mm,ss]=datevec(DateTime);

W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ] ;

dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

DIR=strcat('/data/ncs/pubread/animate/',mooringlc,'/',deploy,'/microcat');
cd(DIR);

%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'_readme.txt'),txt,'');
%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.asc'),W,' ');
%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.csv'),W,',');

%%%%% 2nd data set creation
