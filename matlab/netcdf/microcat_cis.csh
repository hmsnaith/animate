#!/bin/csh
cd /users/itg/animate/netcdf;
setup matlab
setenv DISPLAY hyperion:0
matlab -nodesktop -nosplash <<FIN

pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/matlab',path);
toolbox_area = '/nerc/packages/satprogs/matlab';
path(path, fullfile( toolbox_area, 'netcdf', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'nctype', ''));
path(path, fullfile( toolbox_area, 'netcdf', 'ncutility', ''));
addpath /users/itg/animate/exec;
addpath /users/itg/animate/lib;

% NB 2253 was lost when telemetry buoy broke free.
nvar=11;
Pvar=zeros(1,nvar);


serial_no(1)=2253;	v(1)=10;  			skip(1)=47;
serial_no(2)=2262;	v(2)=37;  	Pvar(2)=1;	skip(2)=57;
serial_no(3)=2257;	v(3)=87;  			skip(3)=47;
serial_no(4)=2263;	v(4)=142; 	Pvar(4)=1;	skip(4)=58;
serial_no(5)=2256;	v(5)=221; 			skip(5)=48;
serial_no(6)=2252;	v(6)=302; 			skip(6)=47;	
serial_no(7)=2271;	v(7)=402;  	Pvar(7)=1;	skip(7)=57;
serial_no(8)=2255;	v(8)=552;			skip(8)=47;	
serial_no(9)=2264;	v(9)=702; 	Pvar(9)=1;	skip(9)=57;
serial_no(10)=2254;	v(10)=853;			skip(10)=47;
serial_no(11)=2265;	v(11)=1002; 	Pvar(11)=1;	skip(11)=57;
mooring=' CIS';
lcmooring3='cis';
startdate='21-Aug-2002';
enddate='25-Jun-2003';
enddate_num=datenum([enddate ' 23:15:00']);
lat=60;
long=39;

% read data
for ii=2:11;
	in_microcat=['/users/itg/animate/data/cis/1_deploy/microcat/recorded_data/raw/' int2str(serial_no(ii)) 'rec.asc'];
	if (Pvar(ii)==1)
	[Tx Cx Px ddx monx yyyyx timex]=textread(in_microcat,'%f%f%f %s%s%s %s','delimiter',', ','whitespace','\n','headerlines',skip(ii));  
	else
	[Tx Cx ddx monx yyyyx timex]=textread(in_microcat,'%f%f %s%s%s %s','delimiter',', ','whitespace','\n','headerlines',skip(ii));  
	end

	mc_time0=datenum(strcat(ddx,'-',monx,'-',yyyyx),13);
	mc_time=datenum(timex,0)+mc_time0;
	jj=find(mc_time <= enddate_num);
	Time(jj,ii)=mc_time(jj);

	T(jj,ii)=Tx(jj);
	C(jj,ii)=Cx(jj).*10;
	if (Pvar(ii)==1)
		P(jj,ii)=Px(jj);
	end
	clear Tx Cx Px jj mc_time0 mc_time ddx monx yyyyx;
end
cd /users/itg/animate;
save temp1;
[rows,cols]=size(T);
TQ=ones(rows,nvar);
PQ=ones(rows,nvar);
CQ=ones(rows,nvar);
SQ=ones(rows,nvar);
S=ones(rows,nvar);
St=ones(rows,nvar);
	
for j=1:nvar;
    if (Pvar(j) == 1)
   	for i=1:rows;
		if (P(i,j) < v(j)-5) PQ(i,j)=4; end
	end
    end
end

for j=1:nvar;
    if (Pvar(j) == 0)
	k=j+1;  
	while (Pvar(k)==0) k=k+1; end
	   	for i=1:rows;
	  	  	P(i,j)=v(j) +  ( P(i,k)-v(k) );
	  	        PQ(i,j)=PQ(i,k);
          	end;
         	Pvar(j) = 2;
    end;
end;


for j=nvar:-1:1;
    if (Pvar(j) == 0) 
    	k=j-1;  
    	while (Pvar(k)==0) k=k-1; end
	   	for i=1:rows;
	  	  	P(i,j)=v(j) +  ( P(i,k)-v(k) );
	  	        PQ(i,j)=PQ(i,k);
	       	end;
   	        Pvar(j) = 3;
    end;
end;

%quality control
for i=1:rows;
	for j=2:nvar;
		if ((P(i,j)==9999.99) | (T(i,j)==999.999) | (C(i,j)==999.999)|(P(i,j)==222.22) | (T(i,j)==22.222) | (C(i,j)==22.222))
		 S(i,j)=999.999;
		 SQ(i,j)=9;
		else 
		 if (TQ(i,j)==0) TQ(i,j)=var_range('temp',P(i,j),T(i,j));  end
		 if (TQ(i,j)==0)
			 S(i,j)=salinity(P(i,j),T(i,j),C(i,j));
			 SQ(i,j)=var_range('salt',P(i,j),S(i,j));
			 St(i,j)=sigmat(T(i,j),S(i,j));
			 CQ(i,j)=SQ(i,j);
		 end		
		end; 
	end;
end;





%kk=find((P(:,2)>30) & (T(:,9) > 2));  % select only data


% read data from telemetry for lost microcat


Time(:,1)=Time(:,2);

sz=size(T);


s1=['SELECT * FROM ' mooring '_data'];
s2=[' left join ' mooring '_qc on'];
s3=[' ((' mooring '_data.mn = ' mooring '_qc.mn_qc) and (' mooring '_data.bid = ' mooring '_qc.bid_qc))'];
s4=[' or ' mooring '_qc.mn_qc IS NULL'];
s5=' where (mn >= 12)  ';
s6=' and (temp10 < 999) and (temp402 < 999) order by mn ASC, bid DESC';
sqlstr=strcat(s1,s2,s3,s4,s5,s6);

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

PQ(:,1)=9;
TQ(:,1)=9;
CQ(:,1)=9;

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
    DateTime10=datenum(ddd(1:19));
    timediff=abs(Time(:,1)-DateTime10).*24.*60.*60;
    iii=find (timediff < 10);
    T(iii,1)=getfield(DATA,{i,1},'temp10' );
    AAAA=getfield(DATA,{i,1},'temp10_qc'  );
    if isempty(AAAA)
       	 TQ(iii,1)=1;
    else
       	 TQ(iii,1)=AAAA;
    end;
    C(iii,1)=getfield(DATA,{i,1},'cond10' );
    AAAA=getfield(DATA,{i,1},'cond10_qc'  );
    if isempty(AAAA)        
       CQ(iii,1)=1;
    else
       CQ(iii,1)=AAAA;
    end;
    
    if ((C(iii,1)==22.222)|(C(iii,1)==999.999))CQ(iii,1)=9;,end;
    if (C(iii,1)==5.000),C(iii,1)=999.999;CQ(iii,1)=9;,end;

    if ((T(iii,1)==22.222)|(T(iii,1)==999.999)) TQ(iii,1)=9;,end;

    if	(P(iii,1)< 5)  
	    PQ(iii,1)=4; 
    else
	    PQ(iii,1)=1; 
    end 
    

%quality control

	if ((P(iii,1)==9999.99) | (T(iii,1)==999.999) | (C(iii,1)==999.999)| (P(iii,1)==222.22)| (PQ(iii,1) > 1 )|(TQ(iii,1) > 1 )|(CQ(iii,1) > 1 ) )
		 S(iii,1)=999.999;
		 SQ(iii,1)=9;
	else 
		 TQ(iii,1)=var_range('temp',10,T(iii,1));
		 if (TQ(iii,1)<2)
			 S(iii,1)=salinity(10,T(iii,1),C(iii,1));
			 SQ(iii,1)=var_range('salt',10,S(iii,1));
			 St(iii,1)=sigmat(T(iii,1),S(iii,1));
			 CQ(iii,1)=SQ(iii,1);
		 end		
	end; 
end;



%kk1=find(T(:,1)>0&TQ(:,1)<2);

col=['b  '; 'g  '; 'r  '; 'c  '; 'm  '; 'y  '; 'k  '; 'b :' ;'g :' ;'r :'; 'c :'];

cd /users/itg/animate;
save temp;

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
%plot(Time(kk1),T(kk1,1),Time(kk,j),T(kk,2),Time(kk,j),T(kk,3),Time(kk,j),T(kk,4),Time(kk,j),T(kk,5),Time(kk,j),T(kk,6),Time(kk,j),T(kk,7),Time(kk,j),T(kk,8),'--',Time(kk,j),T(kk,9),'--',Time(kk,j),T(kk,10),'--',Time(kk,j),T(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),T(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','mmm');
xlabel('Date');
ylabel('Temperature deg C');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/small_cis_temperature.png');
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
%plot(Time(kk1),T(kk1,1),Time(kk,j),T(kk,2),Time(kk,j),T(kk,3),Time(kk,j),T(kk,4),Time(kk,j),T(kk,5),Time(kk,j),T(kk,6),Time(kk,j),T(kk,7),Time(kk,j),T(kk,8),'--',Time(kk,j),T(kk,9),'--',Time(kk,j),T(kk,10),'--',Time(kk,j),T(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),T(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','mmm');
xlabel('Date (2002-2003)');
ylabel('Temperature deg C');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend('Nom. 10m','Nom. 37m','Nom. 87m','Nom. 142m','Nom. 221m','Nom. 302m','Nom. 402m','Nom. 552m','Nom. 702m','Nom. 853m','Nom. 1002m',-1);
set(hlegend,'fontsize',6);
set(gca,'fontsize',8);
title('CIS mooring - Temperature deg C','fontsize',8);
xlabel('Date (2002-2003)');
ylabel('Temperature deg C');
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/cis_temperature.png');

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
%plot(Time(kk1),S(kk1,1),Time(kk,j),S(kk,2),Time(kk,j),S(kk,3),Time(kk,j),S(kk,4),Time(kk,j),S(kk,5),Time(kk,j),S(kk,6),Time(kk,j),S(kk,7),Time(kk,j),S(kk,8),'--',Time(kk,j),S(kk,9),'--',Time(kk,j),S(kk,10),'--',Time(kk,j),S(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),S(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','mmm');
xlabel('Date');
ylabel('Salinity (PSAL)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/small_cis_salinity.png');
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
%plot(Time(kk1),S(kk1,1),Time(kk,j),S(kk,2),Time(kk,j),S(kk,3),Time(kk,j),S(kk,4),Time(kk,j),S(kk,5),Time(kk,j),S(kk,6),Time(kk,j),S(kk,7),Time(kk,j),S(kk,8),'--',Time(kk,j),S(kk,9),'--',Time(kk,j),S(kk,10),'--',Time(kk,j),S(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),S(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','mmm');
xlabel('Date (2002-2003)');
ylabel('Salinity (PSAL)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend('Nom. 10m','Nom. 37m','Nom. 87m','Nom. 142m','Nom. 221m','Nom. 302m','Nom. 402m','Nom. 552m','Nom. 702m','Nom. 853m','Nom. 1002m',-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
title('CIS mooring - Salinity','fontsize',8);
xlabel('Date (2002-2003)');
ylabel('Salinity (PSAL)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/cis_salinity.png');

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
%plot(Time(kk1),St(kk1,1),Time(kk,j),St(kk,2),Time(kk,j),St(kk,3),Time(kk,j),St(kk,4),Time(kk,j),St(kk,5),Time(kk,j),St(kk,6),Time(kk,j),St(kk,7),Time(kk,j),St(kk,8),'--',Time(kk,j),St(kk,9),'--',Time(kk,j),St(kk,10),'--',Time(kk,j),St(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),St(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','mmm');
xlabel('Date');
ylabel('Sigma - t');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/small_cis_sigmat.png');
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
%plot(Time(kk1),St(kk1,1),Time(kk,j),St(kk,2),Time(kk,j),St(kk,3),Time(kk,j),St(kk,4),Time(kk,j),St(kk,5),Time(kk,j),St(kk,6),Time(kk,j),St(kk,7),Time(kk,j),St(kk,8),'--',Time(kk,j),St(kk,9),'--',Time(kk,j),St(kk,10),'--',Time(kk,j),St(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&PQ(:,j)<2);
	plot(Time(kk,j),St(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','mmm');
xlabel('Date (2002-2003)');
ylabel('Sigma - t');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend('Nom. 10m','Nom. 37m','Nom. 87m','Nom. 142m','Nom. 221m','Nom. 302m','Nom. 402m','Nom. 552m','Nom. 702m','Nom. 853m','Nom. 1002m',-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
title('CIS mooring - Sigma-t','fontsize',8);
xlabel('Date (2002-2003)');
ylabel('Sigma -t');
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/cis_sigmat.png');

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
%plot(Time(kk1),P(kk1,1),Time(kk,j),P(kk,2),Time(kk,j),P(kk,3),Time(kk,j),P(kk,4),Time(kk,j),P(kk,5),Time(kk,j),P(kk,6),Time(kk,j),P(kk,7),Time(kk,j),P(kk,8),'--',Time(kk,j),P(kk,9),'--',Time(kk,j),P(kk,10),'--',Time(kk,j),P(kk,11),'--','linewidth',0.8);
hold
for j=1:nvar;
	if (Pvar(j)==1)
		kk=find(PQ(:,j)<2);
		plot(Time(kk,j),P(kk,j),[col(j,:)]);
		clear kk;
	end	
end
hold
set(gca,'fontsize',3);
datetick('x','mmm');
xlabel('Date');
ylabel('Pressure (dbar)');
axis tight;
box;
set(gca,'ydir','reverse');
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/small_cis_pressure.png');
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
%plot(Time(kk,j),P(kk,2),'g',Time(kk,j),P(kk,4),'c',Time(kk,j),P(kk,7),'k',Time(kk,j),P(kk,9),'g--',Time(kk,j),P(kk,11),'c--','linewidth',0.8);
hold
for j=1:nvar;
	if (Pvar(j)==1)
		kk=find(PQ(:,j)<2);
		plot(Time(kk,j),P(kk,j),[col(j,:)]);
		clear kk;
	end	
end
hold
datetick('x','mmm');
xlabel('Date (2002-2003)');
ylabel('Pressure (dbar)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend('Nom. 37m','Nom. 142m','Nom. 402m','Nom. 702m','Nom. 1002m',-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
set(gca,'ydir','reverse');
title('CIS mooring - Pressure','fontsize',8);
xlabel('Date (2002-2003)');
ylabel('Pressure (dbar)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/pubread/animate/cis/1st_deployment/microcat/cis_pressure.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_lab='Date (2002-2003)';
kkk=find(PQ(:,1)<2 & TQ(:,1) <2 & PQ(:,8)<2);

clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.05 0.1 0.90 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),St(kkk,:));
shading interp;
hc=colorbar;
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'TickDir','Out');
set(gca,'YDir','reverse');
set(gca,'fontsize',2);
set(hc,'fontsize',2);
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/small_cis_sigmat_pcolor.jpg');

clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.1 0.9 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),St(kkk,:));
shading interp;
hc=colorbar;
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'TickDir','Out');
set(gca,'YDir','reverse');
set(gcf,'paperposition',[0 0 6.5 4]);
set(gca,'fontsize',7);
set(hc,'fontsize',7);
title('CIS mooring 1st Deployment - Sigma-t','fontsize',10);
xlabel(x_lab,'fontsize',10);
ylabel('Pressure dBar','fontsize',10);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/cis_sigmat_pcolor.jpg');


clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.1 0.9 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),S(kkk,:));
hc=colorbar;
shading interp;
set(gca,'fontsize',7);
set(hc,'fontsize',7);
set(gcf,'paperposition',[0 0 6.5 4]);
set(gca,'YDir','reverse');
set(gca,'TickDir','Out');
title('CIS mooring 1st Deployment - Salinity ','fontsize',10);
xlabel(x_lab,'fontsize',10);
ylabel('Pressure dBar','fontsize',10);
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/cis_salinity_pcolor.jpg');


clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.05 0.1 0.90 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),S(kkk,:));
hc=colorbar;
shading interp;
set(gca,'fontsize',2);
set(gcf,'paperposition',[0 0 1.9 1]);
set(gca,'YDir','reverse');
set(gca,'TickDir','Out');
set(hc,'fontsize',2);
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/small_cis_salinity_pcolor.jpg');


clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.1 0.9 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),T(kkk,:));
hc=colorbar;
shading interp;
set(gca,'fontsize',7);
set(hc,'fontsize',7);
set(gcf,'paperposition',[0 0 6.5 4]);
set(gca,'YDir','reverse');
set(gca,'TickDir','Out');
title('CIS mooring 1st Deployment - Temperature deg C ','fontsize',10);
xlabel(x_lab,'fontsize',10);
ylabel('Pressure dBar','fontsize',10);
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/cis_temp_pcolor.jpg');


clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.05 0.1 0.90 0.85]);
set(gcf,'renderer','painters');
pcolor(Time(kkk,:),P(kkk,:),T(kkk,:));
hc=colorbar;
shading interp;
set(hc,'fontsize',2);
set(gca,'fontsize',2);
set(gcf,'paperposition',[0 0 1.9 1]);
set(gca,'YDir','reverse');
set(gca,'TickDir','Out');
set(gca,'XMinorTick','Off');
datetick('x','mmm')
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
set(gcf,'CurrentAxes',hax);
saveas(gcf,'/data/ncs/www/animate/data/cis/small_cis_temp_pcolor.jpg');

TIME=Time(:,11);
clear hh mm ss
cd /users/itg/animate/netcdf/microcat;
microcat_netcdf_dm;

exit;
FIN

