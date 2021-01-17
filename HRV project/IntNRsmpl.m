function [taco_re] = IntNRsmpl(tacho,target_L,fs)
%Linearly interpolate, then linearly resample at 4 hz. End points removed
%since they are not close to zero and thus gets shifted. 
L=length(tacho);
taco_li=interp1(1:L,tacho,linspace(1,L,target_L));
taco_re=resample(taco_li,4,fs,1);

taco_re(1)=[];
taco_re(end)=[];
end

