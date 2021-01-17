function [meanNstd_before,meanNstd_after,before_array,after_array] = Indice_meanNstd(indices,subjects,method)
if method=="periodogram"
    m=1;
elseif method=="welch"
    m=2;
else
    m=3;
end

before_array=zeros(length(subjects),11);
after_array=zeros(length(subjects),11);
meanNstd_before=zeros(2,11);
meanNstd_after=zeros(2,11);

for i=subjects
    for j=1:2
        if j ==1
            for a=1:11
                before_array(i,a)=indices{2,i}{2,j}{2,m}{2,a};
            end
        else
            for a=1:11
                after_array(i,a)=indices{2,i}{2,j}{2,m}{2,a};
            end
        end
    end
end

meanNstd_before(1,:)=mean(before_array,1);
meanNstd_before(2,:)=std(before_array,0,1);
meanNstd_after(1,:)=mean(after_array,1);
meanNstd_after(2,:)=std(after_array,0,1);
end

