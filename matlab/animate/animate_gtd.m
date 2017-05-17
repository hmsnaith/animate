figure('visible','off');
pcmd='lpr -s -r -h';
path('/nerc/packages/satprogs/satmat/mysql',path);
mysql('open','mysql','animate_admin','an1mate9876','animate');
s1=['select * from ' db_table '_gtd']; 
s2=[' where Date_Time > "' start_date '"']; 
s3=[' and Date_Time < "' end_date '"'];
s4=[' order by Date_Time DESC'];
sql=strcat(s1,s2,s3,s4);
DATA=mysql(sql);
mysql close;
[rows,cols]=size(DATA)
if (rows > 0)
for  i = 1:rows;
    date(1:19)=getfield(DATA,{i,1},'Date_Time');
    ddd(1)=date(6);
    ddd(2)=date(7);
    ddd(3)=date(8);
    ddd(4)=date(9);
    ddd(5)=date(10);
    ddd(6)=date(5);
    ddd(7)=date(1);
    ddd(8)=date(2);
    ddd(9)=date(3);
    ddd(10)=date(4);
    ddd(11:19)=date(11:19);
    gtdnumdate(i)=datenum(ddd(1:19));
    tdgp(i)=getfield(DATA,{i,1},'tdgp');
    time_diff(i)=getfield(DATA,{i,1},'time_diff');

   
end;

clf;
hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0.08 0.15 0.9 0.9]);
plot(gtdnumdate,tdgp,'b.');
set(gca,'fontsize',4);
xlabel(x_lab);
ylabel(' ');
datetick('x','dd/mm');
%set(gca,'Ylim',[7.6 8.6]);
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_gtd_1.png']);

clf;
plot(gtdnumdate,tdgp,'b.');
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(gca,'fontsize',8);
xlabel(x_lab);
ylabel('TDGP mbar');
datetick('x','dd/mm');
%set(gca,'Ylim',[7.6 8.6]);
legend('TDGP','location','northeast');
title(['Pro-Oceanus GTD sensor   Latest data: ' datestr(gtdnumdate(1))]);
saveas(gcf,[webdir 'gtd_1.png']);

else
plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir 'gtd_1.png']);

plot(1,1);
text(0.4,1,'Plot Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_gtd_1.png']);

end
