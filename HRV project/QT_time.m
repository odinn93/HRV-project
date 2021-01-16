function qt_sec = QT_time(ECGSignal,r_ind,fs,t)
l=1:1:length(ECGSignal);
%Add vector l that contains index of peak in ECG signal
ecg=[ECGSignal l'];

%Find indexes
if max(r_ind)==1
    ind_2=find(r_ind==1);
else
    ind_2=r_ind;
end
n_pulse=length(ind_2);
q_shift=floor(0.02*fs);
t_shift=floor(0.06*fs);
qt_sec=zeros(1,n_pulse);
for i=1:n_pulse
    %find index of q and t peak.
    temp_val=ecg(ind_2(i)-0.15*fs:ind_2(i),1);
    temp_n=ecg(ind_2(i)-0.15*fs:ind_2(i),2);
    q_ind=PeakDetection(temp_val,1/(length(temp_val)),0);
    q_ind=find(q_ind==1);
    %Subtract variable to include hole Q-wave
    if q_ind>q_shift
        q_ind=temp_n(q_ind-q_shift);
    else
        q_ind=temp_n(q_ind);
    end
    
    temp_val=ecg(ind_2(i)+0.1*fs:ind_2(i)+0.5*fs,1);
    temp_n=ecg(ind_2(i)+0.1*fs:ind_2(i)+0.5*fs,2);
    
    t_ind=PeakDetection(temp_val,1/(length(temp_val)),1);
    t_ind=find(t_ind==1);
    % Check to remove false-peaks
    if (t_ind+t_shift)>length(temp_n)
        t_ind=temp_n(t_ind);
    %Add variable to include hole T-wave
    else
        t_ind=temp_n(t_ind+t_shift);
    end
    qt_sec(i)=t(t_ind)-t(q_ind);
end

end

