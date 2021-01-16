function [peaks,peaks_ind] = RDetPeak1(ecg,fs)
peak_ind=QRSDetPanTom(ecg,fs);
peaks=zeros(length(ecg),1);
peaks_ind=zeros(length(peak_ind),1);

for i=1:length(peak_ind)
    if i==1
        ind=peak_ind(i);
        val=max(ecg(i:ind));
        r_ind=find(ecg(i:ind)==val);
        peaks_ind(i)=r_ind;
        peaks(r_ind)=val;       
    else
        ind1=peak_ind(i-1);
        ind2=peak_ind(i);
        val=max(ecg(ind1+1:ind2));
        r_ind=find(ecg(ind1+1:ind2)==val);
        r_ind=ind1+r_ind;
        peaks_ind(i)=r_ind;
        peaks(r_ind)=val;  
    end
end
false_peaks=(peaks<mean(peaks(peaks>0))/2 | peaks>mean(peaks(peaks>0))*2);
false_ind=find(false_peaks==1);
peaks(false_ind)=0;
if ~isempty(false_ind)
    peaks_ind(find(ismember(peaks_ind,false_ind)))=[];
end
end

