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

% N
%cdout=['/data/ncs/pubread/animate/' mooringlc '/1st_deployment/microcat/'];
cdout='/users/itg/animate/cd_158/microcat/';
nvar=7;
Pvar=zeros(1,nvar);
%
%
serial_no(1)=2812;	v(1)=10;  			skip(1)=46;	Wvar(1)=2;
serial_no(2)=2974;	v(2)=25;  	Pvar(2)=1;	skip(2)=56;	Wvar(2)=0;
serial_no(3)=2486;	v(3)=42;  	Pvar(3)=1;	skip(3)=55;	Wvar(3)=0;
serial_no(4)=2934;	v(4)=112; 			skip(4)=46;	Wvar(4)=5;
serial_no(5)=2718;	v(5)=156; 	Pvar(5)=1;	skip(5)=55;	Wvar(5)=0;
serial_no(6)=2809;	v(6)=407; 			skip(6)=43;	Wvar(6)=5;
serial_no(7)=2933;	v(7)=1006;  			skip(7)=47;	Wvar(7)=5;
sensor1='Seabird SBE 37-IM                     ';
sensor2='Seabird SBE 37-IM with pressure sensor';
for j=1:nvar;
 if (Wvar(j) > 0)
    sensor_type(j,:)=sensor1;
 else
    sensor_type(j,:)=sensor2;
 end 
end
mooring='PAP3';
mooringlc='pap';
deploy='3rd_deployment';
x_lab='Date (2003-2004)';
startdate='17-Nov-2003';
enddate='18-Jun-2004';
enddate_num=datenum([enddate ' 17:45:05']);
lat=60;
long=39;
mode='D';
M_legend=['Nom. 10m  '; 'Nom. 25m  '; 'Nom. 42m  ' ;'Nom. 112m ';
          'Nom. 156m '; 'Nom. 407m '; 'Nom. 1006m'];
P_legend=['Nom. 25m  '; 'Nom. 42m  ' ;'Nom. 156m '];

%
% read data
for j=1:nvar;
	in_microcat=['/users/itg/animate/cd_158/cd158_AT_SEA/SBE37data/pap3/sbe37sn' int2str(serial_no(j)) '.asc'];
	if (Pvar(j)==1)
	[Tx Cx Px ddx monx yyyyx timex]=textread(in_microcat,'%f%f%f %s%s%s %s','delimiter',', ','whitespace','\n','headerlines',skip(j));  
	else
	[Tx Cx ddx monx yyyyx timex]=textread(in_microcat,'%f%f %s%s%s %s','delimiter',', ','whitespace','\n','headerlines',skip(j));  
	end
%
	mc_time0=datenum(strcat(ddx,'-',monx,'-',yyyyx),13);
	mc_time=datenum(timex,0)+mc_time0;
	tt=find(mc_time <= enddate_num);
	DateTime(tt,j)=mc_time(tt);
%
	T(tt,j)=Tx(tt);
	C(tt,j)=Cx(tt).*10;
	if (Pvar(j)==1)
		P(tt,j)=Px(tt);
	end
	clear Tx Cx Px tt mc_time0 mc_time ddx monx yyyyx;
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
%	
% calculate pressure
for j=1:nvar;
    	if (Wvar(j) > 0)
    	    k=Wvar(j);
   	    kkk=find(PQ(:,k) < 9);
  	  	P(kkk,j)=v(j) +  ( P(kkk,k)-v(k) );
  	        PQ(kkk,j)=PQ(kkk,k);
  	    clear kkk;    
  	    kkk=find(PQ(:,k)==9);
  	        P(kkk,j)=P(kkk,k);
  	        PQ(kkk,j)=PQ(kkk,k);
  	    clear kkk;
  	end;
   	
end;

%
%quality control
for j=1:nvar;
	kkk=find(T(:,j)>9999);
        TQ(kkk,j)=9;
        clear kkk;
	kkk=find( (P(:,j)>9999) | (T(:,j)>9999) | (C(:,j)>9999)|(P(:,j)==222.22) | (T(:,j)==22.222) | (C(:,j)==22.222) );
	 
	 S(kkk,j)=999.999;
	 SQ(kkk,j)=9;
	clear kkk;
	kkk=find(TQ(:,j) < 2);
	 TQ(kkk,j)=var_range('temp',P(kkk,j),T(kkk,j)); 
	clear kkk;
	kkk=find(TQ(:,j) < 2);
		 S(kkk,j)=salinity_dot(P(kkk,j),T(kkk,j),C(kkk,j));
		 SQ(kkk,j)=var_range('salt',P(kkk,j),S(kkk,j));
		 CQ(kkk,j)=SQ(kkk,j);
	clear kkk;		 
	kkk=find(SQ(:,j) < 2);
		St(kkk,j)=sigmat_dot(T(kkk,j),S(kkk,j));		
end;


multiplier=3.29;
for j=1:nvar;
% range by std does not work for temperature
%	iii=find(TQ(:,j)<2);
%	Tmn(j)=mean(T(iii,j));
%	Tstd(j)=std(T(iii,j));
%	kkk=find(abs(T(iii,j)-Tmn(j)) > (multiplier*Tstd(j)) ) ;
%	TQ(kkk,j)=3;
        clear kkk;
	clear iii;
	iii=find(SQ(:,j)<2);
	Smn(j)=mean(S(iii,j));
	Sstd(j)=std(S(iii,j));
	kkk=find(S(iii,j) < 35);
	SQ(kkk,j)=3;
	clear kkk;
	clear iii;
end;


%
%
%
%
col=['b  '; 'g  '; 'r  '; 'c  '; 'm  '; 'y  '; 'k  '; 'b :' ;'g :' ;'r :'; 'c :'];
cd /users/itg/animate;
save temp;
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),T(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Temperature deg C');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'small_' mooringlc '_temperature.png']);
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),T(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Temperature deg C');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend(M_legend,-1);
set(hlegend,'fontsize',6);
set(gca,'fontsize',8);
title([mooring ' mooring - Temperature deg C'],'fontsize',8);
xlabel(x_lab);
ylabel('Temperature deg C');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout mooringlc '_temperature.png']);

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),S(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Salinity (PSAL)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'small_' mooringlc '_salinity.png']);
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),S(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Salinity (PSAL)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend(M_legend,-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
title([mooring ' mooring - Salinity'],'fontsize',8);
xlabel(x_lab);
ylabel('Salinity (PSAL)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout mooringlc '_salinity.png']);

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),St(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',3);
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Sigma - t');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'small_' mooringlc '_sigmat.png']);
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&PQ(:,j)<2);
	plot(DateTime(kk,j),St(kk,j),[col(j,:)]);
	clear kk;
end
hold
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Sigma - t');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend(M_legend,-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
title([mooring ' mooring - Sigma-t'],'fontsize',8);
xlabel(x_lab);
ylabel('Sigma -t');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout mooringlc '_sigmat.png']);
%
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
hold
for j=1:nvar;
	if (Pvar(j)==1)
		kk=find(PQ(:,j)<2);
		plot(DateTime(kk,j),P(kk,j),[col(j,:)]);
		clear kk;
	end	
end
hold
set(gca,'fontsize',3);
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
datetick('x','mmm');
xlabel(x_lab);
ylabel('Pressure (dbar)');
axis tight;
box;
set(gca,'ydir','reverse');
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'small_' mooringlc '_pressure.png']);
clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
hold
for j=1:nvar;
	if (Pvar(j)==1)
		kk=find(PQ(:,j)<2);
		plot(DateTime(kk,j),P(kk,j),[col(j,:)]);
		clear kk;
	end	
end
hold
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
xlabel(x_lab);
ylabel('Pressure (dbar)');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperposition',[0 0 6.5 4]);
hlegend=legend(M_legend,-1);
set(hlegend,'fontsize',7);
set(gca,'fontsize',8);
set(gca,'ydir','reverse');
title([mooring ' mooring - Pressure'],'fontsize',8);
xlabel(x_lab);
ylabel('Pressure (dbar)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout mooringlc '_pressure.png']);


% still work to be done to replace pcolor graphs
% need to exclude non good data
zzz=find(TQ<3 & PQ<3 & T<22);
c1=min(T(zzz));
cmin=fix(min(c1));
c2=max(T(zzz));
cmax=fix(max(c2));
v=[cmin:cmax];
T1=T;
zzz1=find(TQ>2 | PQ>2 | T>22);
T1(zzz1)=NaN;
[C,h,CF]=contourf(DateTime,P,T1,v);
set(gca,'ydir','reverse')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
set(gcf,'paperposition',[0 0 6 4]);
xlabel(x_lab);
ylabel('Depth (dbar)');
title([mooring ' mooring - Temperature deg C - Contour map'],'fontsize',10);
saveas(gcf,[cdout mooringlc '_temp_contour.png'])

dim=fix(rows/48);
newlength=dim*48;
for j=1:nvar;
	yyy=T1(1:newlength,j);
	xxx=reshape(yyy,48,dim);
	www=nanmean(xxx);
	T24(:,j)=www';

	yyy=DateTime(1:newlength,j);
	xxx=reshape(yyy,48,dim);
	www=mean(xxx);
	DateTime24(:,j)=www';

	yyy=P(1:newlength,j);
	xxx=reshape(yyy,48,dim);
	www=mean(xxx);
	P24(:,j)=www';

end;


[C,h,CF]=contourf(DateTime24,P24,T24,v);
set(gca,'ydir','reverse')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gca,'XTickLabel',XTICKLAB);
set(gcf,'paperposition',[0 0 6 4]);
xlabel(x_lab);
ylabel('Depth (dbar)');
title([mooring ' mooring - Temperature deg C - Contour map'],'fontsize',10);
%clabel(C);
axis tight;
saveas(gcf,[cdout mooringlc '_temp_contour_1.png'])

%
%

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

save temp2;
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

%DIR=strcat('/data/ncs/pubread/animate/',mooringlc,'/',deploy,'/microcat');
%cd(DIR);

%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'_readme.txt'),txt,'');
%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.asc'),W,' ');
%dlmwrite(strcat(mooring,'_',startdate,'_to_',enddate,'.csv'),W,',');

%%%%% 2nd data set creation not necessary can be copied on off



exit;
FIN
