function peak_ind= QRSDetPanTom(processed_ecg,fs)
%processed ecg is the lp and hp filtered ecg without dc component.
% fs is the sampling frequency

%derivative filter
nf = 50; 
fpass = 2; 
fstop = 15;
dt=1/fs;
d = designfilt('differentiatorfir','FilterOrder',nf, ...
    'PassbandFrequency',fpass,'StopbandFrequency',fstop, ...
    'SampleRate',fs);
processed_ecg=filter(d,processed_ecg)/dt;

%square
processed_ecg=processed_ecg.^2;

%moving mean
processed_ecg=movmean(processed_ecg,30);

[~,peak_ind]=findpeaks(processed_ecg,"MinPeakDistance",100,"MinPeakHeight",1.5e05);
end

