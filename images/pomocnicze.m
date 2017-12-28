
x = [x_ax, x_ax(end:-1:1)]; 
yy1 = [zeros(200,1); ones(101,1)*-2; zeros(700,1)];
yy2 = [zeros(200,1); ones(101,1)*2; zeros(700,1)];
scale = 2.5;
yy1 = ones(1001,1)*-scale;
yy2 = [ones(230,1)*-scale; ones(101,1)*scale; ones(670,1)*-scale];
yy = [yy1;yy2(end:-1:1)];   % vector of upper & lower boundaries

zz3 = [ones(440,1)*-scale; ones(161,1)*scale; ones(400,1)*-scale];
zz = [yy1;zz3(end:-1:1)];  

% figure('units','normalized','outerposition',[0 0 0.2 0.5])
% ha = tight_subplot(7,1,[.03 .03],[.13 .02],[0.05 .05]);
x_ax = before:1/Fs:after;
ch = 1;
% for ch=1:7
%     axes(ha(ch))
%     plot(x_ax, mean(srednie(ch,:,:),3), 'k','linewidth', 1.2) %dla wszystkich szczurów
%     plot(x_ax, mean(table.trial{1}(table.chans{1}(ch),:,:),3), 'k','linewidth', 1.2)
    plot(f, squeeze(ps(1,4,:)), 'k','linewidth', 1.2)
%     hold on
%     fill(x,yy,[0,0.4,0.9],'LineStyle','none')
%      hold on
%     fill(x,zz,[0.4,0,0.9] ,'LineStyle','none')
%     alpha 0.2
%     xlim([before, after])
%     ylim([-2 2])
      xlim([0 25])
      ylim([0 0.15])

%         xlabel('Time [s]', 'FontWeight', 'bold')%, 'fontsize', 15)
        xlabel('Frequency [Hz]', 'FontWeight', 'bold')
        ylabel('Amplitude [a.u.]', 'FontWeight', 'bold')
%         set(gca, 'xtick', -0.2:0.2:0.8, 'fontsize', 15)
        set(gca, 'xtick', [0,3,5,7,10,12,14,16,18,21,24], 'fontsize', 15)
