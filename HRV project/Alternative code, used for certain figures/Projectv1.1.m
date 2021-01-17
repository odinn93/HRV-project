clear all; close all; clc;

% Time = SX_After/Before.Time
% ECG = SX_After/Before.ECG
% TEB = SX_After/Before.TEB

S1_Before = readtable('S1_Before.txt');
S2_Before = readtable('S2_Before.txt');
S3_Before = readtable('S3_Before.txt');
S4_Before = readtable('S4_Before.txt');
S5_Before = readtable('S5_Before.txt');

S1_After = readtable('S1_After.txt');
S2_After = readtable('S2_After.txt');
S3_After = readtable('S3_After.txt');
S4_After = readtable('S4_After.txt');
S5_After = readtable('S5_After.txt');

%% Filters
close all;
ECG = S1_After.ECG;
Time = S1_After.Time;
TEB = S1_After.TEB;
fs = length(ECG) / Time(end); %samples per second
%ECG = ECG(10000:end);  %cut motion artifact from begininng og measurement
%Time = Time(10000:end);

%b. Implement preprocessing methods with at least two approaches
%Noise and Artifacts
%-Baseline Wander
%-Powerline 50/60Hz
%-Motion artifacts

%Baseline Wander - removing the DC component of the ECG.
%lowest freq = 40 beats/min = 0.67 Hz
% From chapter 7.1 - recommended highpass filter with fc = 0.5 Hz and
% attenuation from 20-40dB
ECG1 = ECG - mean(ECG);
ECG_ts = timeseries(ECG1);
ECG_ts_filt = idealfilter(ECG_ts,[2/fs 60/fs],'pass');
ECG_ts_filt = ECG_ts_filt.Data;
ECG_ts_notch = filter(IIRnotch,ECG_ts_filt);

%ECG_ts_filt2 = filter(FIRbandpass2,ECG_ts_notch); %test
%ECG_ts_filt2 = [ECG_ts_filt2(101:end) ; ECG_ts_filt2(1:100)]; %FIR


% ECG_ts_filt2 = filter(FIRhighpass1,ECG_ts_notch);  %test
% ECG_ts_filt2 = [ECG_ts_filt2(100:end); ECG_ts_filt2(1:99)];

ECG_ts_smooth1 = smoothdata(ECG_ts_notch,'gaussian',20);


ECG_hp = filter(IIRhighpass1,ECG);
ECG_bp = filter(IIRbandpass1,ECG);

ECG2 = ECG1-ECG_hp;

%-Powerline 50/60Hz
% Sweden has: 230 V, 400 V, 50 Hz is the data from sweden?
ECG_notch = filter(IIRnotch,ECG);

ECG_hp_notch = filter(IIRnotch,ECG_hp);
ECG_bp_notch = filter(IIRnotch,ECG_bp);

% for i=1:length(ECG)
%     ECG_hp_notch_rms(i) = rms(ECG_hp_notch(i));
% end
%ECG_hp_notch_rms = ECG_hp_notch_rms';

yy = smoothdata(ECG_hp_notch,'gaussian');
yy1 = yy - mean(yy);
yy_ts = timeseries(yy1);
yy_ts_filt = idealfilter(yy_ts,[2/fs 60/fs],'pass');
yy_ts_filt = yy_ts_filt.Data;

% ECG_ts_smooth1_out = rmoutliers(ECG_ts_smooth1,'gesd');
% Time_out = Time(1: end - (length(ECG_ts_smooth1) - length(ECG_ts_smooth1_out)));

figure
plot(ECG)

figure
plot(Time,ECG_ts_filt,'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.1)
%plot(Time,ECG_ts_notch,'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3)
%plot(Time,ECG_ts_filt2,'r')
%plot(ECG_ts_smooth2,'b')
hold on
plot(Time, ECG_ts_smooth1,'r','Linewidth',1)  
%plot(Time_out, ECG_ts_smooth1_out,'b')
%axis([1 100 -50 100])
%axis([195 205 -inf inf]) %artifact S2 before
%axis([280 290 -inf inf]) %artifact S2 after

% fvtool(ECG_ts_smooth1)
% fvtool(ECG_ts_notch)

%%
fvtool(FIRhighpass1)
%% respiration
% 6 breaths per minute in bio feedback sessions = 0.1 breaths per sec.


ECG_bp = filter(IIRbandpass1,ECG);
TEB_lp = filter(TEBlowpass,TEB);

figure
plot(Time,TEB)
hold on
plot(Time,TEB_lp)



%%
figure
plot(Time,ECG,'Color',[0.7, 0.6470, 0.9410])
hold on

plot(Time,ECG1,'Color',[0, 0.4470, 0.7410])
%plot(Time,ECG_bp,'Color',[0.9290, 0.6940, 0.1250])
plot(Time,ECG_hp,'Color',[0.8500, 0.3250, 0.0980])
legend('ECG raw','ECG1','ECG bp','ECG hp')
axis([150 160 -inf inf])
xlabel('Time [s]')
ylabel('Amplitude')
title('Baseline wander')
%%
figure
plot(Time,ECG_hp, 'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3 );
hold on
plot(Time,yy,'r','Linewidth',4 )
xlabel('Time [s]')
ylabel('Amplitude')
legend('ECG hp','High pass and gaussian')
axis([155 160 -50 200])


%%
fvtool(IIRhighpass1)
fvtool(IIRnotch)
%% polyfitting test
close all;
yy = ECG_notch;
ECG_data = [];
for i=1:100:length(yy)-99
    [p,s,mu] = polyfit( (i:i+99)',yy(i:i+99),4);
    f_y = polyval(p,(i:i+99)',[],mu);

    ECG_data = [ECG_data ; yy(i:i+99) - f_y];        % Detrend data
end

for i=1:100:length(ECG_data)-3
    if i==1
        ECG_data(i) = ECG_data(i)
    else
        ECG_data(i) =  sum(ECG_data(i-3:i+3)) /2;
    end
end


% x = 1:3000;
% p = polyfit(x,yy(1:3000)',4);
% ECG_poly = polyval(p,x);

figure
plot(ECG_data,'r')
xlabel('Samples')
ylabel('Amplitude')
title('Moving window polyfitting')


axis([3000 8000 -300 300])
%hold on
%plot(Time,yy,'r','Linewidth',0.1 )

%axis([155 160 -50 200])

%% Peak detection
close all;

y = ECG_ts_smooth1; % preprocessed signal

thresh_R = 6 * mean(abs( y(round(length(y)*1/4) : round(length(y)*3/4 )) ));

thresh_pos = -mean(abs( y(round(length(y)*1/4) : round(length(y)*3/4 )) ));

thresh_neg = 0.3 * mean(abs( y(round(length(y)*1/4) : round(length(y)*3/4 )) ));
s = 0.005;

[pks_raw, locs_raw] = findpeaks(ECG_ts_filt,fs,'MinPeakHeight',thresh_R);  %find R peaks with height threshold.
locs_raw = locs_raw + s;

for i=1:length(locs_raw)
     y( round(locs_raw(i)*fs) ) = pks_raw(i);
end

[R_pks,R_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_R,'MinPeakDistance',0.3);  %find R peaks with height threshold.
R_locs = R_locs + s;

% automatically delete extreme R peaks.
j=1;
k=1;
for i=length(R_locs):-1:2
    if R_pks(i) > 1.5*R_pks(i-1)
        
       R_pks(i) = [];
       R_locs(i) = [];
       k = k+1
    end
    j = j+1
end

[pos_pks,pos_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_pos);  %vector with local maximas
pos_locs = pos_locs + s;

[inv_pks,inv_locs] = findpeaks(-y,fs,'MinPeakHeight',thresh_neg);  %vector with local minimas
inv_pks = -inv_pks;
inv_locs = inv_locs + s;

all_locs = [pos_locs ; inv_locs];
all_locs = sort(all_locs);

k = 1;
for i=2:length(pos_locs)-1
    if ismembertol(pos_locs(i),R_locs)
        P_pks(k) = pos_pks(i-1);
        P_locs(k) = pos_locs(i-1);
        T_pks(k) = pos_pks(i+1);
        T_locs(k) = pos_locs(i+1);
        k = k+1;
    end
   
end

Q_locs = [];
S_locs = [];

k = 1;
for i=2:length(all_locs)-1
    if ismember(all_locs(i),R_locs)
        Q_locs(k) = all_locs(i-1);
        S_locs(k) = all_locs(i+1);
        k = k+1;
    end
    
end

figure(2)
plot(Time,ECG_ts_filt,'Color',[0.6, 0.8470, 0.9410] ,'Linewidth',0.1)
hold on
plot(Time,y,'r','Linewidth',2)
plot(inv_locs,inv_pks,'k+')
plot(pos_locs, pos_pks,'k+')

text(R_locs,R_pks,'R')
text(P_locs,P_pks,'P')
text(T_locs,T_pks,'T')

text(S_locs,linspace(-20,-20,length(S_locs))','S')
text(Q_locs,linspace(-20,-20,length(Q_locs))','Q')

plot(locs_raw, pks_raw,'r+')

xlabel('Time [s]')
ylabel('Amplitude')
title('Peaks')
axis([280 290 -inf inf])

%%
%remove artifact

% close all;
% 
% for i=2:length(R_pks)-100
%     if R_pks(i) > 1.5*R_pks(i-1) 
%         
%        y( round(R_locs(i)*fs+1) - 100 : round(R_locs(i)*fs+1) + 100 ) = 0;
%     end
% end
% 
% figure
% plot(Time,y)

%% Extract RR and QT variability signals
close all;
%Heart rate variability [s]
HRV = diff(R_locs);
HRV_out = rmoutliers(HRV,'gesd'); %remove outliers

QT = sort([Q_locs T_locs]);
QTV = diff(QT);
QTV = QTV(1:2:end);

%mean heart rate [BPM]
HR = round(60 / mean(HRV));

L_RR = round(max(HRV)*fs) + 1;
SEG_RR=zeros(length(R_locs),L_RR); %create 2D matrix with zeros and then fill it up with all RR segments. Need to be double with same length to create mean curve.

k = 1;
for i=1:length(R_locs)-1
    tmp = y( round(R_locs(i)*fs) : round(R_locs(i+1)*fs) );
    tmp = [tmp' zeros(1 ,(L_RR-length(tmp)) )];
    SEG_RR(i,:) = tmp;
    
    k = k+1;
end

SEG_RR = SEG_RR(1:end-1,:);  %last segment is only zeros because one row is lost when creating intervals from P to P.
%x = 63:350; %manually crop the segments to not include the

MeanCurve_RR = mean([SEG_RR'],2);

SEG2_RR = SEG_RR;
k = 1

for i=size(SEG_RR,1):-1:1
    
    if mean( abs(SEG_RR(i,:) - MeanCurve_RR') ) > 7 %threshold
    %if (xcorr(SEG_RR(i,:), MeanCurve_RR'))
        SEG2_RR(i,:) = [];
        k = k+1
    end
end
        
MeanCurve2_RR = mean([SEG2_RR'],2);    


figure
subplot(2,1,1)
plot(HRV)
hold on
plot(HRV_out)
axis([-inf inf 0.5 1.5])
xlabel('Number of RR segments')
ylabel('HRV')

legend('original','removed outliers')

subplot(2,1,2)
plot(Time,y)
xlabel('Time [s]')
ylabel('Signal amplitude')
%%
A = SEG_RR(50,:);
%[C1,lag1] = xcorr(A, MeanCurve_RR','normalized');
finddelay(A,MeanCurve_RR);

figure
plot(A)
hold on
plot(MeanCurve_RR)
plot(lag1,C1)

%%
% all segments plotted as doubles
close all;

figure
subplot(2,1,1)
for i=1:size(SEG_RR,1)
    plot(SEG_RR(i,:),'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3)
    hold on
end
plot(MeanCurve_RR,'r','Linewidth',2)
title('RR intervals')

subplot(2,1,2)
for i=1:size(SEG2_RR,1)
    plot(SEG2_RR(i,:),'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3)
    hold on
end
plot(MeanCurve2_RR,'r','Linewidth',2)
% figure
% plot(SEG_RR(40,:))


%% all segments turned into cells for time variablity
close all;

for i=1:size(SEG2_RR,1)
    cell{i} = {nonzeros(SEG2_RR(i,:))};
end 

figure

for i=1:size(SEG2_RR,1)
    plot(cell2mat(cell{i}),'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3)
    hold on
end

for i=1:size(cell,2)
    HRV2(i) = length(cell2mat(cell{i}));
end

HRV2 = HRV2/fs;

figure
subplot(2,1,1)
plot(HRV)
hold on
plot(HRV_out)
plot(HRV2)
subplot(2,1,2)
plot(y)









