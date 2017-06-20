ncverbose;
nc=netcdf('aaaa.nc','clobber');

nc.description=['File of temperature, conductivity etc'];
nc.source='l0';
nc.creation_date=datestr(now);

nc('DateTime')=5;
nc('Depth')=2;
nc('Depthx')=1;
nc('Latitude')=1;
nc('Longitude')=1;
nc('strg4')=4;
nc('strg8')=8;
nc('strg32')=32;
nc('strg64')=64;
nc('strg256')=256;



nc{'DateTime'}=ncdouble('DateTime');
nc{'DateTime'}.units='seconds since 1970-01-01 00:00:00';
nc{'Depth'}=ncdouble('Depth');
nc{'Depth'}.units='meter';
nc{'Depthx'}=ncdouble('Depthx');
nc{'Depthx'}.units='meter';
nc{'Latitude'}=ncdouble('Latitude');
nc{'Latitude'}.units='degrees';
nc{'Longitude'}=ncdouble('Longitude');
nc{'Longitude'}.units='degrees';
nc{'vvvv'}=ncdouble('DateTime','Depth','Latitude','Longitude');
nc{'vvvv'}.units='degree_Celcius'
nc{'DATA_TYPE'}=ncchar('strg32');

nc{'DATA_TYPE'}.comment='Data type';
nc{'DATA_TYPE'}.FillValue_=ncchar('x');

str='OceanSites data                 ';
v=[1:5:50];
d=[1:5];
dep=[100,200];
depx=777;
la=500;
lo=501;


nc{'DATA_TYPE'}(:)=str;
nc{'vvvv'}(:,:,1,1)=v;
nc{'DateTime'}(:)=d;
nc{'Depth'}(:)=dep;
nc{'Depthx'}(1)=depx;
nc{'Latitude'}(1)=la;
nc{'Longitude'}(1)=lo;

res=close(nc);

nc=netcdf('aaaa.nc','nowrite');
vari=var(nc);
for i= 1:length(vari)
 disp( name(vari{i}) ) 
 disp( vari{i}(:) )
end

res=close(nc);

