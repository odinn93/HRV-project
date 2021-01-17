function Plot_psd(f,pxx,method,status,i,type)
    figure
    vlf=f(f>0.004 & f<0.04);
    vlf_ind=find(f>0.004 & f<0.04);
    lf=f(f<0.15 & f>0.04);
    lf_ind=find(f<0.15 & f>0.04);
    hf=f(f<0.4 & f>0.15);
    hf_ind=find(f<0.4 & f>0.15);
    if type=="Resp"
        pxx(vlf_ind)=0;
        pxx(lf_ind)=0;
    end
    plot(vlf,pxx(vlf_ind),'b',lf,pxx(lf_ind),'g',hf,pxx(hf_ind),'r')
    title(type+" PSD estimation ("+string(method)+")"+"subject"+string(i)+status)
    legend('VLF','LF','HF')
    xlabel("Frequency [Hz]")
    ylabel("PSD [ms^2/Hz]")
end

