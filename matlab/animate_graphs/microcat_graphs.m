col=['b  '; 'g  '; 'r  '; 'c  '; 'm  '; 'y  '; 'k  '; 'b :' ;'g :' ;'r :'; 'c :'; 'm :'; 'y :';'k :';'b--' ;'g--' ;'r--'; 'c--'; 'm--'; 'y--';'k--'];

% [left, bottom, width, height]
small_graph_axes=[0.11 0.02 0.88 0.9]
full_graph_axes=[0.09 0.08 0.90 0.85];
small_font_size=2;
if (exist('mooring_no')<1)
	mooring_no_text='';
else
  mooring_no_text=['_mn' mooring_no];
end
if (exist('legend_loc')<1)
    legend_loc='NorthEastOutside';
end
clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',small_graph_axes);
hold
clear G_legend P_legend;
jj=1;
for j=1:nvar;
  if (qc_var(j) ~= 3)
	  if  (v(j)<10) G_space='   ';end
	  if ((v(j)>=10)&(v(j)<100))G_space='  ';end
	  if ((v(j)>=100)&(v(j)<1000))G_space=' ';end
	  if  (v(j)>=1000)G_space='';end
	  G_legend(jj,:)= ['Nom.' G_space int2str(v(j)) 'm'];
	  kk=find(TQ(:,j)<2&T(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	  plot(DateTime(kk,1),T(kk,j),[col(j,:)]);
	  jj=jj+1;
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
xlabel(x_lab);
ylabel('Temperature deg C');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/small_' mooringlc mooring_no_text '_temperature.png']);

clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',full_graph_axes);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),T(kk,j),[col(j,:)]);
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
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
hlegend=legend(G_legend,'Location',legend_loc);
set(hlegend,'fontsize',6);
set(gca,'fontsize',7);
title([mooring ' mooring - Temperature deg C'],'fontsize',8);
xlabel(x_lab);
ylabel('Temperature deg C');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_temperature.png']);

clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',small_graph_axes);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),S(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',small_font_size);
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
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/small_' mooringlc mooring_no_text '_salinity.png']);

clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',full_graph_axes);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&S(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),S(kk,j),[col(j,:)]);
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
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
hlegend=legend(G_legend,'Location',legend_loc);
set(hlegend,'fontsize',6);
set(gca,'fontsize',7);
title([mooring ' mooring - Salinity'],'fontsize',8);
xlabel(x_lab);
ylabel('Salinity (PSAL)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_salinity.png']);

clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',small_graph_axes);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),St(kk,j),[col(j,:)]);
	clear kk;
end
hold
set(gca,'fontsize',small_font_size);
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
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/small_' mooringlc mooring_no_text '_sigmat.png']);
clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',full_graph_axes);
hold
for j=1:nvar;
	kk=find(SQ(:,j)<2&St(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),St(kk,j),[col(j,:)]);
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
box on;
%set(gca,'XMinorTick','On');
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
hlegend=legend(G_legend,'Location',legend_loc);
set(hlegend,'fontsize',6);
set(gca,'fontsize',7);
title([mooring ' mooring - Sigma-t'],'fontsize',8);
xlabel(x_lab);
ylabel('Sigma -t');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_sigmat.png']);
%
clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',small_graph_axes);
hold
for j=1:nvar;
	if (Wvar(j)==0)
		kk=find(PQ(:,j)<2);
		plot(DateTime(kk,1),P(kk,j),[col(j,:)]);
		clear kk;
	end	
end
hold
set(gca,'fontsize',small_font_size);
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
box on;
set(gca,'ydir','reverse');
%set(gca,'XMinorTick','On');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/small_' mooringlc mooring_no_text '_pressure.png']);
clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',full_graph_axes);
hold
jj=1;
for j=1:nvar;
	if (Wvar(j)==0)
		  if  (v(j)<10) G_space='   ';end
		  if ((v(j)>=10)&(v(j)<100))G_space='  ';end
		  if ((v(j)>=100)&(v(j)<1000))G_space=' ';end
		  if  (v(j)>=1000)G_space='';end
		  P_legend(jj,:)= ['Nom.' G_space int2str(v(j)) 'm']; 
		kk=find(PQ(:,j)<4);
		plot(DateTime(kk,1),P(kk,j),[col(j,:)]);
		clear kk;
		jj=jj+1;
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
%axis tight;
box on;
%set(gca,'XMinorTick','On');
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
hlegend=legend(P_legend,'Location',legend_loc);
set(hlegend,'fontsize',6);
set(gca,'fontsize',7);
set(gca,'ydir','reverse');
title([mooring ' mooring - Pressure'],'fontsize',8);
xlabel(x_lab);
ylabel('Pressure (dbar)');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_pressure.png']);


% still work to be done to replace pcolor graphs
% need to exclude non good data
%clf;
%zzz=find(TQ<3 & PQ<3 & T<22);
%c1=min(T(zzz));
%cmin=fix(min(c1));
%c2=max(T(zzz));
%cmax=fix(max(c2));
%vv=[cmin:cmax];
%T1=T;
%zzz1=find(TQ>2 | PQ>2 | T>22);
%T1(zzz1)=NaN;
%[Ct,h,CF]=contourf(DateTime,P,T1,vv);
%set(gca,'ydir','reverse')
%datetick('x','dd/mm');
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
%set(gcf,'paperunits','inches','paperposition',[0 0 6 4]);
%xlabel(x_lab);
%ylabel('Depth (dbar)');
%title([mooring ' mooring - Temperature deg C - Contour map'],'fontsize',10);
%saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_temp_contour.png'])
%
%clf;
%dim=fix(rows/48);
%newlength=dim*48;
%for j=1:nvar;
%	yyy=T1(1:newlength,j);
%	xxx=reshape(yyy,48,dim);
%	www=nanmean(xxx);
%	T24(:,j)=www';
%
%	yyy=DateTime(1:newlength,j);
%	xxx=reshape(yyy,48,dim);
%	www=mean(xxx);
%	DateTime24(:,j)=www';
%
%	yyy=P(1:newlength,j);
%	xxx=reshape(yyy,48,dim);
%	www=mean(xxx);
%	P24(:,j)=www';
%
%end;
%
%
%[Ct,h,CF]=contourf(DateTime24,P24,T24,vv);
%set(gca,'ydir','reverse')
%datetick('x','dd/mm');
%XTICK=get(gca,'XTick');
%[xrows xcols]=size(XTICK);
%for j=1:xcols;
%XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%	for k=1:6;
%	XTICKLAB(j,k)=XTL(1,k);
%	end;
%end;
%set(gca,'XTickLabel',XTICKLAB);
%set(gcf,'paperunits','inches','paperposition',[0 0 6 4]);
%xlabel(x_lab);
%ylabel('Depth (dbar)');
%title([mooring ' mooring - Temperature deg C - Contour map'],'fontsize',10);
%clabel(Ct);
%axis tight;
%saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_temp_contour_1.png'])
