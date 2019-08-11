function T = get_rigid_trans(x1,x2)
%p1,p2 -> N*2
N=size(x1,1);
m1=mean(x1); %centroid1
m2=mean(x2);

n1=x1-repmat(m1, N, 1); %centroid to zero
n2=x2-repmat(m2, N, 1);

M=n1'*n2;
[U,~,V]=svd(M);
R = V*U';

if det(R) <0 %refl matrix
    V(:,2) = -V(:,2);
    R = V*U';
end
t=x2'-R*x1';
t=sum(t,2);
t=t/N;

T=eye(3);
T(1:2,3)=t;
T(1:2,1:2)=R;
end

