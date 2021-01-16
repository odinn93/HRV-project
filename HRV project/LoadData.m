function [t,ecg,teb,fs] = LoadData(i,status)

    s=importdata("Data/S"+string(i)+status+".txt"," ",1);
    t=s.data(:,1);
    ecg=s.data(:,2);
    teb=s.data(:,3);

    fs=floor(1/(t(2)-t(1)));
end

