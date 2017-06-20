
startdate2=datestr(datenum(startdate),29);

if isempty(enddate) 
	enddate=date; 
	enddate2=datestr(datenum(enddate),29);
	enddate='current';
else 	
	enddate2=datestr(datenum(enddate),29);
end;


mysql('open','mysql','help','help9','soc');

DATA=mysql(sqlstr);
mysql close;
[rows,cols]=size(DATA);

T=zeros(rows,nvar);
C=zeros(rows,nvar);
P=zeros(rows,nvar);
S=zeros(rows,nvar);
TQ=zeros(rows,nvar);
CQ=zeros(rows,nvar);
PQ=zeros(rows,nvar);
SQ=zeros(rows,nvar);

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
    for j=1:nvar;
    	DateTime(i,j)=(datenum(ddd(1:19))-d1970)*86400;
        T(i,j)=getfield(DATA,{i,1},strcat('temp',int2str(v(j)) ) );
        AAAA=getfield(DATA,{i,1},strcat('temp',int2str(v(j)),'_qc' ) );
        if isempty(AAAA)
       	 TQ(i,j)=1;
       	else
       	 TQ(i,j)=AAAA;
        end;
       	 if (T(i,j)==22.222),T(i,j)=999.999;TQ(i,j)=9;,end;
        
        C(i,j)=getfield(DATA,{i,1},strcat('cond',int2str(v(j)) ) );
        AAAA=getfield(DATA,{i,1},strcat('cond',int2str(v(j)),'_qc' ) );
        if isempty(AAAA)        
          CQ(i,j)=1;
       	else
       	 CQ(i,j)=AAAA;
       	end;
       	  if(C(i,j)==22.222),C(i,j)=999.999;CQ(i,j)=9;,end;
       	  if(C(i,j)==5.000),C(i,j)=999.999;CQ(i,j)=9;,end;
       	  
       	  
% special code for PAP4 depth 152
	if Wvar(j)==-999;
	    P6_low=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_low'));
	    P6_high=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_high'));
	    P(i,j)=((256*P6_high)+P6_low)/10;
	    AAAA=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_low_qc'));
	    BBBB=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_high_qc'));
	    if isempty(AAAA) & isempty(BBBB)
	  	PQ(i,j)=1;
            else
	       	PQ(i,j)=9;
       	    end;
	 
        end;


        if (Wvar(j) == 0)
	    P(i,j)=getfield(DATA,{i,1},strcat('press',int2str(v(j)) ));
	   AAAA=getfield(DATA,{i,1},strcat('press',int2str(v(j)),'_qc' ));

	    if isempty(AAAA)
	  	PQ(i,j)=1;
            else
	       	PQ(i,j)=AAAA;
       	    end;
	 
       	    	if(P(i,j)==2222.2),P(i,j)=9999.99; PQ(i,j)=9;,end;

       end;   
    end;
    
end;

for i=1:rows;
	for j=1:nvar;

	    	if (Wvar(j) > 0)
	    	    k=Wvar(j);
	   	    if (PQ(i,k) < 9)
	  	  	P(i,j)=v(j) +  ( P(i,k)-v(k) );
	  	        PQ(i,j)=PQ(i,k);
	  	    else
	  	        P(i,j)=P(i,k);
	  	        PQ(i,j)=PQ(i,k);
	  	    end;	
	     	end;
    	
		if ((P(i,j)==9999.99) | (T(i,j)==999.999) | (C(i,j)==999.99))
			S(i,j)=999.999;
			SQ(i,j)=9;
		else 
			S(i,j)=salinity(P(i,j),T(i,j),C(i,j));
			SQ(i,j)=CQ(i,j);
		end; 

	end;

end;



if (P(1,1)==0) 
	P(1,:)=10; 
end;

DIR=strcat('/data/ncs/www/animate/data/',mooringlc);
cd(DIR);

% create netcdf file
addpath /users/itg/animate/animate_matlab/
make_microcat_netcdf;

% create space and comma delimited file
for  i = 1:rows;
    dat(1:19)=getfield(DATA,{i,1},'Date_Time');
    yyyy(i,1)=str2num([dat(1:4)]);
    mon(i,1)=str2num([dat(6:7)]);
    day(i,1)=str2num([dat(9:10)]);
    hh(i,1)=str2num([dat(12:13)]);
    mm(i,1)=str2num([dat(15:16)]);
    ss(i,1)=str2num([dat(18:19)]);
end;

W=[yyyy mon day hh mm ss T TQ C CQ P PQ S SQ] ;

dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.csv'),W,',');


dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');

DIR=strcat('/data/ncs/pubread/animate/',mooringlc,'/',deploy,'/microcat');
cd(DIR);

dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'_readme.txt'),readme_txt,'');
dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.asc'),W,' ');
dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.csv'),W,',');

% create netcdf file
cd /users/itg/animate/netcdf/microcat
make_microcat_netcdf;
