blank = zeros(dl*Fs,1);
Fs = 1000;
dl = 50;


stym1 = zeros(dl*Fs,1);
ods1 = 0.2*Fs;
c = 1;
i = 4230;

while i<(dl-1.5)*Fs
    if c == 25
        c = 1;
        stym1(i) = 1;
        stym1(i+1) = -1;
        i = i + ods1 + 4000;
        %round(rand()*3000) + 2000;
    else
        c = c+1;
        stym1(i) = 1;
        stym1(i+1) = -1;
        i = i + ods1;
    end
end

stym2 = zeros(dl*Fs,1);
ods2 = 1*Fs;
c = 1;
i = 4230;

while i<(dl-1)*Fs
    if c == 5
        c = 1;
        stym2(i) = 1;
        stym2(i+1) = -1;
        i = i + ods2+ 4000;
%         i = i + round(rand()*3000) + 2000;
    else
        c = c+1;
        stym2(i) = 1;
        stym2(i+1) = -1;
        i = i + ods2;
    end
end

stym3 = zeros(dl*Fs,1);
ods3 = 0.5*Fs;
c = 1;
i = 4230;

while i<(dl-1)*Fs
    if c == 10
        c = 1;
        stym3(i) = 1;
        stym3(i+1) = -1;
        i = i + ods3+ 4000;
%         i = i + round(rand()*3000) + 2000;
    else
        c = c+1;
        stym3(i) = 1;
        stym3(i+1) = -1;
        i = i + ods3;
    end
end


x_ax = 0:1/1000:dl-1/1000;
gr = 1.1;


figure('units','normalized','outerposition',[0.2 0.2 0.6 0.5])
ha = tight_subplot(3,1,[.0 .0],[.1 .03],[.08 .05]);

axes(ha(1))
% subplot(3,1,1)
plot(x_ax,stym2, 'linewidth', gr)
hold on
plot(x_ax,blank, 'k', 'linewidth', gr)
ylim([-2 2])
axis off

axes(ha(2))
% subplot(3,1,2)
plot(x_ax,stym3, 'linewidth', gr)
hold on
plot(x_ax,blank, 'k', 'linewidth', gr)
ylim([-2 2])
axis off

axes(ha(3))
% subplot(3,1,3)
plot(x_ax,stym1, 'linewidth', gr)
hold on
plot(x_ax,blank, 'k', 'linewidth', gr)
ylim([-2 2])
axis off