function mean_qrst = Calc_mean(windows)
n=length(windows);
l=0;

for i=1:n
    l=l+length(windows{i});
end
%Calculate mean length of segment
l=floor(l/n);
sum_pulse=zeros(l,1);
for i = 1:n
    pulse=windows{i};
    if length(pulse)<l
        sum_pulse(1:length(pulse))=sum_pulse(1:length(pulse))+pulse;
    else    
        sum_pulse=sum_pulse+pulse(1:l);
    end
end
mean_qrst=sum_pulse/n;
end

