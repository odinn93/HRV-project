function [indices,f,pxx] = CalcIndices(signal,t,psd_est)
indices=cell(2,11);
L=length(signal);

if psd_est=="lomb" 
    t_l=linspace(t(1),t(end),L);
    [pxx,f]=plomb(signal,t_l,0.5);
elseif psd_est=="welch"
    fs=1/(t(2)-t(1));
    [pxx,f]=pwelch(signal,L,L/2,L,fs);
elseif psd_est=="periodogram"
    fs=1/(t(2)-t(1));
    L=length(signal);
    [pxx,f]=periodogram(signal,rectwin(L),L,fs);
end
vlf_ind=find(f>0.004 & f<0.04);
lf_ind=find(f<0.15 & f>0.04);
hf_ind=find(f<0.4 & f>0.15);

indices{1,1}='Mean';
indices{2,1}=mean(signal);

indices{1,2}='SDNN';
indices{2,2}=std(signal);
%five minute recording
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
%Estimating the area under the graph
indices{1,5}='VLF';
indices{2,5}=trapz(f(vlf_ind),pxx(vlf_ind));
%sum(pxx([vlf_ind; lf_ind; hf_ind]))/length(pxx);
indices{1,6}='LF';
indices{2,6}=trapz(f(lf_ind),pxx(lf_ind));
%sum(pxx(hf_ind))/length(pxx);
indices{1,7}='HF';
indices{2,7}=trapz(f(hf_ind),pxx(hf_ind));
%sum(pxx(lf_ind))/length(pxx);
indices{1,8}='TP';
indices{2,8}=trapz(f([vlf_ind; lf_ind; hf_ind]),pxx([vlf_ind; lf_ind; hf_ind]));

indices{1,9}='LF/HF';
indices{2,9}=indices{2,6}/indices{2,7};

s1=signal(1:end-1);
s2=signal(2:end);

indices{1,10}='SD1';
indices{2,10}=std(s1-s2)/sqrt(2);

indices{1,11}='SD2';
indices{2,11}=std(s1+s2)/sqrt(2);

end

