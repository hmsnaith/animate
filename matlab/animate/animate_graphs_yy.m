function animate_graphs_yy(varTitle,varStr,y_lab,varYlim,x,y)
% Plot a small and large graph as png for 2 variables on different y axes
% Input:
%   varTitle: Plot title
%   varStr: string to use to name output plots
%   ylab: string to use for y axis labels
%   varYlim: if not empty, used to limit y axes
%   x, y: cell arrays of x and y data to plot
%    uses plotyy to plot x{1},y{1},x{2},y{2} with axes labelled ylab{1} and
%    ylab{2}
%
% the x axis label and directory to output graphs are set in global
% variables x_lab and webdir
global webdir x_lab

%% Setup a new figure - visibility off for batch use
figure('visible','off');
% figure
% Set axes and size for small figure
% hax=axes('Position',[0 0 1 1],'visible','off');
axes('Position',[0 0 1 1]);
%% Plot data
% For each input cell array
if length(x)<2
  disp('Only first 2 variables input to animate_graphs_yy will be plotted');
end

% plot variables
[AX]=plotyy(x{1},y{1},x{2},y{2});
% If we are limiting Y axis, do it here
% if exist('varYlim','var') && ~isempty(varYlim), ylim(varYlim); end

% Set tickmarks and x axis
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');

%% Generate small plot version
% Set paper size
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% Define axes position
set(gca,'Position',[0.08 0.15 0.9 0.9]);
set(gca,'fontsize',3);
% Save plot
saveas(gcf,[webdir 'small_' varStr '.png']);

%% Generate large plot version
% Reset paper size
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% Reset axes position
set(gca,'Position',[0.08 0.1 0.8 0.8]);

% Reset font size
set(gca,'fontsize',7);% Reset paper size and font size for large plot version

% Add title, resize x and y axis labels
title(varTitle,'fontsize',9);
xlabel(x_lab,'fontsize',8);
ylabel(AX(1),y_lab{1},'fontsize',10);
ylabel(AX(2),y_lab{2},'fontsize',10);

% Save to file
saveas(gcf,[webdir varStr '.png']);
close
