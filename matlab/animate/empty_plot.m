function empty_plot( varStr )
%empty_plot Generate 'holding' graphics explainng there are no data yet
global webdir

figure('visible','off');

plot(1,1);
text(0.4,1,'Data Not Yet Available','fontsize',16);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
saveas(gcf,[webdir varStr '.png']);

plot(1,1);
text(0.4,1,'Data Not Yet Available','fontsize',6);
axis off
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
saveas(gcf,[webdir 'small_' varStr '.png']);

end

