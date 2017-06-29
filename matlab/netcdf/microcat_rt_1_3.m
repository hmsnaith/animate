function microcat_rt_1_3(site,dep,dat,v)

microcat_type; % oct 2010
sensor_type=mc_sensor_type;
[rows,cols]=size(T);
%	



%multiplier=3.29;
%for j=1:nvar;
% range by std does not work for temperature
%	iii=find(TQ(:,j)<2);
%	Tmn(j)=mean(T(iii,j));
%	Tstd(j)=std(T(iii,j));
%	kkk=find(abs(T(iii,j)-Tmn(j)) > (multiplier*Tstd(j)) ) ;
%	TQ(kkk,j)=3;
%        clear kkk;
%	clear iii;
%	iii=find(SQ(:,j)<2);
%	Smn(j)=mean(S(iii,j));
%	Sstd(j)=std(S(iii,j));
%	kkk=find(S(iii,j) < 35);
%	SQ(kkk,j)=3;
%	clear kkk;
%	clear iii;
%end;

startdate2=datestr(DateTime(1,1),29);
if isempty(enddate) 
	enddate2=date;
%	enddate='latest';  removed 20090615
else 	
	enddate2=datestr(DateTime(rows,1),29);
end;
startdate=startdate(1:11);
d1970=datenum('01-01-1970');
d1950=datenum('01-01-1950');
%DateTime_nc=(DateTime-d1970).*86400;
DateTime_nc=(DateTime-d1950);

DIR=cdout_os;

% create netcdf file
if ((stype(1) >= 10) & (stype(1) <= 11))  %has oxygen
      disp 'entering make_microcat_sbo_netcdf_v1_3'
   make_microcat_sbo_netcdf_v1_3;
else
if os_format_version=='1.2'
      disp 'entering make_microcat_netcdf_v1_2'
   make_microcat_netcdf_v1_2;
elseif os_format_version=='1.3'
      disp 'entering make_microcat_netcdf_v1_3 native'
      make_microcat_netcdf_v1_3;
   else
      disp 'entering make_microcat_netcdf'
      make_microcat_netcdf;
end
end
DIR=cdout;
cd(DIR);
%% create space and comma delimited file
[yyyy,mon,day,hh,mm,ss]=datevec(DateTime);
clear kkk;
kkk=find(ss>=59.55);
DateTime(kkk,1)=DateTime(kkk,1)+(0.5/(24*60*60));
[yyyy,mon,day,hh,mm,ss]=datevec(DateTime(:,1));
clear kkk;
kkk=find(ss < 1);
ss(kkk)=0;

if (mode == 'R') & ((now-enddate_num)<30)
	enddate='latest';
else
	enddate=datestr(enddate_num,1);
end
if ((stype(1) >= 10) & (stype(1) <= 11))  %has oxygen
	W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ Ox OxQ] ;
else
	W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ] ;
end
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

DIR=cdout1;
cd(DIR);

dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_mooring',mooring_no,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');


[z1,z2]=size(OS_name);

dlmwrite(strcat(cdout_os,OS_name(1:z2-3),'_metadata_form.txt'),gdac_metadata,'');

