col=['b  '; 'g  '; 'r  '; 'c  '; 'm  '; 'y  '; 'k  '; 'b :' ;'g :' ;'r :'; 'c :'; 'm :'; 'y :';'k :';'b--' ;'g--' ;'r--'; 'c--'; 'm--'; 'y--';'k--'];
if (exist('mooring_no')<1)
	mooring_no_text='';
else
  mooring_no_text=['_mn' mooring_no];
end

clf
%figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.1 0.1 0.85 0.85]);
hold
clear G_legend P_legend;
jj=1;
for j=1:nvar;
  if (qc_var(j) ~= 3)
	  if  (v(j)<10) G_space='    ';end
	  if ((v(j)>=10)&(v(j)<100))G_space='   ';end
	  if ((v(j)>=100)&(v(j)<1000))G_space='  ';end
	  if  (v(j)>=1000)G_space=' ';end
	  if  (v(j)>=10000)G_space='';end
	  G_legend(jj,:)= ['Nom.' G_space int2str(v(j)) 'm'];
	  kk=find(TQ(:,j)<2&T(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	  plot(DateTime(kk,1),Ox(kk,j),[col(j,:)]);
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
ylabel('Oxygen ml/l');
axis tight;
box;
%set(gca,'XMinorTick','On');
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/small_' mooringlc mooring_no_text '_oxygen.png']);

clf
figure('visible','off');
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.07 0.08 0.90 0.85]);
hold
for j=1:nvar;
	kk=find(TQ(:,j)<2&T(:,j)>0&(PQ(:,j)<2)|(PQ(:,j)==8));
	plot(DateTime(kk,1),Ox(kk,j),[col(j,:)]);
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
hlegend=legend(G_legend,-1);
set(hlegend,'fontsize',6);
set(gca,'fontsize',7);
title([mooring ' mooring - Temperature deg C'],'fontsize',8);
xlabel(x_lab);
ylabel('Temperature deg C');
set(gcf,'CurrentAxes',hax);
saveas(gcf,[cdout 'graphs/' mooringlc mooring_no_text '_oxygen.png']);

