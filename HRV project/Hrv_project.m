%subjects: subjects to study, e.g. subjects=1 or subjects=2:4. default=1:5
%method: PSD estimation. "lomb" (default), "periodogram", "welch", or "all"
%plot_flag: flag for plot (0 or 1). OBS. If methods is "all", the number of
%plots will increase x3. default=0.
%plot_rr: flag (0 or 1) for plotting respiration PSD for the HF band.
% default=0.
close all;
subjects=1:5;
method="lomb";
plot_flag=0;  
plot_rr=1; 
[HRV_indices,QTV_indices]=CalcNPlot(subjects,method,plot_flag,plot_rr);

%Calculates the mean and STD of the 10 indices for the number of subjects.
% Only handles one method at a time. If method is "all", "lomb" will be
% used
%First row is mean, second is std. Columns (in order):
% Mean, STDNN, SDNNi, SDANN, VLF, LF, HF,TP, LF/HF, SD1, SD2
[HRV_meanNstd_before,HRV_meanNstd_after,b,a] = Indice_meanNstd(HRV_indices,...
                                                        subjects,method);
[QTV_meanNstd_before,QTV_meanNstd_after,b_q,a_q] = Indice_meanNstd(QTV_indices,...
                                                          subjects,method);
%%
indices_b=HRV_meanNstd_before;
indices_a=HRV_meanNstd_after;
hold on
t_vlf=0:1;
x_vlf=[indices_b(1,5),indices_a(1,5)];
y_vlf=[indices_b(2,5),indices_a(2,5)];
errorbar(t_vlf,x_vlf,y_vlf,'-x','DisplayName',"VLF power")
title("Boxplot ("+method+")")
legend('-DynamicLegend','Location','nw')

t_lf=2:3;
x_lf=[indices_b(1,6),indices_a(1,6)];
y_lf=[indices_b(2,6),indices_a(2,6)];
errorbar(t_lf,x_lf,y_lf,'-x','DisplayName',"LF power")
title("Boxplot ("+method+")")

t_hf=4:5;
x_hf=[indices_b(1,7),indices_a(1,7)];
y_hf=[indices_b(2,7),indices_a(2,7)];
errorbar(t_hf,x_hf,y_hf,'-x','DisplayName',"HF power")

t_tp=6:7;
x_tp=[indices_b(1,8),indices_a(1,8)];
y_tp=[indices_b(2,8),indices_a(2,8)];
errorbar(t_tp,x_tp,y_tp,'-x','DisplayName',"Total power")

