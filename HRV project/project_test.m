s1=importdata('Data/S5 Before.txt',' ',1);
t=s1.data(:,1);
ecg=s1.data(:,2);
teb=s1.data(:,3);

ecg1=ecg(10000:end);
t1=t(10000:end);
teb1=teb(500:end);
tb=t(500:end);
fs=1/(t(2)-t(1));
%% remove dc, lp and hp ecg
ecg2=Preprocess1(ecg,t);
plot(ecg2(56000:58000))
%plot(fs*linspace(0,1,length(ecg2)),abs(fft(ecg2)));

%% detect r-peaks
[peaks,peaks_ind]=RDetPeak1(ecg2,fs);

range=1:2000;
peaks(peaks==0)=nan;
plot(t(range),ecg2(range),t(range),peaks(range),'x')

%% Preprocsing 2 ???

ecg3=ecg1-mean(ecg1);
ecg_lp=filter(IRRbp,ecg3);

%d = smoothdata(ecg3,'gaussian',10);
% ecg4=ecg3-ecg_lp;
% ecg_notch=filter(IRRnotch,ecg_lp);
%ecg_notch=filter(IRRbp,ecg_notch);
% t=fs*linspace(0,1,length(d));
x=10*sin(7*pi*t);
hold on
plot(ecg_lp(1:1000))
%plot(x(1:1000))
%plot(t,abs(fft(ecg_notch)))
%% RDetPeak2
r_peaks=PeakDetection(ecg2,1/fs,1);

fs=1/(t(2)-t(1));
range=1:50000;
r_peaks_plot=ecg2.*r_peaks';
peaks_ind2=find(r_peaks_plot~=0);
r_peaks_plot(r_peaks_plot==0)=nan;
plot(t1(range),ecg2(range),t1(range),r_peaks_plot(range),'x')

%% Interpolated tachogram for HR and RR(linear interpolation)
qt=QT_time(ecg2,peaks_ind,fs,t);

hr=PeaksPerMin(peaks_ind,t);

sec_at_peak=t(peaks_ind);
rr=diff(sec_at_peak);

L=length(rr);
target_L=length(ecg2);
rr_taco_li=interp1(1:L,rr,linspace(1,L,target_L));
hr_taco_li=interp1(1:L,hr,linspace(1,L,target_L));
qt_taco_li=interp1(1:L+1,qt,linspace(1,L,target_L));

%% Plot

range=1:60000;
subplot(4,1,1)
plot(ecg2(range))
title("tje");
subplot(4,1,2)
plot(rr_taco_li(range))
title("Tjo")
subplot(4,1,3)
plot(hr_taco_li(range))
subplot(4,1,4)
plot(qt_taco_li(range))
%%
L=length(teb2);
periodogram(teb2,rectwin(L),L,fs);


%% Find peaks for resp rate
%plot(teb1)
teb2=PreprocessTEB(teb,t);
[~,locs]=findpeaks(teb2,"MinPeakdistance",400);

fs=1/(t(2)-t(1));
range=1:70857;
peaks_plot=zeros(1,length(teb2));
peaks_plot(locs)=teb(locs);
peaks_ind_tb=find(peaks_plot~=0);
peaks_plot(peaks_plot==0)=nan;
plot(range,teb(range),range,peaks_plot(range),'x')

%% Tachogram for respiratory rate (time between peaks and breaths/min)
resp_rate=PeaksPerMin(peaks_ind_tb,t);
sec_at_peak=t(peaks_ind_tb);

rtime=diff(sec_at_peak);
L=length(rtime);
target_L=length(ecg2);
rtime_taco_li=interp1(1:L,rtime,linspace(1,L,target_L));
rrate_taco_li=interp1(1:L,resp_rate,linspace(1,L,target_L));
%%
range=1:60226;
subplot(3,1,1)
plot(teb2(range))
subplot(3,1,2)
plot(rtime_taco_li(range))
subplot(3,1,3)
plot(rrate_taco_li(range))
%% Periodogram
signal=rr_taco_li;

L=length(signal);
[pxx,f]=periodogram(signal,rectwin(L),L,fs);


vlf=f(f>0.003 & f<0.04);
vlf_ind=find(f>0.003 & f<0.04);

lf=f(f<0.15 & f>0.04);
lf_ind=find(f<0.15 & f>0.04);

hf=f(f<0.4 & f>0.15);
hf_ind=find(f<0.4 & f>0.15);

plot(vlf,pxx(vlf_ind),'b',lf,pxx(lf_ind),'g',hf,pxx(hf_ind),'r')
legend('VLF','LF','HF')
%% Welch method
signal=rtime_taco_li;
L=length(signal);
[pxx,f]=pwelch(signal,L,L/2,L,200);
%pxx(pxx>10)=0;
vlf=f(f>0.004 & f<0.04);
vlf_ind=find(f>0.004 & f<0.04);

lf=f(f<0.15 & f>0.04);
lf_ind=find(f<0.15 & f>0.04);

hf=f(f<0.4 & f>0.15);
hf_ind=find(f<0.4 & f>0.15);

plot(vlf,pxx(vlf_ind),'b',lf,pxx(lf_ind),'g',hf,pxx(hf_ind),'r')
legend('VLF','LF','HF')

%% Lomb
signal=rr';
L=length(signal);
t_l=linspace(t(floor((peaks_ind(1)+peaks_ind(2))/2)),t(floor((peaks_ind(end-1)+peaks_ind(end))/2)),L);
[pxx_rr,f]=plomb(signal,t_l);

vlf=f(f<0.04);
lf=f(f<0.15 & f>0.04);
hf=f(f<0.4 & f>0.15);
L_vlf=length(vlf);
L_lf=length(lf);
L_hf=length(hf);
plot(vlf,pxx_rr(1:L_vlf),'b',lf,pxx_rr(L_vlf+1:L_vlf+L_lf),'g',hf,pxx_rr(L_vlf+L_lf+1:L_vlf+L_lf+L_hf),'r')
legend('VLF','LF','HF')
%% HRV indices
sec_at_peak=t(peaks_ind);
rr=diff(sec_at_peak);
rr_ms=rr*1000;
HRV_indafter=CalcIndicesNPlots(rr_ms,t,peaks_ind,'lomb');
%% QT indices
[qt,~]=QT_meanNstd(ecg2,peaks_ind,fs,t);
qt_ms=qt*1000;
QT_ind=CalcIndicesNPlots(qt_ms,t,peaks_ind,'periodogram');
%%
qtv=QTV(ecg2,peaks_ind,fs);
