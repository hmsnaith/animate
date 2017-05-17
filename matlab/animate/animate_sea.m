% Script to plot sea data from MySQL table

%% Setup variables

sbodat(1:sbo_nv) = struct('numdate',[],'batt_voltage',[],'memory_used',[],...
  'cyclops_chl',[],'Aa_ox_microM',[],'Aa_ox_air_sat',[],'Aa_ox_temp',[],...
  'Aa_ox_cal_phase',[],'Aa_ox_tcphase',[],'Aa_ox_c1_r_ph',[],...
  'Aa_ox_c2_r_ph',[],'Aa_ox_c1_a',[],'Aa_ox_c2_a',[],'Aa_ox_raw_temp',[],...
  'rcm_speed',[],'rcm_dir',[],'rcm_n',[],'rcm_e',[],'heading_mag',[],...
  'tilt_x',[],'tilt_y',[],'sp_std',[],'sig_strength',[],'ping_count',[],...
  'abs_tilt',[],'max_tilt',[],'std_tilt',[]);
flds = fieldnames(sbodat);

param = struct('temp','Temperature deg C','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen on Seabird microcat','ox_mol','Oxygen on Seabird microcat',...
               'ox_mol_comp','Salinity compensated Oxygen on Seabird microcat');
units = struct('temp','Temperature deg C','press','Pressure dB',...
               'S','Salinity','St','Sigma-t',...
               'ox','Oxygen (ml/l)','ox_mol','Oxygen (\mumol/l)',...
               'ox_mol_comp','Sal. comp. O\2 (\mumol)' );
have_data = 0;
%% Read in and QC Values
% Read data from MySQL database table
db_tab=[db_table '_sea_' num2str(m)];
s_str = ' order by Date_Time ASC';
[DATA, rows] = mysql_animate(db_tab,start_date,end_date,s_str);

if (rows > 0)
  % Convert Date and Time character string to datenum
  sbodat.numdate = datenum(cell2mat({DATA(:).Date_Time}'),'yyyy-mm-dd HH:MM:SS')';
  % transfer remaining data into data structure
  for j=2:length(flds)
    fld = flds{j};
    % Copy measurements into structure
    sbodat(m).(fld) = cell2mat({DATA(:).(fld)});
  end
  
  sbodat.Aa_ox_microM(Aa_ox_microM<1) = NaN;
  sbodat.Aa_ox_air_sat(Aa_ox_air_sat<1) = NaN;
  sbodat.Aa_ox_microM_corr=(sbodat.Aa_ox_microM.*Aa_ox_slope)+Aa_ox_offset;

% monthly averages
  numdate_vec = datevec(sbodat(m).numdate);
  for fld = {'Aa_ox_microM_corr','Aa_ox_air_sat'}
    mnVar = sbodat.(char(fld));
    mnVname=char(fld);
    monthly_average(deploy,start_year,end_year,numdate_vec,mnVar,mnVname);
  end
  
  
  plot(seanumdate,Aa_ox_microM,seanumdate,Aa_ox_air_sat);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('');
datetick('x','dd/mm');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',2);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[webdir 'small_Aa_oxygen5.png']);

clf;
figure('visible','off');
plot(seanumdate,Aa_ox_microM,seanumdate,Aa_ox_air_sat);
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',7);
xlabel(x_lab,'fontsize',8);
ylabel(' ');
hl=legend('Conc. \muM  ','Air sat. %','location','best');
set(hl,'fontsize',5);
title(['Aanderaa Oxygen: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
saveas(gcf,[webdir 'Aa_oxygen5.png']);

clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.15 0.9 0.9]);
plotyy(seanumdate,Aa_ox_microM,seanumdate,Aa_ox_air_sat);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('');
datetick('x','dd/mm');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',2);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[webdir 'small_Aa_oxygen2.png']);

clf;
figure('visible','off');
[AX,H1,H2]=plotyy(seanumdate,Aa_ox_microM,seanumdate,Aa_ox_air_sat);
set(get(AX(1),'Ylabel'),'String','Oxygen Concentration (\muM'); 
set(get(AX(2),'Ylabel'),'String','Sensor Air Saturation (%)');
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',7);
xlabel(x_lab,'fontsize',8);
ylabel(' ');
hl=legend('Conc. \muM','Air Sat.%','location','best');
set(hl,'fontsize',5);
title(['Aanderaa Oxygen: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
saveas(gcf,[webdir 'Aa_oxygen2.png']);


clear k k1


clf;
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.15 0.9 0.9]);
plot(seanumdate,Aa_ox_microM_corr,seanumdate,Aa_ox_air_sat);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('');
datetick('x','dd/mm');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',2);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[webdir 'small_Aa_oxygen3.png']);

clf;
figure('visible','off');
plot(seanumdate,Aa_ox_microM_corr,seanumdate,Aa_ox_air_sat);
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
set(gca,'fontsize',7);
xlabel(x_lab,'fontsize',8);
ylabel(' ');
hl=legend('Conc. \muM/l','Air Sat. %','location','best');
set(hl,'fontsize',5);
title(['Aanderaa Oxygen: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
saveas(gcf,[webdir 'Aa_oxygen3.png']);

clf;
figure('visible','off');
[AX,H1,H2]=plotyy(seanumdate,Aa_ox_microM_corr,seanumdate,Aa_ox_air_sat);
set(get(AX(1),'Ylabel'),'String','Oxygen Concentration (\muM/l'); 
set(get(AX(2),'Ylabel'),'String','Oxygen Saturation (%)');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(AX(1),'XMinorTick','Off')
set(AX(2),'XMinorTick','Off')
datetick(AX(1),'x','dd/mm');
datetick(AX(2),'x','dd/mm');
XTICK=get(AX(1),'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(AX(1),'XTickLabel',XTICKLAB);
set(AX(1),'fontsize',2);
set(AX(2),'XTickLabel',XTICKLAB);
set(AX(2),'fontsize',2);
%xlabel(x_lab,'fontsize',8);
ylabel(AX(1),' ');
ylabel(AX(2),' ');
%hl=legend('Conc. \muM/l','Air Sat. %','location','best');
%set(hl,'fontsize',5);
%title(['Aanderaa Oxygen: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
saveas(gcf,[webdir 'small_Aa_oxygen.png']);

clf;
figure('visible','off');
[AX,H1,H2]=plotyy(seanumdate,Aa_ox_microM_corr,seanumdate,Aa_ox_air_sat);
set(get(AX(1),'Ylabel'),'String','Oxygen Concentration (\muM/l'); 
set(get(AX(2),'Ylabel'),'String','Oxygen Saturation (%)');
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(AX(1),'XMinorTick','Off')
set(AX(2),'XMinorTick','Off')
datetick(AX(1),'x','dd/mm');
datetick(AX(2),'x','dd/mm');
XTICK=get(AX(1),'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(AX(1),'XTickLabel',XTICKLAB);
set(AX(1),'fontsize',7);
set(AX(2),'XTickLabel',XTICKLAB);
set(AX(2),'fontsize',7);
xlabel(x_lab,'fontsize',8);
ylabel(' ');
hl=legend('Conc. \muM/l','Air Sat. %','location','best');
set(hl,'fontsize',5);
title(['Aanderaa Oxygen: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
saveas(gcf,[webdir 'Aa_oxygen.png']);



%%%%%%%%%%%%%%%%%%%%%%%
clf;
cyclops_chl=(cyclops_chl*cyclops_slope)+cyclops_intercept; % calibration against CTD 

% monthly averages
numdate_vec=datevec(seanumdate);
if exist('mnVar')
	clear mnVname mnVvar;
end
mnVar=cyclops_chl;
mnVname='cyclops_Chl';
fd=fopen(['/noc/users/animate/animate_data/pap/' deploy '/monthly/' mnVname '_monthly_average.csv'],'w+');
for loop_year=start_year:end_year;
	for loop_mon=1:12;
		clear kwkw;
		kwkw=find((numdate_vec(:,1)==loop_year)&(numdate_vec(:,2)==loop_mon));		
		mon_ave=nanmean(mnVar(1,kwkw(:)));
		fprintf(fd,'%u,%u,%f\n',loop_year,loop_mon,mon_ave);
	end
end
fclose(fd);

figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.15 0.9 0.9]);
plot(seanumdate,cyclops_chl);
datetick('x','dd/mm');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
%set(gca,'XTickLabel',XTICKLAB);
clear ylim
chlYlim
ylim(chlYlim);
set(gca,'fontsize',2);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[webdir 'small_cyclops.png']);


clf;
figure('visible','off');
plot(seanumdate,cyclops_chl);
datetick('x','dd/mm');
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[xrows xcols]=size(XTICK);
for j=1:xcols;
XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
	for k=1:6;
	XTICKLAB(j,k)=XTL(1,k);
	end;
end;
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(gca,'fontsize',7);
xlabel(x_lab,'fontsize',8);
ylabel('Chlorophyll-a (\mug/l)','fontsize',10);
title(['Cyclops Chlorophyll-a: Latest data: ' datestr(seanumdate(rows))],'fontsize',10);
chlYlim
ylim(chlYlim);
saveas(gcf,[webdir 'cyclops.png']);


clf;
figure('visible','off');
plot(seanumdate,heading_mag,seanumdate,tilt_x,seanumdate,tilt_y);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('Tilt (Degrees)');
datetick('x',19);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_sea_tilt.png']);

set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(gca,'fontsize',8);
xlabel(x_lab);
ylabel('Tilt (Degrees)');
hl=legend('Seaguard Orientation','Tilt X','Tilt Y');
set(hl,'fontsize',5);
title(['Seaguard Tilt: Latest data: ' datestr(seanumdate(rows))]);
saveas(gcf,[webdir 'sea_tilt.png']);


clear k
k=find(((rcm_speed==0.00)&(rcm_dir==0.00))|(rcm_speed<-2));
rcm_speed(k)=NaN;
rcm_dir(k)=NaN;
rcm_n(k)=NaN;
rcm_e(k)=NaN;

clf;
figure('visible','off');
plot(seanumdate,rcm_speed,seanumdate,rcm_dir);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel(' ');
datetick('x',19);
%set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'paperunits','centimeters','paperposition',[0 0 5 2.5]);
saveas(gcf,[webdir 'small_rcm1.png']);

set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(gca,'fontsize',8);
xlabel(x_lab);
ylabel('Current');
hl=legend('Speed (cm/s)','Direction (degrees)');
set(hl,'fontsize',5);
title(['Current Meter Latest data: ' datestr(seanumdate(rows))]);
saveas(gcf,[webdir 'rcm1.png']);

clf;
figure('visible','off');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
subplot(2,1,1);
plot(seanumdate,rcm_speed);
set(gca,'fontsize',2);
datetick('x',19);
subplot(2,1,2);
plot(seanumdate,rcm_dir,'.');
set(gca,'fontsize',2);
xlabel(x_lab);
datetick('x',19);

saveas(gcf,[webdir 'small_rcm2.png']);

clf;
figure('visible','off');
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
subplot(2,1,1);
plot(seanumdate,rcm_speed);
set(gca,'fontsize',8);
title(['Current Meter Latest data: ' datestr(seanumdate(rows))]);
ylabel('Current Speed (cm/s)');
xlabel(x_lab);
datetick('x',19);
subplot(2,1,2);
plot(seanumdate,rcm_dir,'.');
set(gca,'fontsize',8);
xlabel(x_lab);
datetick('x',19);
ylabel('Current Direction (deg)');
saveas(gcf,[webdir 'rcm2.png']);


clf;
figure('visible','off');

%select time points closest to 0,6,12,18,
drift=0.0035; %5minutes as proportion of day 300/84600
drift=0.0106; %15  minutes as proportion of day
drift=0.022; %30  minutes as proportion of day
seanumtime=seanumdate-floor(seanumdate);
zz=ones(size(rcm_e));
kk1=find((seanumtime< drift)|(seanumtime>1-drift));
kk2=find((seanumtime>(0.25-drift))&(seanumtime<(0.25+drift)));
kk3=find((seanumtime>(0.5-drift))&(seanumtime<(0.5+drift)));
kk4=find((seanumtime>(0.75-drift))&(seanumtime<(0.75+drift)));

quiver(seanumdate(kk1),zz(kk1),rcm_e(kk1),rcm_n(kk1));
hold;
quiver(seanumdate(kk2),zz(kk2),rcm_e(kk2),rcm_n(kk2));

quiver(seanumdate(kk3),zz(kk3),rcm_e(kk3),rcm_n(kk3));

quiver(seanumdate(kk4),zz(kk4),rcm_e(kk4),rcm_n(kk4));
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);

datetick('x',19); 
set(gca,'fontsize',4);
set(gca,'yticklabel',' ');
xlabel(x_lab);
saveas(gcf,[webdir 'small_rcm3.png']);

set(gca,'yticklabel',' ');
legend('00:00','06:00','12:00','18:00');
yyy=get(gca,'ylim');
yyy1=yyy(2)+(yyy(2)-yyy(1))/20;
%text(seanumdate(rows),yyy1,'Current Meter : arrows show direction of flow and relative speed');
set(gca,'fontsize',8);
title(['Current Direction Latest data: ' datestr(seanumdate(rows))  ' : Arrows show direction and relative speed']);
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
datetick('x',19); 
xlabel(x_lab);
saveas(gcf,[webdir 'rcm3.png']);
hold off;
clf;
figure('visible','off');
plot(seanumdate,rcm_n,seanumdate,rcm_e);
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('Current');
datetick('x',19);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_rcm4.png']);

set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(gca,'fontsize',8);
xlabel(x_lab);
ylabel('Sea Current');
hl=legend('North vector','East vector');
set(hl,'fontsize',5);
title(['Current Meter : Latest data: ' datestr(seanumdate(rows))]);
saveas(gcf,[webdir 'rcm4.png']);

clf;
figure('Visible','off');
axes('Position',[0.07 0.05 0.85 0.88]);
[haxes,hline1,hline2]=plotyy(seanumdate,sea_batt_v,seanumdate,memory);
set(haxes(1),'fontsize',3);
datetick(haxes(1),'x',19);
xlabel(x_lab);
set(haxes(2),'fontsize',3);
datetick(haxes(2),'x',19);
xlabel(x_lab);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_sea_monitor.png']);

set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(haxes(1),'fontsize',8);
set(get(haxes(1),'Ylabel'),'String','Battery (V)');
datetick(haxes(1),'x',19);
xlabel(x_lab);
set(haxes(2),'fontsize',8);
set(get(haxes(2),'Ylabel'),'String','Memory used');
datetick(haxes(2),'x',19);
xlabel(x_lab);
title(['Seaguard monitoring : Latest data: ' datestr(seanumdate(rows))],'fontsize',8);
saveas(gcf,[webdir 'sea_monitor.png']);


else
plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'oxygen.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_oxygen.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'oxygen2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_oxygen2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'rcm1.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_rcm1.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'rcm2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_rcm2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'rcm3.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_rcm3.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'rcm4.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_rcm4.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'cyclops.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_cyclops.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'sea_tilt.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_sea_tilt.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'sea_monitor.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_sea_monitor.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'Aa_co2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_Aa_co2.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'sbo_oxygen.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_sbo_oxygen.png']);


end


