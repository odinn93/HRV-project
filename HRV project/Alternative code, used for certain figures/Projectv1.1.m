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
ECG = S1_Before.ECG;
Time = S1_Before.Time;
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


figure
%plot(Time,ECG_ts_filt,'Color',[0.249, 0.247, 0.255] ,'Linewidth',0.1)
%plot(Time,ECG_ts_notch,'Color',[0.5, 0.6470, 0.9410] ,'Linewidth',0.3)
%plot(Time,ECG_ts_filt2,'r')
%plot(ECG_ts_smooth2,'b')

plot(Time, ECG_ts_smooth1,'r')  
axis([1 100 -50 100])

% fvtool(ECG_ts_smooth1)
% fvtool(ECG_ts_notch)



%%
figure
plot(Time,ECG,'Color',[0.7, 0.6470, 0.9410])
hold on

plot(Time,ECG1,'Color',[0, 0.4470, 0.7410])
plot(Time,ECG_bp,'Color',[0.9290, 0.6940, 0.1250])
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
% ECG_data = [];
% for i=1:100:length(yy)-99
%     [p,s,mu] = polyfit( (i:i+99)',yy(i:i+99),4);
%     f_y = polyval(p,(i:i+99)',[],mu);
% 
%     ECG_data = [ECG_data ; yy(i:i+99) - f_y];        % Detrend data
% end

% for i=1:100:length(ECG_data)-3
%     if i==1
%         ECG_data(i) = ECG_data(i)
%     else
%         ECG_data(i) =  sum(ECG_data(i-3:i+3)) /2;
%     end
% end

figure
plot(ECG_data)
hold on
plot(ECG_ts_smooth1)
axis([1 1000 -50 200])
%hold on
%plot(Time,yy,'r','Linewidth',0.1 )

%axis([155 160 -50 200])

%% Peak detection
close all;

y = ECG_ts_smooth1;
thresh_R = 0.7 * max( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
thresh_pos = 0.1 * min( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
thresh_neg = -0.2 * min( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
s = 0.005;

[R_pks,R_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_R);  %find R peaks with height threshold.
R_locs = R_locs + s;

[pos_pks,pos_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_pos);  %vector with local maximas
pos_locs = pos_locs + s;

[inv_pks,inv_locs] = findpeaks(-y,fs,'MinPeakHeight',thresh_neg);  %vector with local minimas
inv_pks = -inv_pks;
inv_locs = inv_locs + s;

all_locs = [pos_locs ; inv_locs];
all_locs = sort(all_locs);


k = 1;
for i=1:length(pos_locs)-1
    if ismember(pos_locs(i),R_locs)
        P_pks(k) = pos_pks(i-1);
        P_locs(k) = pos_locs(i-1);
        T_pks(k) = pos_pks(i+1);
        T_locs(k) = pos_locs(i+1);
    end
    k = k+1;
end

Q_locs = [];
S_locs = [];

k = 1;
for i=1:length(all_locs)-1
    if ismember(all_locs(i),R_locs)
        Q_locs(k) = all_locs(i-1);
        S_locs(k) = all_locs(i+1);
    end
    k = k+1;
end



figure(2)
plot(Time,y,'r','Linewidth',1)
hold on
plot(inv_locs,inv_pks,'+')
plot(pos_locs, pos_pks,'+')

text(R_locs,R_pks,'R')
text(P_locs,P_pks,'P')
text(T_locs,T_pks,'T')

text(S_locs,linspace(-20,-20,length(S_locs))','S')
text(Q_locs,linspace(-20,-20,length(Q_locs))','Q')
xlabel('Time [s]')
ylabel('Amplitude')
title('Peaks')
axis([150 160 -50 200])

%%

%Heart rate variability [s]
HRV = diff(R_locs);
%mean heart rate [BPM]
HR = round(60 / mean(HRV));







