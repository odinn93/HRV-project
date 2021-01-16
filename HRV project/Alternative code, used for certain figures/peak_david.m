% Peak detection
% y1 = processed signal before gaussian
% y1 = fully processed signal

function[QTV] = peak_david(y1,y,fs) 

thresh_R = 0.7 * max( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
thresh_pos = 0.1 * min( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
thresh_neg = -0.1 * min( y(round(length(y)*1/3) : round(length(y)*2/3 )) );
s = 0.005;

[pks_raw, locs_raw] = findpeaks(y1,fs,'MinPeakHeight',70);  %find R peaks with height threshold.
locs_raw = locs_raw + s;

for i=1:length(locs_raw)
     y( round(locs_raw(i)*fs) ) = pks_raw(i);
end

[R_pks,R_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_R,'MinPeakDistance',0.3);  %find R peaks with height threshold.
R_locs = R_locs + s;

% automatically delete extreme R peaks.
% k=1
% for i=2:length(R_locs)-20
%     if R_pks(i) > 1.5*R_pks(i-1)
%         
%        R_pks(i) = [];
%        R_locs(i) = [];
%     end
%     k = k+1
% end

[pos_pks,pos_locs] = findpeaks(y,fs,'MinPeakHeight',thresh_pos);  %vector with local maximas
pos_locs = pos_locs + s;

[inv_pks,inv_locs] = findpeaks(-y,fs,'MinPeakHeight',thresh_neg);  %vector with local minimas
inv_pks = -inv_pks;
inv_locs = inv_locs + s;

all_locs = [pos_locs ; inv_locs];
all_locs = sort(all_locs);

k = 1;
for i=1:length(pos_locs)-1
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
for i=1:length(all_locs)-1
    if ismember(all_locs(i),R_locs)
        Q_locs(k) = all_locs(i-1);
        S_locs(k) = all_locs(i+1);
        k = k+1;
    end
    
end

QT = sort([Q_locs T_locs]);
QTV = diff(QT);

end