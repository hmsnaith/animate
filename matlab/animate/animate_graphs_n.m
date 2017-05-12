function animate_graphs_n(varTitle,varStr,y_lab,varYlim,x,y)
% Plot a small and large version of n subplots as png for given parameter for several instruments
% Input:
%   varTitle: Plot title
%   varStr: string to use to name output plots
%   ylab: strings to use for y axis labels (one line for each input array)
%   varYlim: if not empty, used to limit y axis
%   x, y: cell arrays of x and y data to plot, one array / plot
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
nps = length(x);
% For each input cell array
for i=1:nps;
  % As long as we have data for this 
  if ~isempty(x{i})
    % increment plot count
    p = p+1;
    % plot variable
    subplot(nps,1,i);
    plot(x{i},y{i},'-','Color',c(i,:));
    % If we are limiting Y axis, do it here
    if exist('varYlim','var') && ~isempty(varYlim), ylim(varYlim); end
    % Add y axis label
    ylabel(y_lab{i},'fontsize',10);
    % Set tickmarks and x axis
    set(gca,'XMinorTick','Off')
    datetick('x','dd/mm');
    % Set font size
    set(gca,'fontsize',4);
  end
end
%% Generate small plot version
% Set paper size
set(gcf,'paperunits','inches','paperposition',[0 0 3.5 2]);
% Save plot
saveas(gcf,[webdir 'small_' varStr '.png']);

%% Generate large plot version
% Reset paper size
set(gcf,'paperunits','inches','paperposition',[0 0 7 4]);

% Reset font size
set(gca,'fontsize',8);

% Add title, x and y axis labels
title(varTitle,'fontsize',10);
xlabel(x_lab,'fontsize',8);

% Save to file
saveas(gcf,[webdir varStr '.png']);
close
