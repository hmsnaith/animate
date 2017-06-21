function animate_quiver(varTitle,varStr,y_lab,legend_M,varYlim,x,y,u,v)
% Plot a small and large quiver plot as png for given parameter
% Input:
%   varTitle: Plot title
%   varStr: string to use to name output plots
%   ylab: string to use for y axis label
%   legend_M: legend text (one line for each input array)
%   varYlim: if not empty, used to limit y axis
%   x, y, u, v: cell arrays of x y u & v data to plot
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
% Set up an empty legend text array
np = 0;
for i=1:length(x);
  if ~isempty(x{i}), np = np+1; end
end
if iscell(legend_M)
  lgnd = cell(1,np);
elseif ischar(legend_M)
  lgnd = char(zeros(np,length(legend_M)));
else
  lgnd = [];
end

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
    if ~isempty(legend_M)
      if iscell(legend_M)
        lgnd{p} = legend_M{i};
      else
        lgnd(p,:)=legend_M(i,:);
      end
    end
    % plot variable
    quiver(x{i},y{i},u{i},v{i},'-','Color',c(i,:));
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
% Set font size
set(gca,'fontsize',3);
% Save plot
saveas(gcf,[webdir 'small_' varStr '.png']);

%% Generate large plot version
% Reset paper size
set(gcf,'paperunits','inches','paperposition',[0 0 6.5 4]);
% Reset axes position
set(gca,'Position',[0.08 0.1 0.9 0.85]);
% Reset font size
set(gca,'fontsize',7);% Reset paper size and font size for large plot version

% % Add legend with reduced font
% if ~isempty(lgnd)
%   hlegend=legend(lgnd,'location','best');
%   set(hlegend,'FontSize',6);
% end

% Add title, x and y axis labels
title(varTitle,'fontsize',10);
xlabel(x_lab,'fontsize',8);
ylabel(y_lab,'fontsize',8);

% Save to file
saveas(gcf,[webdir varStr '.png']);
close
