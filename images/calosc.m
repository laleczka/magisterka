clear all
% %% Dla 1 i 7 Hz
table.rat = {'kontrola43', 'kontrola44', 'kontrola45', 'kontrola46', 'kontrola47', 'kontrola55'}; %dla 1 i 7 Hz
table.chans = {[1,3,5,7,9,11,12],[1,3,5,6,8,10,12],[1,2,4,5,8,10,12],[1,3,5,6,8,10,12],[1,2,5,7,8,9,10],1:7}; %dla 1 i 7 Hz

% %% Dla 2, 4 i 10 Hz 
% table.rat = {'kontrola43', 'kontrola44', 'kontrola45', 'kontrola46', 'kontrola55'}; %dla 2,4,10 Hz
% table.chans = {[1,3,5,7,9,11,12],[1,3,5,6,8,10,12],[1,2,4,5,8,10,12],[1,3,5,6,8,10,12],1:7};%dla 2,4,10 Hz

%% Dla 12 Hz
% table.rat = {'kontrola46', 'kontrola47', 'kontrola55'}; %dla 12 Hz
% table.chans = {[1,3,5,6,8,10,12],[1,2,5,7,8,9,10],1:7}; %dla 12 Hz

%% Poszczegolne czêstoœci
% table.vep = {25, 1, 1, 1, 4, 4}; % vepy dla 1 Hz
table.vep = {7, 7, 7, 4, 1, 5}; % vepy dla 7 Hz
% table.vep = {13,14,13,7,9}; %vepy dla 2 Hz
% table.vep = {19,20,19,10,8}; %vepy dla 10 Hz
% table.vep = {31,26,25,13,7}; %vepy dla 4 Hz
% table.vep = {22,7,6}; %vepy dla 12 Hz

%% [1,3,5,7,9,11,12]
%% [1,2,5,7,8,9,10]
deep = [0.2,0.35,0.5,0.6,0.7,0.8,0.9,1.1,1.35,1.6,1.8,2]-0.2; % elektroda V
deep2 = [0.2, 0.5, 0.7, 0.8, 0.95, 1.15, 1.35, 1.65]-0.2; % elektroda VIII

trig_no = 40; 
Fs = 1000;

[b,a] = butter(1, 100/(Fs/2), 'low');
[d,c] = butter(1, [45 55]/(Fs/2), 'stop');
[f,e] = butter(1, 1/(Fs/2), 'high');
 
for v = 1:length(table.rat)
    path_data = ['D:\Doœwiadczenia\data matlab\kontrola\',table.rat{v},'\'];
    path_trig = ['D:\Doœwiadczenia\data multichannel\kontrola\',table.rat{v},'\'];
    x = load([path_data,table.rat{v},'_',sprintf('%.2d', table.vep{v}),'.mat']);
    s = size(x.all_data);
    chan_no = s(1);
    
    for ch=1:chan_no
        x.all_data(ch,:) = filtfilt(b,a, x.all_data(ch,:));
        x.all_data(ch,:) = filtfilt(d,c, x.all_data(ch,:));
        x.all_data(ch,:) = filtfilt(f,e, x.all_data(ch,:));
    end
    
    table.dataNN{v} = x.all_data;
  
    for ch=1:chan_no
        table.data{v}(ch,:) = (x.all_data(ch,:) - mean(x.all_data(ch,:)))/std(x.all_data(ch,:));
    end
    
    trig =  get_trig_from_dat_file([path_trig,table.rat{v},'_',sprintf('%.2d', table.vep{v}),'.dat']);
    trig_start = [];
    next = 1;

    while length(trig_start)<trig_no
        trig_start = [trig_start, next];
        next = find(trig>trig(next)+5*Fs,1);
    end
    
    ctrl(v).freq = (trig_start(2)-trig_start(1))/5;
    table.trigger{v} = trig(trig_start);


    

before = -0.5;
after = 5.5;
s = size(table.data{v});
chan_no = s(1);


    for ch=1:chan_no
        for t=1:trig_no
            table.trialNN{v}(ch,:,t) = table.dataNN{v}(ch, before*Fs+table.trigger{v}(t):after*Fs+table.trigger{v}(t));
            table.trial{v}(ch,:,t) = table.data{v}(ch, before*Fs+table.trigger{v}(t):after*Fs+table.trigger{v}(t));
        end
    end
end

x_ax = before:1/Fs:after;

%% Przyk³adowy szczur dla którego dokonano wyboru 7 kana³ów z 12
% v = 4;
% chans = [1:5,7,6,8:12];
% figure('units','normalized','outerposition',[0 0 0.3 1])
% ha = tight_subplot(12,1,[.01 .01],[.1 .03],[.1 .05]);
% for ch=1:12
%     axes(ha(ch))
%     if find(ch==table.chans{v})~=0
%         plot(before:1/Fs:after-1/Fs, mean(table.trial{v}(chans(ch),:,:),3), 'linewidth', 1.2)
%     else
%         plot(before:1/Fs:after-1/Fs, mean(table.trial{v}(chans(ch),:,:),3))
%     end
%     ylim([-2 2])
%     if ch~=12
%         set(gca, 'xtick',[],'ytick',[])
% %         if ch==2
% %             ylabel('Amplitude [a.u.]')
% %         end
%     else
%         xlabel('Time [s]')
%         set(gca, 'ytick',[])
%     end
%     if find(ch==table.chans{v})~=0
%         ylabel([num2str(deep(ch))], 'fontweight', 'bold')
%     else
%         ylabel(deep(ch))
%     end
%     set(gca, 'fontsize', 15)
% end

%% Szereg okienek
% figure('units','normalized','outerposition',[0 0 1 1])
% ha = tight_subplot(7,length(table.vep),[.03 .03],[.03 .03],[.05 .05]);
% i = 1;
% for ch=1:7
% %     figure('units','normalized','outerposition',[(1/length(table.vep))*(v-1) 0 (1/length(table.vep)) 1])
% %     ha = tight_subplot(7,1,[.03 .03],[.03 .03],[.05 .05]);
%     
%     for v=1:length(table.vep)
%         axes(ha(i))
% %         kupa = NaN(1001,1);
% %         kupa(round(amp(v,ch,2)+(-before+0.1)*Fs+1)) = amp(v,ch,1);
%         plot(x_ax, mean(table.trial{v}(table.chans{v}(ch),:,:),3))
% %         hold on
% %         plot(x_ax, kupa, '.', 'markersize', 10)
%         xlim([before after])
%         ylabel(table.chans{v}(ch))
%         ylim([-2.5 2.5])
%         if ch==1
%             title(table.rat{v})
%         end
%         i = i+1;
%     end
% end

%% Na jednym rysunku œrednie ze wszystkich szczurów i œrednia ogólna jako poszczególne linie
% figure('units','normalized','outerposition',[0 0 0.2 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.1 .05]);
% srednie = zeros(7, (after-before)*Fs+1, 6);
% % labels = {'0.2 - 0.3', '0.35 - 0.5', '0.6 - 0.7', '0.8 - 0.9', '0.95-1.35', '1.4 - 1.6', '1.6 - 2'};
% labels = {'Ch 1', 'Ch 2', 'Ch 3', 'Ch 4', 'Ch 5', 'Ch 6', 'Ch 7'};
% c = cool(6);
% for ch=1:7
% %     od = 3;
% %     do = -1;
%     zakres = [];
%     for v=1:6
%         axes(ha(ch))
%         srednie(ch, :, v) = mean(table.trial{v}(table.chans{v}(ch),:,:),3);
%         plot(x_ax, mean(table.trial{v}(table.chans{v}(ch),:,:),3),'color',[0.6 0.7 0.9])
%         hold on
%         if v~=6
%             zakres = [zakres, deep(table.chans{v}(ch))];
%         else
%             zakres = [zakres, deep2(table.chans{v}(ch))];
% %             set(gca, 'ytick', [])
%         end
% %         ylabel(deep(table.chans{v}(ch)))
%         ylabel(labels{ch}, 'fontsize', 13)
%         ylim([-2 2])
%         xlim([before after])
%     end
%     hold on
%     plot(x_ax, mean(srednie(ch,:,:),3), 'linewidth', 1.2,'Color',[0.3 0.4 0.9])
%     if ch ~= 7
%         set(gca, 'xtick', [], 'ytick', [])
%     else
%         xlabel('Time [s]', 'fontweight', 'bold')
%         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 14)
%     
% end
% hold off
%% Na jednym rysunku œrednia dla 1 szczura i pojedyncze triale jako poszczególne linie
% figure('units','normalized','outerposition',[0 0 0.2 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.1 .05]);
% srednie = zeros(7, (after-before)*Fs+1, 6);
% % labels = {'0.2 - 0.3', '0.35 - 0.5', '0.6 - 0.7', '0.8 - 0.9', '0.95-1.35', '1.4 - 1.6', '1.6 - 2'};
% labels = {'Ch 1', 'Ch 2', 'Ch 3', 'Ch 4', 'Ch 5', 'Ch 6', 'Ch 7'};
% c = cool(6);
% v = 4;
% for ch=1:7
%     axes(ha(ch))
%     plot(x_ax, squeeze(table.trial{v}(table.chans{v}(ch),:,[4:7:end])),'color',[0.7 0.8 1])
%     hold on    
%     plot(x_ax, mean(table.trial{v}(table.chans{v}(ch),:,:),3) , 'linewidth', 1.3,'Color',[0.3 0.4 0.8])
%     if ch ~= 7
%         set(gca, 'xtick', [], 'ytick', [])
%     else
%         xlabel('Time [s]', 'fontweight', 'bold')
%         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 14)
%     ylabel(labels{ch}, 'fontsize', 13)
%     ylim([-3 3])
%     xlim([before after])
% end
    
% hold off

%% Amplituda pierwszego piku dla wszystkich zwierzaków
% amp = zeros(length(table.vep), 7,2);
% for v=1:length(table.vep)
%     for ch=1:7
% %         segment = mean(table.trial{v}(table.chans{v}(ch),-before*Fs+1:-before*Fs+200,:),3);
% %         segment = mean(table.trial{v}(table.chans{v}(ch),(-before+0.2)*Fs+1:(-before+0.2)*Fs+300,:),3); %2 pik
%         segment = mean(table.trial{v}(table.chans{v}(ch),441:600,:),3);
%         pks = max(abs(segment));
%         locs = find(abs(segment) == pks);
% %         if v==6 && ch == 4
% %             pks = min(segment);
% %             locs = find(segment == pks);
% %         end
%         amp(v,ch,1) = segment(locs);
%         amp(v,ch,2) = locs;
%     end
% end

%% Amplituda w postaci kwadratów w zale¿noœci od g³êbokoœci
% figure()
% deep2 = [0.2, 0.5, 0.7, 0.8, 0.95, 1.15, 1.35, 1.65];
% c = cool(6); 
% for v=1:6
% %     if v ~= 6
% %         plot(deep(table.chans{v}), amp(v,:,1), '-s', 'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
% %     else
% %         plot(deep2(table.chans{v}), amp(v,:,1), '-s',  'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
% %     end
%     
%     plot(amp(v,:,1), '-s', 'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
%     hold on
% end
% hold off
% xlabel('Depth [mm]', 'fontweight', 'bold')
% ylabel('Amplitude [a.u.]', 'fontweight', 'bold')
% % xlim([0 2.2])
% ylim([-2 2])
% % set(gca, 'fontsize', 13, 'ytick', -2:0.5:2, 'xtick', 0:0.2:2.2)
% legend(table.rat)



% figure()
% boxplot(amp(:,:,1), 'labels', labels)% deep(table.chans{4}))
% ylim([-3.5 2.5])



% hold on
% plot(amp(:,:,1)','.','markersize',20)
% legend(table.rat)

% legend('1','2','3','4','5','6')
% barwitherr(std(amp(:,:,1),0,1),mean(amp(:,:,1),1))


%         [pks,locs] = findpeaks(mean(table.trial{v}(ch,201:300,:),3));
%         amp(v,ch,1) = max(kupa);
%         amp(v,ch,2) = min(kupa);
%         if max(mean(table.trial{v}(chans(ch),201:300,:),3))> abs(min(mean(table.trial{v}(chans(ch),201:300,:),3)));
%             amp(v,ch) = max(mean(table.trial{v}(chans(ch),201:300,:),3));
%         else
%             amp(v,ch) = min(mean(table.trial{v}(chans(ch),201:300,:),3));
%         end
%     end
%     amp(v,:) =  max(abs(mean(table.trial{v}(chans,201:300,:),3))');
% end

%% Zaznaczenie co rozumiem przez pierwszy i drugi pik.
% srednie = zeros(7, (after-before)*Fs+1, length(table.vep));
% for ch=1:7
%     for v=1:length(table.vep)
%         srednie(ch, :, v) = mean(table.trial{v}(table.chans{v}(ch),:,:),3);  
%     end
% end
% 
% x = [x_ax, x_ax(end:-1:1)]; 
% yy1 = [zeros(200,1); ones(101,1)*-2; zeros(700,1)];
% yy2 = [zeros(200,1); ones(101,1)*2; zeros(700,1)];
% scale = 2.5;
% yy1 = ones(1001,1)*-scale;
% yy2 = [ones(230,1)*-scale; ones(101,1)*scale; ones(670,1)*-scale];
% yy = [yy1;yy2(end:-1:1)];   % vector of upper & lower boundaries
% 
% zz3 = [ones(440,1)*-scale; ones(161,1)*scale; ones(400,1)*-scale];
% zz = [yy1;zz3(end:-1:1)];  
% 
% figure('units','normalized','outerposition',[0 0 0.2 0.5])
% ha = tight_subplot(7,1,[.03 .03],[.13 .02],[0.05 .05]);
% x_ax = before:1/Fs:after;
% for ch=1:7
%     axes(ha(ch))
% %     plot(x_ax, mean(srednie(ch,:,:),3), 'k','linewidth', 1.2) %dla wszystkich szczurów
%     plot(x_ax, mean(table.trial{1}(table.chans{1}(ch),:,:),3), 'k','linewidth', 1.2)
%     hold on
%     fill(x,yy,[0,0.4,0.9],'LineStyle','none')
%      hold on
%     fill(x,zz,[0.4,0,0.9] ,'LineStyle','none')
%     alpha 0.2
%     xlim([before, after])
%     ylim([-2.5 2.5])
%     if ch ~= 7
%         set(gca, 'xtick', [], 'fontsize', 15)
%     else
%         xlabel('Time [s]', 'FontWeight', 'bold')%, 'fontsize', 15)
%         set(gca, 'xtick', -0.2:0.2:0.8, 'fontsize', 15)
%     end
% end

%% Pojedyncze triale + œrednia dla jednego zwierzaka HOLD ON
% figure('units','normalized','outerposition',[0 0 0.2 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .02],[.1 .05]);
% x_ax = before:1/Fs:after;
% v=4;
% for ch=1:7
%     axes(ha(ch))
%     plot(x_ax,squeeze(table.trial{v}(table.chans{v}(ch),:,[1,5,10])))%, 'Color',[0.6 0.7 1])
%     hold on
%     plot(x_ax,mean(table.trial{v}(table.chans{v}(ch),:,:),3), 'linewidth', 1.1, 'Color','k')%[0.1 0.1 0.9])
%     ylim([-3 3])
%     xlim([before after])
%     ylabel(deep(table.chans{v}(ch)), 'fontsize', 14)
%     if ch ~= 7
%         set(gca, 'xtick', [], 'ytick', [])
%     else
%         xlabel('Time [s]', 'FontWeight', 'bold')%, 'fontsize', 15)
%         set(gca, 'ytick', [], 'xtick', -0.2:0.2:0.8, 'fontsize', 14)
%     end
% end


%% Pojedyncze triale + œrednia dla jednego zwierzaka SUBPLOT
% figure('units','normalized','outerposition',[0 0 0.35 1])
% ha = tight_subplot(7,2,[.03 .08],[.1 .02],[.06 .05]);
% x_ax = before:1/Fs:after;
% nr = 1;
% for ch=1:7
%     for i=1:2
%         if i==1
%             axes(ha(nr))
%             plot(x_ax,squeeze(table.trial{v}(table.chans{v}(ch),:,[1,15,26])))%, 'Color',[0.6 0.7 1])
%             ylim([-4 4])
%             xlim([before after])
%             ylabel(deep(table.chans{v}(ch)), 'fontsize', 14)
%             if ch ~= 7
%                 set(gca, 'xtick', [], 'ytick', [])
%             else
%             xlabel('Time [s]', 'FontWeight', 'bold')%, 'fontsize', 15)
%             set(gca, 'ytick', [], 'xtick', -0.2:0.2:0.8, 'fontsize', 14)
%     end
%         else
%             axes(ha(nr))
%             plot(x_ax,mean(table.trial{v}(table.chans{v}(ch),:,:),3), 'linewidth', 1.1, 'Color','k')%[0.1 0.1 0.9])
%             ylim([-2 2])
%             xlim([before after])
% %             ylabel(deep(table.chans{v}(ch)), 'fontsize', 14)
%             if ch ~= 7
%                 set(gca, 'xtick', [], 'ytick', [])
%             else
%                 xlabel('Time [s]', 'FontWeight', 'bold')%, 'fontsize', 15)
%                 set(gca, 'ytick', [], 'xtick', -0.2:0.2:0.8, 'fontsize', 14)
%             end
%         end
%         nr = nr +1;
%     end
% end


%% Œrednie  + odchylenie dla pojedynczego szczura
% figure('units','normalized','outerposition',[0 0 0.2 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.1 .05]);
% v=4;
% for i=1:7
%     x = x_ax; % 100 points between intersections
%     yy1 =[mean(table.trial{v}(table.chans{v}(i),:,:),3)-std(table.trial{v}(table.chans{v}(i),:,:),0,3)]; %lower function
%     yy2 = [mean(table.trial{v}(table.chans{v}(i),:,:),3)+std(table.trial{v}(table.chans{v}(i),:,:),0,3)]; % upper function
%     x = [x,x(end:-1:1)];        % repeat x values
%     yy = [yy1,yy2(end:-1:1)];   % vector of upper & lower boundaries
%     
%     axes(ha(i))
%     plot(x_ax, mean(table.trial{v}(table.chans{v}(i),:,:),3), 'linewidth', 1.1, 'Color',[0 0 0.9])
%     hold on
%     fill(x,yy,'b', 'LineStyle','none')    % fill area defined by x & yy in blue
%     alpha 0.2
%     ylim([-3 3])
%     xlim([before after])
%  
% %     ylabel(labels{ch}, 'fontsize', 13)
% 
% %     plot(x_ax, mean(srednie(ch,:,:),3), 'linewidth', 1.2,'Color',[0.3 0.4 0.9])
%     if i ~= 7
%         set(gca, 'xtick', [], 'ytick', [])
%     else
%         xlabel('Time [s]', 'fontweight', 'bold')
%         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 14)
% end

%% Srednie + odchylenie dla wszystkich szczurów

% yy1 = [zeros(200,1); ones(101,1)*-2; zeros(700,1)];
% yy2 = [zeros(200,1); ones(101,1)*2; zeros(700,1)];
% scale = 2.5;
% yy1 = ones(1001,1)*-scale;
% yy2 = [ones(230,1)*-scale; ones(101,1)*scale; ones(670,1)*-scale];
% ww = [yy1;yy2(end:-1:1)];   % vector of upper & lower boundaries
% 
% zz3 = [ones(440,1)*-scale; ones(161,1)*scale; ones(400,1)*-scale];
% zz = [yy1;zz3(end:-1:1)];  
% 
% 
% figure('units','normalized','outerposition',[0 0 0.3 1])
% ha = tight_subplot(7,1,[.03 .03],[.08 .03],[.09 .05]);
% for i=1:7
%     x = x_ax; % 100 points between intersections
%     yy1 =[mean(srednie(i,:,:),3)-std(srednie(i,:,:),0,3)]; %lower function
%     yy2 = [mean(srednie(i,:,:),3)+std(srednie(i,:,:),0,3)]; % upper function
%     x = [x,x(end:-1:1)];        % repeat x values
%     yy = [yy1,yy2(end:-1:1)];   % vector of upper & lower boundaries
% 
%     axes(ha(i))
%     plot(x_ax,mean(srednie(i,:,:),3), 'linewidth', 1.2, 'Color',[0 0 0.9])
%     hold on
%     fill(x,yy,'b', 'LineStyle','none')    % fill area defined by x & yy in blue
% %     hold on
% %     fill(x,ww,[0,0.4,0.9],'LineStyle','none')
% %      hold on
% %     fill(x,zz,[0.4,0,0.9] ,'LineStyle','none')
%     alpha 0.2
%     ylim([-2 2])
%     xlim([before after])
% %     ylabel(labels{i})
%     if i == 7
%         xlabel('Time [s]', 'fontsize', 25)% 'fontweight', 'bold')
%         
%     elseif i == 4 
%         ylabel('Amplitude [a.u.]', 'fontsize', 25)
%         set(gca, 'xtick', [])
%     else
%         set(gca, 'xtick', [])
%       
% %         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 20)
% end

%% ANALIZA WIDMOWA! %%

%% Amplituda piku 7 i 14 Hz
ps = zeros(length(table.vep), 7, 2049);
% ps2 = zeros(7, 3001);
pmax = zeros(length(table.vep), 7, 2);
freq = 2;
for v=1:length(table.vep)
    for ch=1:7
        [p,f] = pwelch(mean(table.trial{v}(table.chans{v}(ch),:,:),3), 3*Fs, 2*Fs, [], Fs);
        ps(v,ch,:) = p;
    %     [p,f2] = furier(mean(table.trial{v}(ch,:,:),3), Fs);
    %     ps2(ch,:) = p;
        ind = find(freq -0.5<f & f<freq+0.5); 
        ind2 = find(2*freq -0.5<f & f<2*freq+0.5); 
    %     ind2 = find(freq -0.5<f2 & f2<freq+0.5); 
        pmax(v,ch,1) = max(ps(v,ch,ind));
        pmax(v,ch,2) = max(ps(v,ch,ind2));

    end

end

%% Amplituda piku 7 Hz w zale¿noœci od g³êbokoœci
% figure('units','normalized','outerposition',[0 0 0.55 0.6])
% c = cool(6); 
% for v=1:length(table.vep)
% %     if v ~= length(table.vep)
% %         plot(deep(table.chans{v}), pmax(v,:,1), '-s', 'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
% %     else
% %         plot(deep2(table.chans{v}), pmax(v,:,1), '-s',  'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
% %     end
%     plot(pmax(v,:,1), '-s',  'markersize', 7, 'MarkerFaceColor', c(v,:),'MarkerEdgeColor', c(v,:), 'color', c(v,:), 'linewidth', 1.2)
%     hold on
% end
% hold off
% xlabel('Depth [mm]', 'fontweight', 'bold')
% ylabel('Amplitude [a.u.]', 'fontweight', 'bold')
% % xlim([0 2.2])
% % ylim([-2 2])
% % set(gca, 'fontsize', 13, 'xtick', 0:0.2:2.2)% 'ytick', 0:0.5:2,
% legend(table.rat)

%% Rysowanie boxplotów amp + pik widma
% figure('units','normalized','outerposition',[0 0 0.55 0.6])
% boxplot(amp(:,:,1), 'labels', labels)
% % boxplot(pmax(:,:,2), 'labels', labels)
% xlabel('Depth [mm]', 'fontweight', 'bold')
% ylabel('Amplitude [a.u.]', 'fontweight', 'bold')
% set(gca, 'fontsize', 14)
% % ylim([-3.5 2.4])
% % ylim([-0.005 0.05])
% % title('The dependence of the amplitude of peak for second harmonic of depth')
% hold on

%% !??!
% % figure('units','normalized','outerposition',[0 0 0.4 0.5])
% % ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.08 .05]);
% % for i=1:7
% skladowa = 2;
%     x = 1:7; % 100 points between intersections
%     yy1 =[mean(pmax(:,:,skladowa),1)-std(pmax(:,:,skladowa),0,1)]; %lower function
%     yy2 = [mean(pmax(:,:,skladowa),1)+std(pmax(:,:,skladowa),0,1)]; % upper function
%     x = [x,x(end:-1:1)];        % repeat x values
%     yy = [yy1,yy2(end:-1:1)];   % vector of upper & lower boundaries
% 
% %     axes(ha(i))
%     plot(mean(pmax(:,:,skladowa),1), 'linewidth', 1.2, 'Color',[0 0 0.9])
%     hold on
%     fill(x,yy,'b', 'LineStyle','none')    % fill area defined by x & yy in blue
%     alpha 0.2
% %     ylim([0 0.004])
% %     xlim([before after])
% %     ylabel(labels{i})
% %     if i ~= 7
% %         set(gca, 'xtick', [], 'ytick', [])
% %     else
% %         xlabel('Time [s]', 'fontweight', 'bold')
% %         set(gca, 'ytick', [])
% %     end
%     set(gca, 'fontsize', 14)
% end

%% Rysowanie przebiegu widma dla szeregu okienek
% figure('units','normalized','outerposition',[0 0 1 1])
% ha = tight_subplot(7,length(table.vep),[.03 .03],[.03 .03],[.05 .05]);
% i = 1;
% for ch=1:7
% % for v=1:6
% %     figure('units','normalized','outerposition',[0.165*(v-1) 0 0.165 1])
% %     ha = tight_subplot(7,1,[.03 .03],[.03 .03],[.05 .05]);
% %     for ch=1:7
%     for v=1:length(table.vep)
%         axes(ha(i))
%         plot(f, squeeze(ps(v,ch,:)))
%         xlim([0 25])
%         ylabel(table.chans{v}(ch))
% %         ylim([-2 2])
%         if ch==1
%             title(table.rat{v})
%         end
%         set(gca, 'xtick', 0:2:25)
%         i = i + 1;
%     end
% end

%% Rysowanie przebiegu widma jako odchylenie
% figure('units','normalized','outerposition',[0 0 0.3 1])
%  ha = tight_subplot(7,1,[.03 .03],[.08 .03],[.12 .05]);
% for i=1:7
%     f_end = find(f>100, 1);
%     x = f(1:f_end); 
%     yy1 =[squeeze(mean(ps(:,i,1:f_end),1))-squeeze(std(ps(:,i,1:f_end),0,1))]; %lower function
% %     for y1 = 1:length(yy1)
% %         if yy1(y1) < 0
% %             yy1(y1) = 0;
% %         end
% %     end
%     yy2 = [squeeze(mean(ps(:,i,1:f_end),1))+squeeze(std(ps(:,i,1:f_end),0,1))]; % upper function
%     x = [x;x(end:-1:1)];        % repeat x values
%     yy = [yy1;yy2(end:-1:1)];   % vector of upper & lower boundaries
%     axes(ha(i))
%     plot(f(1:f_end),squeeze(mean(ps(:,i,1:f_end),1)), 'linewidth', 1.2, 'Color',[0 0 0.9])
%     hold on
%     fill(x,yy,'b', 'LineStyle','none')    % fill area defined by x & yy in blue
%     alpha 0.2
%     ylim([0 0.1])
%     xlim([0 25])
% %     ylabel(labels{i})
%     if i == 7
%         xlabel('Frequency [Hz]', 'fontsize', 25)% 'fontweight', 'bold')
%         set(gca, 'xtick', [0:2:24])
%     elseif i == 4 
%         ylabel('Amplitude [a.u.]', 'fontsize', 25)
%         set(gca, 'xtick', [])
%     else
%         set(gca, 'xtick', [])
%       
% %         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 20)
%     set(gca, 'ytick', [0,0.05,0.1])
% end


% for i=1:8
% plot(std(ctrl(v).trialNORM(i,:,:),0,3))
% hold on
% end
% ylim([0 1.5])
% hold off
% figure()
% ch=4;
% limit = 0;
% pmax = zeros(chan_no, length(veps),2);
% ps = zeros(chan_no, 2049, length(veps));
% for ch=1:chan_no
% for v=1:length(veps)
% %     subplot(length(veps),1,v)
%     [p,f] = pwelch(ctrl(v).norm(ch,:), 30*Fs, 10*Fs, [], Fs);
% %     if max(p)>limit
% %         limit=max(p);
% %     end
% %     plot(f,p)
% %     xlim([0 13])
% %     ylabel([num2str(ctrl(v).freq),' Hz'], 'fontweight', 'bold')
% %     title(['freq stim: ', num2str(ctrl(v).freq), ' mean freq: ', num2str(meanfreq(p,f))])
% %     ylim([0 limit*1.1])
% %     set(gca, 'xtick', 0:1:13)
% %     if v==1
% %         title('NORM')
% %     end
% %     plot(ctrl(v).data(ch,:))
%      ind = find(ctrl(v).freq -0.5<f & f<ctrl(v).freq+0.5); 
%      pmax(ch,v,1) = max(p(ind));
%      [p,f] = pwelch(mean(ctrl(v).trialNORM(ch,:,:),3), 3*Fs, 1*Fs, [], Fs);
% %      pmax(ch,v,2) = meanfreq(p,f);
%      pmax(ch,v,2) = max(p(ind));
%      ps(ch, :, v) = p;
% 
% end
% end
% % figure();plot(f,ps(1,:,5)); xlim([0 10])
% figure();
% for i=1:6
%     subplot(2,3,i)
%  bar([pmax(1:7,freq_order(i),1),pmax(1:7,freq_order(i),2)*100] )
% legend('all', 'mean')
% title(names{i})
% end
% [p1,f] = pwelch(ctrl(1).data(1,:),30*Fs,20*Fs,[],Fs);
% % [p2,f] = pwelch(ctrl(2).data(1,:),30*Fs,20*Fs,[],Fs);
% % [p3,f] = pwelch(ctrl(3).data(1,:),30*Fs,20*Fs,[],Fs);
% plot(f,p1);xlim([0 20]);legend('1','2','3')
% 
% ps = zeros(24,2049,length(veps));
% ps2 = zeros(24,16385,length(veps));
% for ch =1:24
%     for v=1:length(veps)
%         [p,f] = pwelch(mean(dataTrial_NN(ch,:,:,v),3),4*Fs,3*Fs,[],Fs);
%         ps(ch,:,v) = p;
% %         [p,f] = pwelch(ctrl(v).data(ch,:,v),30*Fs,20*Fs,[],Fs);
% %         ps2(ch,:,v) = p;
%     end
% end
% 
% for ch=13:24
% for v=1:2
% pik(ch-12,v) = max(ps(ch,29:31,v));
% end
% end
% 
% bar(pik(:,1))
% legend('0.1V','1V')
% legend('0.1V','0.2V','0.3V')

% % plot(squeeze(mean(dataTrial_NN(3,:,:,6),3)))
% figure();
% plot(f,squeeze(ps([1:12]+12,:,1)))
% xlim([0 20])
% legend('1','2','3','4','5','6','7','8','9','10','11','12');%,'5','6')



% ylim([0 10^(-8)])
% title('przed stym prawa kora 3 kanaly')
% % legend('1','2','3','4','6','7','8','10','11','12');%,'4','5','6','7','8','9')

% bar(squeeze(ps(1:12,5,:)));legend('1','2','3')

% ch = 7;

% ps = zeros(4,16385,4,3);
% for v=1:4
%     for i=1:3
%         [p1,f] = pwelch(ctrl(v).data(ch,ctrl(v).trigger(round(100*(i-1)/3)+1):ctrl(v).trigger(round(100*i/3))),30*Fs,20*Fs,[],Fs);
%         [p2,f] = pwelch(all_data(v).s30(ch,ctrl(v).trigger(round(100*(i-1)/3)+1):ctrl(v).trigger(round(100*i/3))),30*Fs,20*Fs,[],Fs);
%         [p3,f] = pwelch(all_data(v).s200(ch,ctrl(v).trigger(round(100*(i-1)/3)+1):ctrl(v).trigger(round(100*i/3))),30*Fs,20*Fs,[],Fs);
%         [p4,f] = pwelch(all_data(v).all(ch,ctrl(v).trigger(round(100*(i-1)/3)+1):ctrl(v).trigger(round(100*i/3))),30*Fs,20*Fs,[],Fs);
%         ps(1,:,v,i) = p1;
%         ps(2,:,v,i) = p2;
%         ps(3,:,v,i) = p3;
%         ps(4,:,v,i) = p4;
%     end
% end

% 
% subplot(2,3,1);
% plot(squeeze(mean(dataTrial_all(ch,:,1:33,:),3)))
% title(['all ch ', num2str(ch), ' trials 1-33'])
% subplot(2,3,2);
% plot(squeeze(mean(dataTrial_all(ch,:,34:66,:),3)))
% title(['all ch ', num2str(ch), ' trials 34-66'])
% subplot(2,3,3);
% plot(squeeze(mean(dataTrial_all(ch,:,67:100,:),3)))
% title(['all ch ', num2str(ch), ' trials 67-100'])
% for i=1:3
%     subplot(2,3,3+i)
%     plot(f,squeeze(ps(4,:,:,i)))
%     xlim([0 10])
% end

% dl = min([length(ctrl(1).data(ch,:)), length(ctrl(2).data(ch,:)), length(ctrl(3).data(ch,:)), length(ctrl(4).data(ch,:))]);
% ha = tight_subplot(6,1,[.075 .03],[.05 .05],[.01 .01]);
% % figure();
% for v=1:6
% %     subplot(6,1,v)
%     axes(ha(v))
%     bodzce1 = zeros(length(ctrl(v).data(ch,:)),1);
%     bodzce1(ctrl(v).trigger([1,33])) = max(all_data(v).all(ch,:));
%     bodzce1(ctrl(v).trigger([1,33])+1) = min(all_data(v).all(ch,:));
%     
%     bodzce2 = zeros(length(ctrl(v).data(ch,:)),1);
%     bodzce2(ctrl(v).trigger([34,66])) = max(all_data(v).all(ch,:));
%     bodzce2(ctrl(v).trigger([34,66])+1) = min(all_data(v).all(ch,:));
%     
%     bodzce3 = zeros(length(ctrl(v).data(ch,:)),1);
%     bodzce3(ctrl(v).trigger([67,100])) = max(all_data(v).all(ch,:));
%     bodzce3(ctrl(v).trigger([67,100])+1) = min(all_data(v).all(ch,:));
%     
% %     plot(all_data(v).all(ch,:));
%     plot(ctrl(v).data(ch,:))
% %     hold on
% %     plot(bodzce1)
% %     hold on
% %     plot(bodzce2)
% %     hold on
% %     plot(bodzce3)
%     xlim([1 dl])
%     title(['NN ch', num2str(ch), ' rejestracja ', num2str(veps(v))])
% end
% 
% ch = 12;
% subplot(2,2,1);
% plot(squeeze(mean(dataTrial_NN(ch,:,:,:),3)))
% title('NN')
% subplot(2,2,2)
% plot(squeeze(mean(dataTrial_30s(ch,:,:,:),3)))
% title('30s')
% subplot(2,2,3)
% plot(squeeze(mean(dataTrial_200(ch,:,:,:),3)))
% title('200')
% subplot(2,2,4)
% plot(squeeze(mean(dataTrial_all(ch,:,:,:),3)))
% title('all')
% legend('1','2','3','4','5','6')



% ch=7;
% ps = zeros(4,16385,6);
% for v=1:6
%     [p1,f] = pwelch(ctrl(v).data(ch,:),30*Fs,20*Fs,[],Fs);
%     [p2,f] = pwelch(all_data(v).s30(ch,:),30*Fs,20*Fs,[],Fs);
%     [p3,f] = pwelch(all_data(v).s200(ch,:),30*Fs,20*Fs,[],Fs);
%     [p4,f] = pwelch(all_data(v).all(ch,:),30*Fs,20*Fs,[],Fs);
%     ps(1,:,v) = p1;
%     ps(2,:,v) = p2;
%     ps(3,:,v) = p3;
%     ps(4,:,v) = p4;
% end
% names = {'NN','30s','200','all'};    
% for i=1:4
%     subplot(2,2,i)
%     plot(f,squeeze(ps(i,:,:)));
%     title(names{i})
%     xlim([0 10])
%     if i==4
%         legend('1','2','3','4','5','6')
%     end
% end
% 
% 
% 
% 




% ch = 10;
% 
% bodzce = zeros(length(ctrl(1).data(ch,:)),1);
% bodzce(ctrl(1).trigger) = max(ctrl(1).data(ch,:));
% bodzce(ctrl(1).trigger+1) = min(ctrl(1).data(ch,:));
% 
% bodzce2 = zeros(length(ctrl(1).data(ch,:)),1);
% bodzce2(ctrl(1).trigger) = max(all_data(1).s30(ch,:));
% bodzce2(ctrl(1).trigger+1) = min(all_data(1).s30(ch,:));
% 
% bodzce3 = zeros(length(ctrl(1).data(ch,:)),1);
% bodzce3(ctrl(1).trigger) = max(all_data(1).s200(ch,:));
% bodzce3(ctrl(1).trigger+1) = min(all_data(1).s200(ch,:));
% 
% 
% bodzce4 = zeros(length(ctrl(1).data(ch,:)),1);
% bodzce4(ctrl(1).trigger) = max(all_data(1).all(ch,:));
% bodzce4(ctrl(1).trigger+1) = min(all_data(1).all(ch,:));
% 
% przebieg1 = 31*Fs:51*Fs-1;
% przebieg2 = 1200*Fs:1220*Fs-1;
% 
% subplot(4,2,1)
% plot(ctrl(1).data(ch,przebieg1))
% hold on
% plot(bodzce(przebieg1))
% title('NN')
% 
% subplot(4,2,2)
% plot(all_data(1).s30(ch,przebieg1))
% hold on
% plot(bodzce2(przebieg1))
% title('30s')
% 
% subplot(4,2,5)
% plot(ctrl(1).data(ch,przebieg2))
% hold on
% plot(bodzce(przebieg2))
% title('NN')
% 
% subplot(4,2,6)
% plot(all_data(1).s30(ch,przebieg2))
% hold on
% plot(bodzce2(przebieg2))
% title('30s')
% 
% subplot(4,2,3)
% plot(all_data(1).s200(ch,przebieg1))
% hold on
% plot(bodzce3(przebieg1))
% title('200')
% 
% subplot(4,2,4)
% plot(all_data(1).all(ch,przebieg1))
% hold on
% plot(bodzce4(przebieg1))
% title('all')
% 
% subplot(4,2,7)
% plot(all_data(1).s200(ch,przebieg2))
% hold on
% plot(bodzce3(przebieg2))
% title('200')
% 
% subplot(4,2,8)
% plot(all_data(1).all(ch,przebieg2))
% hold on
% plot(bodzce4(przebieg2))
% title('all')





% veps = [1,4,2,13:15, 24:26];
% for j = 1:length(veps)
%     ps = zeros(12,8193);
%     for v=1:12
%         [p,f] = pwelch((stim05(veps(j)).data(1,(v-1)*30*Fs+1:v*30*Fs)-mean(stim05(veps(j)).data(1,:)))/std(stim05(veps(j)).data(1,:)),10*Fs, 5*Fs, [], Fs);
%         ps(v,:) = p;
%     end
% 
% 
% 
%     %           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%     %           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
% 
%     path_prints = 'D:\Doœwiadczenia\analiza\stim05\';
% 
%     figure('units','normalized','outerposition',[0 0 1 1])
%     ha = tight_subplot(3,4,[.075 .03],[.05 .05],[.01 .01]);
%     limit = 1.1*max(max(ps));
%     for i=1:12
%         axes(ha(i))
%         plot(f,squeeze(ps(i,:))')
%         xlim([0 10])
%         ylim([0 limit])
%         title(num2str(i))
%     %     if i<9
%     %         set(gca,'xtick',[],'ytick',[])
%     %     else
%     if i == 1 || i == 5 || i == 9
%         set(gca, 'ytick',[])
%     end
%             set(gca, 'XTick',1:10)
%     %     end
%     %     legend('1','2','3')
%     end
%     print([path_prints, rat, '_', sprintf('%.2d', veps(j)), '_7Hz_spectrum_every_30_s'], '-dpng')
% end


%% Przyk³adowy szczur dla którego dokonano wyboru 7 kana³ów z 12
% for v=1:6
% figure('units','normalized','outerposition',[0.165*(v-1) 0 0.165 1])
% % figure('units','normalized','outerposition',[0 0 0.3 1])
% ha = tight_subplot(7,1,[.01 .01],[.1 .03],[.1 .05]);
% for ch=1:7
%     axes(ha(ch))
%     rectangle('Position',[0,-2,5,4],'FaceColor',[0.9 .9 .9],'EdgeColor',[0.9 .9 .9], 'LineWidth',0.1)
%     hold on
%     plot(before:1/Fs:after, mean(table.trial{v}(table.chans{v}(ch),:,:),3))
%     ylim([-2 2])
%     xlim([before after])
%     if ch~=7
%         set(gca, 'xtick',[],'ytick',[])
% %         if ch==2
% %             ylabel('Amplitude [a.u.]')
% %         end
%     else
%         xlabel('Time [s]')
%         set(gca, 'ytick',[], 'xtick', 0:1:5)
%     end
%     if v == 1
%         ylabel(labels(ch))
%     end
%         
% %     if v~=6
% %         ylabel(deep(table.chans{v}(ch)))
% %     else
% %         ylabel(deep2(table.chans{v}(ch)))
% %     end
% 
%     set(gca, 'fontsize', 15)
% end
% end

% figure('units','normalized','outerposition',[0 0 0.4 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.08 .05]);
% srednie = zeros(7, 6001, 6);
% labels = {'0.2 - 0.3', '0.35 - 0.5', '0.6 - 0.7', '0.8 - 0.9', '0.95-1.35', '1.4 - 1.6', '1.6 - 2'};
% c = cool(6);
% for ch=1:7
%     zakres = [];
%     for v=1:length(table.vep)
%         srednie(ch, :, v) = mean(table.trial{v}(table.chans{v}(ch),:,:),3);
%         if v~=8
%             zakres = [zakres, deep(table.chans{v}(ch))];
%         else
%             zakres = [zakres, deep2(table.chans{v}(ch))];
% %             set(gca, 'ytick', [])
%         end
%     end
% end
% 

%% Fajowe cienie

% figure('units','normalized','outerposition',[0 0 0.4 1])
% ha = tight_subplot(7,1,[.03 .03],[.1 .03],[.08 .05]);
% for i=1:7
%     x = x_ax; % 100 points between intersections
%     yy1 =[mean(srednie(i,:,:),3)-std(srednie(i,:,:),0,3)]; %lower function
%     yy2 = [mean(srednie(i,:,:),3)+std(srednie(i,:,:),0,3)]; % upper function
%     x = [x,x(end:-1:1)];        % repeat x values
%     yy = [yy1,yy2(end:-1:1)];   % vector of upper & lower boundaries
% 
%     axes(ha(i))
%     plot(x_ax,mean(srednie(i,:,:),3), 'linewidth', 1.2, 'Color',[0 0 0.9])
%     hold on
%     fill(x,yy,'b', 'LineStyle','none')    % fill area defined by x & yy in blue
%     alpha 0.2
%     ylim([-2 2])
%     xlim([before after])
%     ylabel(labels{i})
%     if i ~= 7
%         set(gca, 'xtick', [], 'ytick', [])
%     else
%         xlabel('Time [s]', 'fontweight', 'bold')
%         set(gca, 'ytick', [])
%     end
%     set(gca, 'fontsize', 14)
% end

%% CSD!!!


%% Current Source Density
% v = 1;
% table.chans{v} = [2, 4, 6, 8, 10, 12, 13]-1;
% elPos = [0.2,0.35,0.5,0.6,0.7,0.8,0.9,1.1,1.35,1.6,1.8,2]; %pozycje elektrody V - w wiêkszoœci lewa kora
% % elPos = [0.2, 0.5, 0.7, 0.8, 0.95, 1.15, 1.45];  % elektroda VIII
% elPos = elPos(table.chans{v});
% % pots = mean(table.trial{v}(table.chans{v},:,:),3)*-1; %[1:5,7,6,8:12]
% pots = mean(srednie(:,:,:),3)*-1; %[1:5,7,6,8:12]
% X = 0:0.01:2.1;
% k = kCSD1d(elPos, pots, 'X', X);
% k.estimate;
% figure
% 
% % chans = [1:9,11:12];
% %% elektroda V
% ydis = ([0,0.2,0.35,0.5,0.6,0.7,0.8,0.9,1.1,1.35,1.6,1.8,2])*100+1;
% ylab = {'0','0.2','0.35','0.5','0.6','0.7','0.8','0.9','1.1','1.35','1.6','1.8','2'};
% %% elektroda VIII
% % ydis = [0.2, 0.5, 0.7, 0.8, 0.95, 1.15, 1.45]*100;  
% % ylab = {'0.2', '0.5', '0.7', '0.8', '0.95', '1.15', '1.45'}; 
% % load('mycmap.mat');
% ha = tight_subplot(1,1,[.03 .03],[.15 .03],[.15 .03]);
% axes(ha(1))
% imagesc(k.csdEst); colormap jet %colormap(gcf,mycmap)  
% 
% set(gca, 'ytick', ydis([1,table.chans{v}+1]))  %[0.2,0.35,0.5,0.6,0.7,0.8,0.9,1.1,1.35,1.6,1.8,2]
% set(gca, 'yticklabels', ylab([1,table.chans{v}+1]))
% ylabel('Depth [mm]', 'fontweight', 'bold')
% xlabel('Time [s]', 'fontweight', 'bold')
% legend
% % set(gca, 'ytick', ydis)% 1:20:210)  %[0.2,0.35,0.5,0.6,0.7,0.8,0.9,1.1,1.35,1.6,1.8,2]
% % set(gca, 'yticklabels', ylab(table.chans{v}))
% 
% set(gca, 'xtick', 0:500:6000, 'xticklabels', before:0.5:after)
% set(gca, 'fontsize', 15)
% ylim([1 190])
% grid on
% % tit = [rat, 'vep ',num2str(veps),' left cortex 1 Hz 1 second CSD ',num2str(length(chans)),' chans mV'];
% % title(tit)
% % path = 'D:\Doœwiadczenia\analiza\17.08.22\';
% % print([path, tit],'-dpng')
