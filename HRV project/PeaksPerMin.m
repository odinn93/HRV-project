function peak_rate = PeaksPerMin(peaks_ind,t)
sec_at_peak=t(peaks_ind);
time_between_peaks=diff(sec_at_peak);
peak_rate=zeros(length(time_between_peaks),1);
for i=1:length(time_between_peaks)
    peak_rate(i)=60/time_between_peaks(i);
end
end

