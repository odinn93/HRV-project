
function[QTV] = QTV(ecg,peaks_ind,fs)
% ecg= processed ecg
% peaks_ind=R-peak indices
%fs= sampling frequency
thresh_pos = 0.1 * min( ecg(round(length(ecg)*1/3) : round(length(ecg)*2/3 )) );
thresh_neg = -0.1 * min( ecg(round(length(ecg)*1/3) : round(length(ecg)*2/3 )) );

[~,pos_locs] = findpeaks(ecg,'MinPeakHeight',thresh_pos);  %vector with local maximas

[~,inv_locs] = findpeaks(-ecg,'MinPeakHeight',thresh_neg);  %vector with local minimas

all_locs = [pos_locs ; inv_locs];
all_locs = sort(all_locs);

k = 1;
for i=1:length(pos_locs)-1
    if ismembertol(pos_locs(i),peaks_ind(2:end))
        T_locs(k) = pos_locs(i+1);
        k = k+1;
    end
   
end

Q_locs = [];

k = 1;
for i=1:length(all_locs)-1
    if ismember(all_locs(i),peaks_ind(2:end))
        Q_locs(k) = all_locs(i-1);
        k = k+1;
    end
    
end

QT = sort([Q_locs T_locs]);
QTV = diff(QT);
QTV=QTV(1:2:end);
QTV=QTV/fs;
end