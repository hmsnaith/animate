function animate_graphs(varTitle,varStr,y_lab,legend_M,varYlim,x,y)
% Plot a small and large graph as png for given parameter for several instruments
% Input:
%   varTitle: Plot title
%   varStr: string to use to name output plots
%   ylab: string to use for y axis label
%   legend_M: legend text (one line for each input array)
%   varYlim: if not empty, used to limit y axis
%   x, y: cell arrays of x and y data to plot
%
% the x axis label and directory to output graphs are set in global
% variables x_lab and webdir
global webdir x_lab

%% Setup a new figure - visibility off for batch use
figure('visible','off');
% figure
% Set axes and size for small figure
% hax=axes('Position',[0 0 1 1],'visible','off');
hax=axes('Position',[0 0 1 1]);
% Get axes colour order for plotting
c = get(gca,'ColorOrder');
% Set up an empty legend text array
lgnd = char(zeros(size(legend_M)));

%% Plot data
p = 0;
hold on
% For each input cell array
for i=1:length(x);
  % As long as we have data for this 
  if ~isempty(x{i})
    % increment plot count
    p = p+1;
    % Save the legend text for this line
    lgnd(p,:) = legend_M(i,:);
    % plot variable
    plot(x{i},y{i},'-','Color',c(i,:));
  end
end
% If we are limiting Y axis, do it here
if exist('varYlim','var') && ~isempty(varYlim), ylim(varYlim); end

% Set tickmarks and x axis
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');

%% Generate small plot version
% Set paper size
set(gcf,'paperunits','inches','paperposition',[0 0 1.9 1]);
% Define axes position
set(gca,'Position',[0.08 0.15 0.9 0.9]);
% XTICK=get(gca,'XTick');
% [~, xcols]=size(XTICK);
% for j=1:xcols;
%   XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
%   for k=1:6, XTICKLAB(j,k)=XTL(1,k); end
% end;
%set(gca,'XTickLabel',XTICKLAB);
% Set font size
set(gca,'fontsize',3);
% set(gcf,'CurrentAxes',hax);
% Save plot
saveas(gcf,[webdir 'small_' varStr '.png']);

%% Generate large plot version
% clf;
% figure('visible','off');
% Reset paper size
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% hax=axes('Position',[0 0 1 1],'visible','off');
% axes('Position',[0.08 0.1 0.9 0.85]);
% Reset axes position
set(gca,'Position',[0.08 0.1 0.9 0.85]);
% plot(x,y,'-');

% Reset font size
set(gca,'fontsize',7);% Reset paper size and font size for large plot version

% Add legend with reduced font
hlegend=legend(lgnd(1:p,:),'location','NorthEast');
set(hlegend,'FontSize',6);

% Add X tick labelling
% set(gca,'XMinorTick','Off')
% datetick('x','dd/mm');
XTICK=get(gca,'XTick');
[~, xcols]=size(XTICK);
for j=1:xcols;
  XTL=[datestr(XTICK(1,j),'dd') '-' datestr(XTICK(1,j),'mmm')];
  for k=1:6, XTICKLAB(j,k)=XTL(1,k); end
end
set(gca,'XTickLabel',XTICKLAB);

% Add title, x and y axis labels
title(varTitle,'fontsize',10);
xlabel(x_lab,'fontsize',8);
ylabel(y_lab,'fontsize',10);
% set(gcf,'CurrentAxes',hax);
% if exist('varYlim','var') && ~isempty(varYlim), ylim(varYlim); end

% Save to file
saveas(gcf,[webdir varStr '.png']);
close
