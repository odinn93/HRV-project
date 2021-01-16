function processed_ecg = PreprocessTEB(TEB,t)
%ecg is a nx1 vector with raw ecg data
%t is a nx1 time vector corresponding to the ecg
ecg1=TEB-mean(TEB);
dt=t(2)-t(1);
fs=1/dt;
ecg_ts=timeseries(ecg1);
ecg_ts_filt=idealfilter(ecg_ts,[0.05/fs 5/fs],'pass');
ecg_ts_filt=idealfilter(ecg_ts_filt,[49.5/fs 50.5/fs],'notch');
d=ecg_ts_filt.Data;
d = smoothdata(d,'gaussian',100);
processed_ecg=d;
end


