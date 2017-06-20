
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

DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);

T=zeros(nvar,rows);
C=zeros(nvar,rows);
P=zeros(nvar,rows);
S=zeros(nvar,rows);
TQ=zeros(nvar,rows);
CQ=zeros(nvar,rows);
PQ=zeros(nvar,rows);
SQ=zeros(nvar,rows);

d1970=datenum('01-01-1970');
for  i = 1:rows;
    dat(1:19)=getfield(DATA,{i,1},'Date_Time');
    ddd(1)=dat(6);
    ddd(2)=dat(7);
    ddd(3)=dat(8);
    ddd(4)=dat(9);
    ddd(5)=dat(10);    
    ddd(6)=dat(5);
    ddd(7)=dat(1);
    ddd(8)=dat(2);
    ddd(9)=dat(3);
    ddd(10)=dat(4);
    ddd(11:19)=dat(11:19);
    DateTime(i)=(datenum(ddd(1:19))-d1970)*86400;
    for j=1:nvar;
        T(j,i)=getfield(DATA,{i,1},strcat('temp',int2str(v(j)) ) );
        AAAA=getfield(DATA,{i,1},strcat('temp',int2str(v(j)),'_qc' ) );
        if isempty(AAAA)
       	 TQ(j,i)=1;
       	else
       	 TQ(j,i)=AAAA;
        end;
       	 if (T(j,i)==22.222),T(j,i)=999.999;TQ(j,i)=9;,end;
        
        C(j,i)=getfield(DATA,{i,1},strcat('cond',int2str(v(j)) ) );
        AAAA=getfield(DATA,{i,1},strcat('cond',int2str(v(j)),'_qc' ) );
        if isempty(AAAA)        
          CQ(j,i)=1;
       	else
       	 CQ(j,i)=AAAA;
       	end;
       	  if(C(j,i)==22.222),C(j,i)=999.999;CQ(j,i)=9;,end;
       	  if(C(j,i)==5.000),C(j,i)=999.999;CQ(j,i)=9;,end;
       	  
       	  
% special code for PAP4 depth 152
	if Wvar(j)==-999;
	    P6_low=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_low'));
	    P6_high=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_high'));
	    P(j,i)=((256*P6_high)+P6_low)/10;
	    AAAA=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_low_qc'));
	    BBBB=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_high_qc'));
	    if isempty(AAAA) & isempty(BBBB)
	  	PQ(j,i)=1;
            else
	       	PQ(j,i)=9;
       	    end;
	 
        end;


        if (Wvar(j) == 0)
	    P(j,i)=getfield(DATA,{i,1},strcat('press',int2str(v(j)) ));
	   AAAA=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_qc' ));

	    if isempty(AAAA)
	  	PQ(j,i)=1;
            else
	       	PQ(j,i)=AAAA;
       	    end;
	 
       	    	if(P(j,i)==2222.2),P(j,i)=9999.99; PQ(j,i)=9;,end;

       end;   
    end;
    
end;

for i=1:rows;
	for j=1:nvar;

	    	if (Wvar(j) > 0)
	    	    k=Wvar(j);
	   	    if (PQ(k,i) < 9)
	  	  	P(j,i)=v(j) +  ( P(k,i)-v(k) );
	  	        PQ(j,i)=PQ(k,i);
	  	    else
	  	        P(j,i)=P(k,i);
	  	        PQ(j,i)=PQ(k,i);
	  	    end;	
	     	end;
    	
		if ((P(j,i)==9999.99) | (T(j,i)==999.999) | (C(j,i)==999.99))
			S(j,i)=999.999;
			SQ(j,i)=9;
		else 
			S(j,i)=salinity(P(j,i),T(j,i),C(j,i));
			SQ(j,i)=CQ(j,i);
		end; 

	end;

end;



if (P(1,1)==0) 
	P(1,:)=10; 
end;

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

nc{'TEMP'}=ncdouble('DateTime','Depth','Latitude','Longitude');
nc{'CNDC'}=ncdouble('DateTime','Depth','Latitude','Longitude');
nc{'PRES'}=ncdouble('DateTime','Depth','Latitude','Longitude');
nc{'PSAL'}=ncdouble('DateTime','Depth','Latitude','Longitude');
nc{'QC_TEMP'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_CNDC'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_PRES'}=ncint('DateTime','Depth','Latitude','Longitude');
nc{'QC_PSAL'}=ncint('DateTime','Depth','Latitude','Longitude');

nc{'DateTime'}(:)=DateTime;
nc{'Depth'}(:)=v;
nc{'Latitude'}(1)=lat;
nc{'Longitude'}(1)=long;

for j=1:nvar;
	if (Wvar(j) < 1)
	nc{'Depthx'}(1)=v(j);
	nc{['PRES' int2str(v(j))]}=ncfloat('DateTime','Depthx','Latitude','Longitude');
	nc{['PRES' int2str(v(j))]}(:,1,1,1)=P(j,:);
	nc{['PRES' int2str(v(j))]}.long_name='pressure';
	nc{['PRES' int2str(v(j))]}.standard_name='sea_pressure';
	nc{['PRES' int2str(v(j))]}.units='dbar';
	nc{['PRES' int2str(v(j))]}.FillValue= 99999.;
	nc{['PRES' int2str(v(j))]}.valid_min= 0.;
	nc{['PRES' int2str(v(j))]}.valid_max= 9999.;
	nc{['PRES' int2str(v(j))]}.missing_value= 99999.;

	nc{['QC_PRES' int2str(v(j))]}=ncint('DateTime','Depthx','Latitude','Longitude');
	nc{['QC_PRES' int2str(v(j))]}(:,1,1,1)=PQ(j,:);
	nc{['QC_PRES' int2str(v(j))]}.long_name=['Quality Marker for nominal depth of ' int2str(v(j)) ' metres'];
	nc{['QC_PRES' int2str(v(j))]}.units='dbar';
	nc{['QC_PRES' int2str(v(j))]}.FillValue= 9;
	nc{['QC_PRES' int2str(v(j))]}.valid_min= 0;
	nc{['QC_PRES' int2str(v(j))]}.valid_max= 9;
	nc{['QC_PRES' int2str(v(j))]}.missing_value= 9;
	end;
end;


nc{'Depthx'}(1)=0;
nc{'TEMP'}(:,:,1,1)=T';
nc{'CNDC'}(:,:,1,1)=C';
nc{'PRES'}(:,:,1,1)=P';
nc{'PSAL'}(:,:,1,1)=S';
nc{'QC_TEMP'}(:,:,1,1)=TQ';
nc{'QC_CNDC'}(:,:,1,1)=CQ';
nc{'QC_PRES'}(:,:,1,1)=PQ';
nc{'QC_PSAL'}(:,:,1,1)=SQ';


nc{'DateTime'}.description='Date and Time from Matlab';
nc{'DateTime'}.long_name = 'Date and Time' ;
nc{'DateTime'}.standard_name = 'time' ;
nc{'DateTime'}.units = 'seconds since 1970-01-01 00:00:00' ;
nc{'DateTime'}.epic_code=ncint(601);
nc{'DateTime'}.FillValue=999999. ;

nc{'Depth'}.epic_code=ncint(1);
nc{'Depth'}.units='dbar';
nc{'Depth'}.long_name='Depth';

nc{'Latitude'}.units = 'degree_north';
nc{'Latitude'}.epic_code = ncint(500);
nc{'Latitude'}.long_name='latitude of measurements';
nc{'Latitude'}.standard_name='latitude';
nc{'Latitude'}.FillValue = 99999.;
nc{'Latitude'}.valid_min=-90.;
nc{'Latitude'}.valid_max=90.;

nc{'Longitude'}.units = 'degree_west';
nc{'Longitude'}.epic_code = ncint(501);
nc{'Longitude'}.long_name='longitude of measurements';
nc{'Longitude'}.standard_name='longitude';
nc{'Longitude'}.FillValue = 99999.;
nc{'Longitude'}.valid_min=-180.;
nc{'Longitude'}.valid_max=180.;

nc{'TEMP'}.units='degree_Celsius';
nc{'TEMP'}.epic_code=ncint(20);
nc{'TEMP'}.description=['Degrees Celcius at nominal depths of ' int2str(v) ' metres'];
nc{'TEMP'}.missing_value= 99999;
nc{'TEMP'}.FillValue= 99999;
nc{'TEMP'}.valid_min= 2.0;
nc{'TEMP'}.valid_max= 100.0;
nc{'TEMP'}.long_name='Temperature';
nc{'TEMP'}.standard_name='sea_temperature';
nc{'QC_TEMP'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_TEMP'}.missing_value= 9;
nc{'QC_TEMP'}.FillValue= 9;
nc{'QC_TEMP'}.valid_min= 0;
nc{'QC_TEMP'}.valid_max= 9;
nc{'QC_TEMP'}.long_name='Quality Marker for Temperature';

nc{'CNDC'}.units='mS/cm';
nc{'CNDC'}.epic_code=ncint(50);
nc{'CNDC'}.long_name='Conductivity';
nc{'CNDC'}.standard_name='electrical_conductivity';
nc{'CNDC'}.description=['Conductivity (mS/cm) at nominal depths of ' int2str(v) 'metres'];
nc{'CNDC'}.missing_value= 999.999;
nc{'CNDC'}.FillValue= 999.999;
nc{'CNDC'}.valid_min= 25.0;
nc{'CNDC'}.valid_max= 45.0;
nc{'QC_CNDC'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_CNDC'}.missing_value= 9;
nc{'QC_CNDC'}.valid_min= 0;
nc{'QC_CNDC'}.valid_max= 9;
nc{'QC_CNDC'}.long_name='Quality Marker for Conductivity';

nc{'PRES'}.units='dbar';
nc{'PRES'}.epic_code=ncint(1);
nc{'PRES'}.long_name='PRES';
nc{'PRES'}.standard_name='sea_pressure';
nc{'PRES'}.description=['PRES (dbar) at nominal depths of ' int2str(v) 'metres'];
nc{'PRES'}.missing_value= 9999.99;
nc{'PRES'}.FillValue= 9999.99;
nc{'PRES'}.valid_min= 0.0;
nc{'PRES'}.valid_max= 1200.0;
nc{'QC_PRES'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PRES'}.missing_value= 9;
nc{'QC_PRES'}.valid_min= 0;
nc{'QC_PRES'}.valid_max= 9;
nc{'QC_PRES'}.long_name='Quality Marker for Pressure';

nc{'PSAL'}.units='PSU';
nc{'PSAL'}.epic_code=ncint(41);
nc{'PSAL'}.long_name='Practical Salinity';
nc{'PSAL'}.standard_name='practical_salinity';
nc{'PSAL'}.description=['Practical PSAL Units at nominal depths of ' int2str(v) 'metres'];
nc{'PSAL'}.missing_value= 999.999
nc{'PSAL'}.FillValue= 999.999
nc{'PSAL'}.valid_min= 29.0;
nc{'PSAL'}.valid_max= 40.0;
nc{'QC_PSAL'}.description=['Quality Marker for each nominal depth of ' int2str(v) ' metres'];
nc{'QC_PSAL'}.missing_value= 9;
nc{'QC_PSAL'}.FillValue= 9;
nc{'QC_PSAL'}.valid_min= 0;
nc{'QC_PSAL'}.valid_max= 9;
nc{'QC_PSAL'}.long_name='Quality Marker for Practical Salinity';
close(nc);

% create space and comma delimited file
for  i = 1:rows;
    dat(1:19)=getfield(DATA,{i,1},'Date_Time');
    yyyy(i)=str2num([dat(1:4)]);
    mon(i)=str2num([dat(6:7)]);
    day(i)=str2num([dat(9:10)]);
    hh(i)=str2num([dat(12:13)]);
    mm(i)=str2num([dat(15:16)]);
    ss(i)=str2num([dat(18:19)]);
end;

W=[yyyy' mon' day' hh' mm' ss' T' TQ' C' CQ' P' PQ' S' SQ'] ;

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

DIR=strcat('/data/ncs/pubread/animate/',lcmooring3,'/',deploy,'/microcat');
cd(DIR);

%dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'_readme.txt'),txt,'');
%dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'.asc'),W,' ');
%dlmwrite(strcat(mooring2,'_',startdate,'_to_',enddate,'.csv'),W,',');

%%%%% 2nd data set creation
