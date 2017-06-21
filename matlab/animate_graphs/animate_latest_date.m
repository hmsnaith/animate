function animate_latest_date(webdir,psuf,posdate)
% Save date as a png file
latest_date=[datestr(posdate,'dddd, dd-mmmm-yyyy, HH:MM') ' utc'];
ldText='The latest data received from the PAP site was recorded on ';
figure('visible','off');
axes('Position',[0 0 1 1], 'visible','off');
axes('Position',[0.01 0.04 1 1],'visible','off');
text('Position',[0 0],'VerticalAlignment','baseline','FontName','Helvetica',...
     'Fontsize',6,'FontWeight','bold','String',...
     [ldText ' ' '{\color{red}' latest_date '}']);
set(gcf,'paperunits','centimeters','paperposition',[0 0 11 1]);

saveas(gcf,[webdir 'animate_latest_date' psuf '.png']);
close





