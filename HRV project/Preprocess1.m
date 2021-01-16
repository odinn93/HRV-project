function processed_ecg = Preprocess1(ecg,t)
%ecg is a nx1 vector with raw ecg data
%t is a nx1 time vector corresponding to the ecg
ecg1=ecg-mean(ecg);
dt=t(2)-t(1);
fs=1/dt;
ecg_ts=timeseries(ecg1);
ecg_ts_filt=idealfilter(ecg_ts,[2/fs 60/fs],'pass');
ecg_ts_filt=idealfilter(ecg_ts_filt,[49.5/fs 50.5/fs],'notch');
d=ecg_ts_filt.Data;
d = smoothdata(d,'gaussian',20);
processed_ecg=d;
end

