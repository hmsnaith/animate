function animate_graphs_yy_1(varTitle,varStr,y_lab,varYlim,x,y)
% Plot a small and large version of 2 variables on different y axes on 1 
%   subplot and additional variable on 2nd subplot, as png
% Input:
%   varTitle: Plot title
%   varStr: string to use to name output plots
%   ylab: strings to use for y axis labels (one line for each input array)
%   varYlim: if not empty, used to limit y axis - either 1 for all or
%   1/plot
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
axes('Position',[0 0 1 1]);
% Get axes colour order for plotting
c = get(gca,'ColorOrder');
%% Plot data
nps = length(x) - 1; % Number of subplots
if nps<2
  disp('Need at least 3 variables for animate_graphs_yy_1');
end
h = zeros(1,nps);

% plot first 2 variables on yy axes on first subplot
p = 1;
h(1) = subplot(nps,1,1);
[AX] = plotyy(x{1},y{1},x{2},y{2});
% If we are limiting Y axis, do it here
% if exist('varYlim','var') && ~isempty(varYlim), ylim(varYlim); end
% Set tickmarks and x axis
set(gca,'XMinorTick','Off')
datetick('x','dd/mm');
% Set font size
set(AX(1),'fontsize',4);
set(AX(2),'fontsize',4);

% For each additional input cell array
for i=3:nps+1;
  % As long as we have data for this plot
  if ~isempty(x{i})
    % increment plot count
    p = p+1;
    % plot variable
    h(p) = subplot(nps,1,p);
    plot(x{i},y{i},'-','Color',c(1,:));
    % If we are limiting Y axis, do it here
    if exist('varYlim','var') && ~isempty(varYlim)
      if size(varYlim,1)>1
        ylim(varYlim(i,:));
      else
        ylim(varYlim);
      end
    end
    % Set font size
    set(gca,'fontsize',4);
    % Set tickmarks and x axis
    set(gca,'XMinorTick','Off')
    datetick('x','dd/mm');
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
for i=1:nps, set(h(i),'fontsize',8); end

% Add title, x & y axis labels
title(h(1), varTitle,'fontsize',10);
ylabel(AX(1),y_lab{1},'fontsize',10);
ylabel(AX(2),y_lab{2},'fontsize',10);
for i=2:nps, ylabel(y_lab{i},'fontsize',10); end

% Save to file
saveas(gcf,[webdir varStr '.png']);
close
