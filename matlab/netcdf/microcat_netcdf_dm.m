
startdate2=datestr(datenum(startdate),29);

if isempty(enddate) 
	enddate=date; 
	enddate2=datestr(datenum(enddate),29);
	enddate='current';
else 	
	enddate2=datestr(datenum(enddate),29);
end;

[szr szc]=size(mooring);
mooring2=mooring(1,2:szc);

mysql('open','mysql','help','help9','soc');



d1970=datenum('01-01-1970');
DateTime=(TIME-d1970).*86400;


DIR=strcat('/data/ncs/www/animate/data/',lcmooring3);
cd(DIR);

% create netcdf file
nc=netcdf(strcat(mooring2,'_',startdate,'_to_',enddate,'.nc'),'clobber');
if isempty(nc),error('## Bad netcdf operation'),end;
close(nc);
nc=netcdf(strcat(mooring2,'_',startdate,'_to_',enddate,'.nc'),'write');
result=redef(nc);
if isempty(result), error('## Bad redef operation'), end;
nc.description=['File of temperature, conductivity and pressure data collected at',mooring,' mooring ',' at ',num2str(lat),' Degrees N ',num2str(long),' Degrees W',' Deployment between ',startdate,' and ',enddate];
l0='ANIMATE Atlantic Network of Interdisciplinary Moorings and Time-series for Europe EU Project EVR1-CT-2001-40014.';
nc.source=l0;
nc.creation_date=datestr(now);

nc('DateTime')=sz(1);
nc('Depth')=nvar;
nc('Depthx')=1;
nc('Latitude')=1;
nc('Longitude')=1;

nc{'DateTime'}='DateTime';
nc{'Depth'}=ncfloat('Depth');
nc{'Depthx'}=ncfloat('Depthx');
nc{'Latitude'}=ncfloat('Latitude');
nc{'Longitude'}=ncfloat('Longitude');

nc{'TEMP'}=ncfloat({'DateTime','Depth','Latitude','Longitude'});
nc{'Conductivity'}=ncfloat({'DateTime','Depth','Latitude','Longitude'});
nc{'PRES'}=ncfloat({'DateTime','Depth','Latitude','Longitude'});
nc{'PSAL'}=ncfloat({'DateTime','Depth','Latitude','Longitude'});
nc{'QC_TEMP'}=ncint({'DateTime','Depth','Latitude','Longitude'});
nc{'QC_Conductivity'}=ncint({'DateTime','Depth','Latitude','Longitude'});
nc{'QC_PRES'}=ncint({'DateTime','Depth','Latitude','Longitude'});
nc{'QC_PSAL'}=ncint({'DateTime','Depth','Latitude','Longitude'});

nc{'DateTime'}(:)=DateTime;
nc{'Depth'}(:)=v;
nc{'Latitude'}(1)=lat;
nc{'Longitude'}(1)=long;

for j=1:nvar;
	if (Pvar(j) == 1)
	nc{'Depthx'}(1)=v(j);
	nc{['PRES' int2str(v(j))]}={'DateTime','Depthx','Latitude','Longitude'};
	nc{['PRES' int2str(v(j))]}(:)=P(:,j);
	nc{['PRES' int2str(v(j))]}.units='dbar';
	nc{['PRES' int2str(v(j))]}.long_name='Pressure';
	nc{['PRES' int2str(v(j))]}.missing_value= 9999.99;
	nc{['QC_PRES' int2str(v(j))]}={'DateTime','Depthx','Latitude','Longitude'};
	nc{['QC_PRES' int2str(v(j))]}(:)=P(:,j);
	nc{['QC_PRES' int2str(v(j))]}.units='dbar';
	nc{['QC_PRES' int2str(v(j))]}.long_name='Pressure';
	nc{['QC_PRES' int2str(v(j))]}.missing_value= 9999.99;
	end;
end;


nc{'Depthx'}(1)=0;
nc{'TEMP'}(:)=T;
nc{'Conductivity'}(:)=C;
nc{'PRES'}(:)=P;
nc{'PSAL'}(:)=S;
nc{'QC_TEMP'}(:)=TQ;
nc{'QC_Conductivity'}(:)=CQ;
nc{'QC_PRES'}(:)=PQ;
nc{'QC_PSAL'}(:)=SQ;


nc{'DateTime'}.description='Date and Time from Matlab';
nc{'DateTime'}.long_name = 'Date and Time' ;
nc{'DateTime'}.units = 'seconds since 1970-01-01 00:00:00' ;
nc{'DateTime'}.epic_code=ncint(601);
nc{'Depth'}.epic_code=ncint(1);
nc{'Depth'}.units='dbar';
nc{'Depth'}.long_name='Depth';
nc{'Latitude'}.units = 'degree_north';
nc{'Latitude'}.epic_code = ncint(500);
nc{'Latitude'}.long_name='Latitude';
nc{'Longitude'}.units = 'degree_west';
nc{'Longitude'}.epic_code = ncint(501);
nc{'Longitude'}.long_name='Longitude';

nc{'TEMP'}.units='C';
nc{'TEMP'}.epic_code=ncint(20);
nc{'TEMP'}.description=['Degrees Celcius at nominal depths of ' int2str(v) ' metres'];
nc{'TEMP'}.missing_value= 999.999;
nc{'TEMP'}.valid_min= 2.0;
nc{'TEMP'}.valid_max= 100.0;
nc{'TEMP'}.long_name='Temperature';
nc{'QC_TEMP'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_TEMP'}.missing_value= 9;
nc{'QC_TEMP'}.valid_min= 0;
nc{'QC_TEMP'}.valid_max= 9;
nc{'QC_TEMP'}.long_name='Quality Marker for Temperature';

nc{'Conductivity'}.units='mS/cm';
nc{'Conductivity'}.epic_code=ncint(50);
nc{'Conductivity'}.long_name='Conductivity';
nc{'Conductivity'}.description=['Conductivity (mS/cm) at nominal depths of ' int2str(v) 'metres'];
nc{'Conductivity'}.missing_value= 999.999;
nc{'Conductivity'}.valid_min= 25.0;
nc{'Conductivity'}.valid_max= 45.0;
nc{'QC_Conductivity'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_Conductivity'}.missing_value= 9;
nc{'QC_Conductivity'}.valid_min= 0;
nc{'QC_Conductivity'}.valid_max= 9;
nc{'QC_Conductivity'}.long_name='Quality Marker for Conductivity';

nc{'PRES'}.units='dbar';
nc{'PRES'}.epic_code=ncint(1);
nc{'PRES'}.long_name='PRES';
nc{'PRES'}.description=['PRES (dbar) at nominal depths of ' int2str(v) 'metres'];
nc{'PRES'}.missing_value= 9999.99;
nc{'PRES'}.valid_min= 0.0;
nc{'PRES'}.valid_max= 1200.0;
nc{'QC_PRES'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PRES'}.missing_value= 9;
nc{'QC_PRES'}.valid_min= 0;
nc{'QC_PRES'}.valid_max= 9;
nc{'QC_PRES'}.long_name='Quality Marker for Pressure';

nc{'PSAL'}.units='PSU';
nc{'PSAL'}.epic_code=ncint(41);
nc{'PSAL'}.long_name='PSAL';
nc{'PSAL'}.description=['Practical PSAL Units at nominal depths of ' int2str(v) 'metres'];
nc{'PSAL'}.missing_value= 999.999
nc{'PSAL'}.valid_min= 29.0;
nc{'PSAL'}.valid_max= 40.0;
nc{'QC_PSAL'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PSAL'}.missing_value= 9;
nc{'QC_PSAL'}.valid_min= 0;
nc{'QC_PSAL'}.valid_max= 9;
nc{'QC_PSAL'}.long_name='Quality Marker for Practical Salinity';
close(nc);

% create space and comma delimited file
[yyyyx monx ddx hh mm ss]=datevec(TIME);


W=[yyyyx monx ddx hh mm ss T TQ C CQ P PQ S SQ] ;

dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'.csv'),W,',');

l1=['File of temperature, conductivity and pressure data collected at' mooring ' mooring '];
l2=['at ' num2str(lat) ' Degrees N ' num2str(long) ' Degrees W' ' Deployment between ' startdate ' and ' enddate];
l2a=['Created on ' datestr(date)];
l3='The data in this file are :- ';
l4='year';
l5='month';
l6='day';
l7='hour';
l8='minute';
l9='second';
l10=['temperatures (Celcius)1 to ' int2str(nvar)];
l10a=['temperature quality 1 to ' int2str(nvar)];
l11=['conductivities (mS/cm)1 to ' int2str(nvar)];
l11a=['conductivity quality 1 to ' int2str(nvar)];
l12=['pressures (dbar) 1 to ' int2str(nvar)];
l12a=['pressure quality 1 to ' int2str(nvar)];
l13=['salinities (PSU) 1 to ' int2str(nvar)];
l13a=['salinity quality 1 to ' int2str(nvar)];
l14=' ';
l15=['data were measured at ' int2str(nvar) ' sensors at the nominal depths of ' int2str(v) ' metres.'];
l15a=' ';
l16='Quality Indicators are :- ';
l17='  0        No Quality Control';
l18='  1        Correct';
l19='  2        Inconsistent';
l20='  3        Doubtful';
l21='  4        Bad';
l22='  5        Changed';
l22a='  8        Profile Interpolated at standard depth';
l23='  9        Missing';

txt=strvcat(l0,l1,l2,l2a,l3,l4,l5,l6,l7,l8,l9,l10,l10a,l11,l11a,l12,l12a,l13,l13a,l14,l15,l15a,l16,l17,l18,l19,l20,l21,l22,l22a,l23);

dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'_readme.txt'),txt,'');



