% create netcdf file
cd(DIR);
nc=netcdf(strcat(mooring,'_',startdate,'_to_',enddate,'.nc'),'clobber');
if isempty(nc),error('## Bad netcdf operation'),end;
close(nc);
nc=netcdf(strcat(mooring,'_',startdate,'_to_',enddate,'.nc'),'write');
result=redef(nc);
if isempty(result), error('## Bad redef operation'), end;
nc.description=['File of temperature, conductivity and pressure data collected at ',mooring,' mooring ',' at ',num2str(lat),' Degrees N ',num2str(long),' Degrees W',' Deployment between ',startdate,' and ',enddate];
l0='ANIMATE Atlantic Network of Interdisciplinary Moorings and Time-series for Europe EU Project EVR1-CT-2001-40014.';
nc.source=l0;
nc.creation_date=datestr(now);

nc('DateTime')=rows;
nc('Depth')=nvar;
nc('Depthx')=1;
nc('Latitude')=1;
nc('Longitude')=1;

nc{'DateTime'}=ncdouble('DateTime');
nc{'Depth'}=ncfloat('Depth');
nc{'Depthx'}=ncfloat('Depthx');
nc{'Latitude'}=ncfloat('Latitude');
nc{'Longitude'}=ncfloat('Longitude');

nc{'TEMP'}=ncfloat('DateTime','Depth','Latitude','Longitude');
nc{'CNDC'}=ncfloat('DateTime','Depth','Latitude','Longitude');
nc{'PRES'}=ncfloat('DateTime','Depth','Latitude','Longitude');
nc{'PSAL'}=ncfloat('DateTime','Depth','Latitude','Longitude');
nc{'QC_TEMP'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_CNDC'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_PRES'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_PSAL'}=ncint('DateTime','Depth','Latitude','Longitude');

nc{'DateTime'}(:)=DateTime(:,1);
nc{'Depth'}(:)=v(1,:)';
nc{'Latitude'}(1)=lat;
nc{'Longitude'}(1)=long;

for j=1:nvar;
	if (Wvar(j) < 1)
	nc{'Depthx'}(1)=v(j);
	nc{['PRES' int2str(v(j))]}=ncfloat('DateTime','Depthx','Latitude','Longitude');
	nc{['PRES' int2str(v(j))]}(:,1,1,1)=P(:,j);
	nc{['PRES' int2str(v(j))]}.long_name='pressure';
	nc{['PRES' int2str(v(j))]}.standard_name='sea_pressure';
	nc{['PRES' int2str(v(j))]}.units='dbar';
	nc{['PRES' int2str(v(j))]}.FillValue= ncfloat(99999);
	nc{['PRES' int2str(v(j))]}.valid_min= ncfloat(0);
	nc{['PRES' int2str(v(j))]}.valid_max= ncfloat(2000);
	nc{['PRES' int2str(v(j))]}.missing_value= ncfloat(99999);

	nc{['QC_PRES' int2str(v(j))]}=ncint('DateTime','Depthx','Latitude','Longitude');
	nc{['QC_PRES' int2str(v(j))]}(:,1,1,1)=PQ(:,j);
	nc{['QC_PRES' int2str(v(j))]}.long_name=['Quality Marker for nominal depth of ' int2str(v(j)) ' metres'];
	nc{['QC_PRES' int2str(v(j))]}.units='dbar';
	nc{['QC_PRES' int2str(v(j))]}.FillValue= ncint(9);
	nc{['QC_PRES' int2str(v(j))]}.valid_min= ncint(0);
	nc{['QC_PRES' int2str(v(j))]}.valid_max= ncint(9);
	nc{['QC_PRES' int2str(v(j))]}.missing_value= ncint(9);
	end;
end;

nc{'Depthx'}(1)=0;
nc{'TEMP'}(:,:,1,1)=T;
nc{'CNDC'}(:,:,1,1)=C;
nc{'PRES'}(:,:,1,1)=P;
nc{'PSAL'}(:,:,1,1)=S;
nc{'QC_TEMP'}(:,:,1,1)=TQ;
nc{'QC_CNDC'}(:,:,1,1)=CQ;
nc{'QC_PRES'}(:,:,1,1)=PQ;
nc{'QC_PSAL'}(:,:,1,1)=SQ;


nc{'DateTime'}.description='Date and Time from Matlab';
nc{'DateTime'}.long_name = 'Date and Time' ;
nc{'DateTime'}.standard_name = 'time' ;
nc{'DateTime'}.units = 'seconds since 1970-01-01 00:00:00' ;
nc{'DateTime'}.epic_code=ncint(601);
nc{'DateTime'}.FillValue=ncfloat(999999) ;
nc{'DateTime'}.axis='t' ;

nc{'Depth'}.long_name='Depth of each measurement';
nc{'Depth'}.standard_name='depth';
nc{'Depth'}.units='meter';
nc{'Depth'}.positive='down';
nc{'Depth'}.axis='z';
nc{'Depth'}.FillValue = ncfloat(99999);
nc{'Depth'}.valid_min=ncfloat(0);
nc{'Depth'}.valid_max=ncfloat(12000);


nc{'Latitude'}.units = 'degree_north';
nc{'Latitude'}.epic_code = ncint(500);
nc{'Latitude'}.long_name='latitude of each location';
nc{'Latitude'}.standard_name='latitude';
nc{'Latitude'}.FillValue = ncfloat(99999);
nc{'Latitude'}.valid_min=ncfloat(-90);
nc{'Latitude'}.valid_max=ncfloat(90);

nc{'Longitude'}.units = 'degree_west';
nc{'Longitude'}.epic_code = ncint(501);
nc{'Longitude'}.long_name='longitude of each location';
nc{'Longitude'}.standard_name='longitude';
nc{'Longitude'}.FillValue = ncfloat(99999);
nc{'Longitude'}.valid_min=ncfloat(-180);
nc{'Longitude'}.valid_max=ncfloat(180);

nc{'TEMP'}.long_name='Temperature';
nc{'TEMP'}.standard_name='sea_temperature';
nc{'TEMP'}.units='degree_Celsius';
nc{'TEMP'}.FillValue= ncfloat(99999);
nc{'TEMP'}.valid_min= ncfloat(2.0);
nc{'TEMP'}.valid_max= ncfloat(100.0);
nc{'TEMP'}.epic_code=ncint(20);
nc{'TEMP'}.description=['Degrees Celcius at nominal depths of ' int2str(v) ' metres'];
nc{'TEMP'}.missing_value= ncfloat(99999);
nc{'QC_TEMP'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_TEMP'}.missing_value= ncint(9);
nc{'QC_TEMP'}.FillValue= ncint(9);
nc{'QC_TEMP'}.valid_min= ncint(0);
nc{'QC_TEMP'}.valid_max= ncint(9);
nc{'QC_TEMP'}.long_name='Quality Marker for Temperature';

nc{'CNDC'}.units='mS/cm';
nc{'CNDC'}.epic_code=ncint(50);
nc{'CNDC'}.long_name='Conductivity';
nc{'CNDC'}.standard_name='electrical_conductivity';
nc{'CNDC'}.description=['Conductivity (mS/cm) at nominal depths of ' int2str(v) 'metres'];
nc{'CNDC'}.missing_value= ncfloat(99999);
nc{'CNDC'}.FillValue= ncfloat(99999);
nc{'CNDC'}.valid_min= ncfloat(25.0);
nc{'CNDC'}.valid_max= ncfloat(45.0);
nc{'QC_CNDC'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_CNDC'}.missing_value=ncint(9);
nc{'QC_CNDC'}.valid_min= ncint(0);
nc{'QC_CNDC'}.valid_max= ncint(9);
nc{'QC_CNDC'}.long_name='Quality Marker for Conductivity';

nc{'PRES'}.units='dbar';
nc{'PRES'}.epic_code=ncint(1);
nc{'PRES'}.long_name='PRES';
nc{'PRES'}.standard_name='sea_pressure';
nc{'PRES'}.description=['PRES (dbar) at nominal depths of ' int2str(v) 'metres'];
nc{'PRES'}.missing_value= ncfloat(99999);
nc{'PRES'}.FillValue= ncfloat(99999);
nc{'PRES'}.valid_min= ncfloat(0.0);
nc{'PRES'}.valid_max= ncfloat(12000);
nc{'QC_PRES'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PRES'}.missing_value=ncint(9);
nc{'QC_PRES'}.valid_min= ncint(0);
nc{'QC_PRES'}.valid_max= ncint(9);
nc{'QC_PRES'}.long_name='Quality Marker for Pressure';

nc{'PSAL'}.units='PSU';
nc{'PSAL'}.epic_code=ncint(41);
nc{'PSAL'}.long_name='Practical Salinity';
nc{'PSAL'}.standard_name='practical_salinity';
nc{'PSAL'}.description=['Practical PSAL Units at nominal depths of ' int2str(v) 'metres'];
nc{'PSAL'}.missing_value= ncfloat(99999);
nc{'PSAL'}.FillValue= ncfloat(99999);
nc{'PSAL'}.valid_min= ncfloat(29.0);
nc{'PSAL'}.valid_max= ncfloat(40.0);
nc{'QC_PSAL'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PSAL'}.missing_value=ncint(9);
nc{'QC_PSAL'}.FillValue= 9;
nc{'QC_PSAL'}.valid_min= ncint(0);
nc{'QC_PSAL'}.valid_max= ncint(9);
nc{'QC_PSAL'}.long_name='Quality Marker for Practical Salinity';
close(nc);
