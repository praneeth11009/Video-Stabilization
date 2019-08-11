function Hf = ransac_rigid_trans(x1,x2, thresh) %x2=H*x1
%RANSACHOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
nitr=100;
samp=3;
idx=zeros(nitr,samp);
inl=zeros(nitr,1);
ols=zeros(nitr,1);
Hi=zeros(3,3,nitr);
for i=1:nitr %itr
    S=1:size(x1,1);
    idx(i,:)=datasample(S,samp,'Replace',false);%min 5
    H=get_rigid_trans( x1(idx(i,:),:), x2(idx(i,:),:) ); %%x2=H*x1
    S(idx(i,:))=[];
    for j=1:size(S,2)
        xc=H*[x1(S(j),1); x1(S(j),2) ; 1];
        px=xc(1)/xc(3);
        py=xc(2)/xc(3);
        if norm([px,py]-x2(S(j),:)) < thresh
            inl(i)=inl(i)+1;
        end
    end
    ols(i)=size(S,2)-inl(i);
    Hi(:,:,i)=H;
end
[~,idx]=max(inl);
%ol=min(ols);
Hf=Hi(:,:,idx);

end

