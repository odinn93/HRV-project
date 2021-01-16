function [HRV_indices,QTV_indices] = CalcNPlot(subjects,method,plot_flag,plot_rr)
if nargin==0
    subjects=1:5;
    method="lomb";
    plot_flag=0;
    plot_rr=0;
elseif nargin==1
    method="lomb";
    plot_flag=0;
    plot_rr=0;
elseif nargin==2
    plot_flag=0;
    plot_rr=0;
elseif nargin==3
    plot_rr=0;
end

HRV_indices=cell(2,length(subjects));
QTV_indices=cell(2,length(subjects));

for i=subjects
    %Load subject data
    HRV_indices{1,i}="Subject"+string(i);
    HRV_indices{2,i}=cell(2,2);
    QTV_indices{1,i}="Subject"+string(i);
    QTV_indices{2,i}=cell(2,2);
    for j=1:2
        if j==1
            if i<5 
                status="_Before";
            else
                status=" Before";
            end
        else
            if i<5 
                status="_After";
            else
                status=" After";
            end
        end
        HRV_indices{2,i}{1,j}=status;
        HRV_indices{2,i}{2,j}=cell(2,3);
        QTV_indices{2,i}{1,j}=status;
        QTV_indices{2,i}{2,j}=cell(2,3);

        [t,ecg,teb,fs] = LoadData(i,status);
        %Preprocess
        ecg2=Preprocess1(ecg,t);
        [peaks,peaks_ind]=RDetPeak1(ecg2,fs);
         peaks(peaks==0)=nan;

        % Calculate tachograms, interpolate and resample at 4 Hz. 
        target_L=length(ecg2);
        
        qt=QTV(ecg2,peaks_ind,fs);
        qt_new=rmoutliers(qt,'gesd');
        qt_taco=IntNRsmpl(qt,target_L,fs);
        qt_taco_new=IntNRsmpl(qt_new,target_L,fs);
        
        sec_at_peak=t(peaks_ind);
        rr=diff(sec_at_peak);
        rr_new=rmoutliers(rr,'gesd');
        %interpolate and resample at 4 hz
        rr_taco=IntNRsmpl(rr,target_L,fs);
        rr_taco_new=IntNRsmpl(rr_new,target_L,fs);

        %Respiration rate
        teb2=PreprocessTEB(teb,t);
        [~,peaks_tb_ind]=findpeaks(teb2,"MinPeakdistance",400);

        sec_at_peak=t(peaks_tb_ind);
        rtime=diff(sec_at_peak);
        rtime_new=rmoutliers(rtime,'gesd');
        
        rtime_taco=IntNRsmpl(rtime,target_L,fs);
        rtime_taco_new=IntNRsmpl(rtime_new,target_L,fs);
        
        t_re=resample(t,4,fs,1);
        t_re(1)=[];
        t_re(end)=[];
        
        if plot_flag
            figure
            subplot(7,1,1)
            plot(t,ecg2,t,peaks,'x')
            title("Processed ECG")
            subplot(7,1,2)
            plot(t_re,rr_taco)
            title("RR tachogram")
            subplot(7,1,3)
            plot(t_re,rr_taco_new)
            title("RR tachogram w.o. outliers")
            subplot(7,1,4)
            plot(t_re,rtime_taco)
            title("Respiration tachogram")
            subplot(7,1,5)
            plot(t_re,rtime_taco_new)
            title("Respiration tachogram w.o. outliers")
            subplot(7,1,6)
            plot(t_re,qt_taco)
            title("QTV tachogram")
            subplot(7,1,7)
            plot(t_re,qt_taco_new)
            title("QTV tachogram w.o. outliers")
            sgtitle("Subject"+string(i)+" "+status,"FontSize",12)
        end

        %Calculate HRV indices
        if method=="periodogram" | method=="all"
            [HRV_ind,frr,pxxrr]=CalcIndices(rr_taco_new*1000,t_re,peaks_ind,"periodogram");
            [QTV_ind,fqt,pxxqt]=CalcIndices(qt_taco_new*1000,t_re,peaks_ind,"periodogram");
            HRV_indices{2,i}{2,j}{1,1}="periodogram";
            HRV_indices{2,i}{2,j}{2,1}=HRV_ind;
            QTV_indices{2,i}{2,j}{1,1}="periodogram";
            QTV_indices{2,i}{2,j}{2,1}=QTV_ind;
            if plot_flag 
                Plot(frr,pxxrr,"periodogram",status,i,"RR")
                Plot(fqt,pxxqt,"periodogram",status,i,"QT")
                if plot_rr
                    [~,f,pxx]=CalcIndices(rtime_taco_new*1000,t_re,peaks_tb_ind,"periodogram");
                    Plot(f,pxx,"periodogram",status,i,"Resp")
                end
            end
        end
        
        if method=="welch" | method=="all"
            [HRV_ind,frr,pxxrr]=CalcIndices(rr_taco_new*1000,t_re,peaks_ind,"welch");
            [QTV_ind,fqt,pxxqt]=CalcIndices(qt_taco_new*1000,t_re,peaks_ind,"welch");
            HRV_indices{2,i}{2,j}{1,2}="welch";
            HRV_indices{2,i}{2,j}{2,2}=HRV_ind;
            QTV_indices{2,i}{2,j}{1,2}="welch";
            QTV_indices{2,i}{2,j}{2,2}=QTV_ind;
            if plot_flag 
                Plot(frr,pxxrr,"welch",status,i,"RR")
                Plot(fqt,pxxqt,"welch",status,i,"QT")
               if plot_rr
                   [~,f,pxx]=CalcIndices(rtime_taco_new*1000,t_re,peaks_tb_ind,"welch");
                   Plot(f,pxx,"welch",status,i,"Resp")
               end
            end
        end
        
        if method=="lomb"| method=="all"
            [HRV_ind,frr,pxxrr]=CalcIndices(rr_new*1000,t,peaks_ind,"lomb");
            [QTV_ind,fqt,pxxqt]=CalcIndices(qt_new*1000,t,peaks_ind,"lomb");
            HRV_indices{2,i}{2,j}{1,3}="lomb";
            HRV_indices{2,i}{2,j}{2,3}=HRV_ind;
            QTV_indices{2,i}{2,j}{1,3}="lomb";
            QTV_indices{2,i}{2,j}{2,3}=QTV_ind;
            if plot_flag 
                Plot(frr,pxxrr,"lomb",status,i,"RR")
                Plot(fqt,pxxqt,"lomb",status,i,"QT")
                if plot_rr
                   [~,f,pxx]=CalcIndices(rtime_new*1000,t,peaks_tb_ind,"lomb");
                   Plot(f,pxx,"lomb",status,i,"Resp")
               end
            end
        end
    end
end
end

