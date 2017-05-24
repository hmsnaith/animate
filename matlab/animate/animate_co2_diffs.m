%script to generate, save and plot CO2 differences
%Needs Work!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
co2_diff=diff(proKdat.pCO2);
time_diff=diff(proKdat.Date_Time);
k=find(time_diff<0.0008);
plot(pro_o_K_numdate(1:end-1),co2_diff,'.');
title('Pro-Oceanus on keel data - Plot of difference from previous reading within measurement');
saveas(gcf,[webdir 'keel_pro_o_K_diff_1.png']);

plot(pro_o_K_numdate(k),diff(k),'.')
saveas(gcf,[webdir 'small_keel_pro_o_K_diff_2.png']);
ylabel('Differences');
title('PAP mooring : Pro-Oceanus on keel data: Plot of difference from previous reading within measurment period');
saveas(gcf,[webdir 'keel_pro_o_K_diff_2.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kq=find(time_diff<-((5*60)/(24*60*60)));
k=1;
skq=size(kq)
szz=skq(1);
if (skq(2) > szz) szz=skq(2); end

for i = 1:szz;
  for j=0:9
    Wdate(1,k)=pro_o_K_numdate(kq(i)-j);
    W(3,k)=pro_o_K_seconds(kq(i)-j);
    W(4,k)=pro_o_K_conc(kq(i)-j);
    W(5,k)=pro_o_K_gas_press(kq(i)-j);
    W(6,k)=pro_o_K_cell_temp(kq(i)-j);
    W(7,k)=pro_o_K_AZPC(kq(i)-j);
    W(8,k)=pro_o_K_raw_co2(kq(i)-j);
    W(9,k)=pro_o_K_gas_temp(kq(i)-j);
    W(10,k)=pro_o_K_gas_humid(kq(i)-j);
    W(11,k)=pCO2(kq(i)-j);
    k=k+1;
  end
end  
% convert to Excel date
Wdate(1,:)=Wdate(1,:)+1-datenum(1900,1,0);
W(1,:)=floor(Wdate(1,:));
W(2,:)=Wdate(1,:)-W(1,:);
csvwrite(['/noc/users/animate/animate_data/pap/' deploy '/pro_o/pro_o_K_last10.csv'],transpose(W));


WW=W(11,:);
kq7=find(WW>450);
WW(kq7)=NaN;
Wsize=size(W);
WWW=reshape(WW,10,(Wsize(2)/10));
WWW_date1=reshape(W(1,:),10,(Wsize(2)/10));
WWW_date2=reshape(W(2,:),10,(Wsize(2)/10));

[WWWmax,WWWindex]=max(WWW,[],1);
for ii=1:(Wsize(2)/10)
    WWWindex2(ii)=WWWindex(ii)+(10*(ii-1));
end


pCO2_max=[WWW_date1(WWWindex2); WWW_date2(WWWindex2); WWWmax];
csvwrite(['/noc/users/animate/animate_data/pap/' deploy '/pro_o/pro_o_K_maxpCO2.csv'],transpose(pCO2_max));
pCO2_max_date=WWW_date1(WWWindex2)+ WWW_date2(WWWindex2)-1+datenum(1900,1,0);

% monthly averages
numdate_vec=datevec(pCO2_max_date);
if exist('mnVar')
	clear mnVname mnVar;
end
mnVar=pCO2_max(3,:);
mnVname='pCO2_1';
monthly_average;

clf;
%hax=axes('Position',[0 0 1 1],'visible','off');
%axes('Position',[0.08 0.15 0.9 0.9]);

plot(pro_o_K_numdate(kq),pro_o_K_conc(kq),'b.',pro_o_K_numdate(kq),pCO2(kq),'g.',...
    pro_o_K_numdate(kq-1),pro_o_K_conc(kq-1),'b.',pro_o_K_numdate(kq-1),pCO2(kq-1),'g.',...
    pro_o_K_numdate(kq-2),pro_o_K_conc(kq-2),'b.',pro_o_K_numdate(kq-2),pCO2(kq-2),'g.',...
    pro_o_K_numdate(kq-3),pro_o_K_conc(kq-3),'b.',pro_o_K_numdate(kq-3),pCO2(kq-3),'g.',...
    pro_o_K_numdate(kq-4),pro_o_K_conc(kq-4),'b.',pro_o_K_numdate(kq-4),pCO2(kq-4),'g.',...
    pro_o_K_numdate(kq-5),pro_o_K_conc(kq-5),'b.',pro_o_K_numdate(kq-5),pCO2(kq-5),'g.',...
    pro_o_K_numdate(kq-6),pro_o_K_conc(kq-6),'b.',pro_o_K_numdate(kq-6),pCO2(kq-6),'g.',...
    pro_o_K_numdate(kq-7),pro_o_K_conc(kq-7),'b.',pro_o_K_numdate(kq-7),pCO2(kq-7),'g.',...
    pro_o_K_numdate(kq-8),pro_o_K_conc(kq-8),'b.',pro_o_K_numdate(kq-8),pCO2(kq-8),'g.',...
    pro_o_K_numdate(kq-9),pro_o_K_conc(kq-9),'b.',pro_o_K_numdate(kq-9),pCO2(kq-9),'g.',...
    pro_o_K_numdate(rows),pro_o_K_conc(rows),'b.',pro_o_K_numdate(rows),pCO2(rows),'g.',...
    pCO2_max_date,pCO2_max(3,:),'r.');
    
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('');
datetick('x',19);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'YLim',[250 400]);
saveas(gcf,[webdir 'small_keel_pro_o_K_conc_2.png']);

set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(gca,'fontsize',9);
xlabel(x_lab);
ylabel('Concentration');
tb1(1)={'Blue  xCO_2 (ppm)'};
tb1(2)={'Green pCO_2 (\muatm)'};
tb1(3)={'Red   Maximum pCO_2'};
text((now-30),270,tb1,'fontsize',5);
%hl=legend('xCO_2 (ppm)   ','pCO_2 (\muatm)','pCO_2 Maximum ','location','best');
%set(hl,'fontsize',5);
title(['PAP mooring : Pro-Oceanus on keel data - Carbon Dioxide. Latest data: ' datestr(pro_o_K_numdate(rows))]);
set(gca,'YLim',ylim);
saveas(gcf,[webdir 'keel_pro_o_K_conc_2.png']);


clf;

plot(pro_o_K_numdate(kq),pro_o_K_conc(kq),'b.',pro_o_K_numdate(kq),pCO2(kq),'g.',...
    pro_o_K_numdate(kq-1),pro_o_K_conc(kq-1),'b.',pro_o_K_numdate(kq-1),pCO2(kq-1),'g.',...
    pro_o_K_numdate(kq-2),pro_o_K_conc(kq-2),'b.',pro_o_K_numdate(kq-2),pCO2(kq-2),'g.',...
    pro_o_K_numdate(kq-3),pro_o_K_conc(kq-3),'b.',pro_o_K_numdate(kq-3),pCO2(kq-3),'g.',...
    pro_o_K_numdate(kq-4),pro_o_K_conc(kq-4),'b.',pro_o_K_numdate(kq-4),pCO2(kq-4),'g.',...
    pro_o_K_numdate(kq-5),pro_o_K_conc(kq-5),'b.',pro_o_K_numdate(kq-5),pCO2(kq-5),'g.',...
    pro_o_K_numdate(kq-6),pro_o_K_conc(kq-6),'b.',pro_o_K_numdate(kq-6),pCO2(kq-6),'g.',...
    pro_o_K_numdate(kq-7),pro_o_K_conc(kq-7),'b.',pro_o_K_numdate(kq-7),pCO2(kq-7),'g.',...
    pro_o_K_numdate(kq-8),pro_o_K_conc(kq-8),'b.',pro_o_K_numdate(kq-8),pCO2(kq-8),'g.',...
    pro_o_K_numdate(kq-9),pro_o_K_conc(kq-9),'b.',pro_o_K_numdate(kq-9),pCO2(kq-9),'g.',...
    pro_o_K_numdate(rows),pro_o_K_conc(rows),'b.',pro_o_K_numdate(rows),pCO2(rows),'g.');
%    ,...
%    seanumdate,Aa_co2_calc,'r+');
    
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel('');
datetick('x',19);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'YLim',ylim);
saveas(gcf,[webdir 'small_keel_pro_o_K_conc_3.png']);


clf;
%hax=axes('Position',[0 0 1 1],'visible','off');
%axes('Position',[0.08 0.15 0.9 0.9]);

plot(pro_o_K_numdate(kq),pro_o_K_conc(kq),'b.',pro_o_K_numdate(kq),pCO2(kq),'g.',...
    pro_o_K_numdate(kq-1),pro_o_K_conc(kq-1),'b.',pro_o_K_numdate(kq-1),pCO2(kq-1),'g.',...
    pro_o_K_numdate(kq-2),pro_o_K_conc(kq-2),'b.',pro_o_K_numdate(kq-2),pCO2(kq-2),'g.',...
    pro_o_K_numdate(kq-3),pro_o_K_conc(kq-3),'b.',pro_o_K_numdate(kq-3),pCO2(kq-3),'g.',...
    pro_o_K_numdate(kq-4),pro_o_K_conc(kq-4),'b.',pro_o_K_numdate(kq-4),pCO2(kq-4),'g.',...
    pro_o_K_numdate(kq-5),pro_o_K_conc(kq-5),'b.',pro_o_K_numdate(kq-5),pCO2(kq-5),'g.',...
    pro_o_K_numdate(kq-6),pro_o_K_conc(kq-6),'b.',pro_o_K_numdate(kq-6),pCO2(kq-6),'g.',...
    pro_o_K_numdate(kq-7),pro_o_K_conc(kq-7),'b.',pro_o_K_numdate(kq-7),pCO2(kq-7),'g.',...
    pro_o_K_numdate(kq-8),pro_o_K_conc(kq-8),'b.',pro_o_K_numdate(kq-8),pCO2(kq-8),'g.',...
    pro_o_K_numdate(kq-9),pro_o_K_conc(kq-9),'b.',pro_o_K_numdate(kq-9),pCO2(kq-9),'g.',...
    pro_o_K_numdate(rows),pro_o_K_conc(rows),'b.',pro_o_K_numdate(rows),pCO2(rows),'g.')
    %,...
    %seanumdate,Aa_co2_calc,'r+');
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
set(gca,'fontsize',9);
xlabel(x_lab);
ylabel('Concentration');

datetick('x',19);
%hl=legend('xCO_2 (ppm)   ','pCO_2 (\muatm)','location','best');
%set(hl,'fontsize',5);
title(['PAP mooring : Pro-Oceanus on keel data - Carbon Dioxide. Latest data: ' datestr(pro_o_K_numdate(rows))]);
set(gca,'YLim',ylim);
saveas(gcf,[webdir 'keel_pro_o_K_conc_3.png']);

