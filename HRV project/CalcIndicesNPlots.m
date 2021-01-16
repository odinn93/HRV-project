function [indices,f,pxx] = CalcIndicesNPlots(tachogram,t,peaks_ind,psd_est)
indices=cell(2,10);
signal=tachogram;
L=length(signal);

if psd_est=="lomb"
    t_l=linspace(t(floor((peaks_ind(1)+peaks_ind(2))/2)),t(floor((peaks_ind(end-1)+peaks_ind(end))/2)),L);
    [pxx,f]=plomb(signal,t_l);
elseif psd_est=="welch"
    fs=1/(t(2)-t(1));
    [pxx,f]=pwelch(signal,L,round(L/2),L,fs);
elseif psd_est=="periodogram"
    fs=1/(t(2)-t(1));
    [pxx,f]=periodogram(signal,rectwin(L),L,fs);
end
vlf_ind=find(f>0.004 & f<0.04);
lf_ind=find(f<0.15 & f>0.04);
hf_ind=find(f<0.4 & f>0.15);

% vlf=f(f>0.004 & f<0.04);
% vlf_ind=find(f>0.004 & f<0.04);
% 
% lf=f(f<0.15 & f>0.04);
% lf_ind=find(f<0.15 & f>0.04);
% 
% hf=f(f<0.4 & f>0.15);
% hf_ind=find(f<0.4 & f>0.15);
% 
% plot(vlf,pxx(vlf_ind),'b',lf,pxx(lf_ind),'g',hf,pxx(hf_ind),'r')
% legend('VLF','LF','HF')

indices{1,1}='Mean';
indices{2,1}=mean(signal);

indices{1,2}='SDNN';
indices{2,2}=std(signal);

L=floor(length(signal)/5);
temp_std=zeros(1,L);
temp_mean=zeros(1,L);
for i=1:5
    temp_std(i)=std(signal((i-1)*L+1:i*L));
    temp_mean(i)=mean(signal((i-1)*L+1:i*L));
end
indices{1,3}='SDNNi';
indices{2,3}=mean(temp_std);

indices{1,4}='SDANN';
indices{2,4}=mean(temp_mean);

indices{1,5}='TP';
indices{2,5}=sum(pxx([vlf_ind; lf_ind; hf_ind]));

indices{1,6}='HF';
indices{2,6}=sum(pxx(hf_ind));

indices{1,7}='LF';
indices{2,7}=sum(pxx(lf_ind));

indices{1,8}='LF/HF';
indices{2,8}=indices{2,7}/indices{2,6};

s1=signal(1:end-1);
s2=signal(2:end);

indices{1,9}='SD1';
indices{2,9}=std(s1-s2)/sqrt(2);

indices{1,10}='SD2';
indices{2,10}=std(s1+s2)/sqrt(2);

end

