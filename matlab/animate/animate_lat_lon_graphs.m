function animate_lat_lon_graphs(webdir, plnm, suff, vTit, vLeg)
%animate_lat_lon_graphs
% Save large and small versions of animate lat/lon data plots

% Set small plot parameters
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
set(gca,'fontsize',4);
axis equal;

% Add axis labels
hxl = xlabel('Longitude W');
hyl = ylabel('Latitude  N');

% Save small version of plot
saveas(gcf,[webdir 'small_' plnm suff '.png']);

% Reset plot and font for large image
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);
set(hxl,'FontSize',8);
set(hyl,'FontSize',8);
set(gca,'FontSize',8);

% Add legend
hl=legend(vLeg,'Location','northwest');
set(hl,'FontSize',5);

% Add title
title(vTit);

% Save large version of plot
saveas(gcf,[webdir plnm suff '.png']);


end

