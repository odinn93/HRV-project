%subjects: subjects to study, e.g. subjects=1 or subjects=2:4. default=1:5
%method: PSD estimation. "lomb" (default), "periodogram", "welch", or "all"
%plot_flag: flag for plot (0 or 1). OBS. If methods is "all", the number of
%plots will increase x3. default=0.
%plot_rr: flag (0 or 1) for plotting respiration PSD for the HF band.
% default=0.

subjects=1:5;
method="welch";
plot_flag=1;  
plot_rr=0; 
[HRV_indices,QTV_indices]=CalcNPlot(subjects,method,plot_flag,plot_rr);

%Calculates the mean and STD of the 10 indices for the number of subjects.
% Only handles one method at a time. If method is "all", "lomb" will be
% used
%First row is mean, second is std. Columns (in order):
% Mean, STDNN, SDNNi, SDANN, TP, HF, LF, LF/HF, SD1, SD2
[HRV_meanNstd_before,HRV_meanNstd_after,b,a] = Indice_meanNstd(HRV_indices,...
                                                        subjects,method);
[QTV_meanNstd_before,QTV_meanNstd_after] = Indice_meanNstd(QTV_indices,...
                                                          subjects,method);

