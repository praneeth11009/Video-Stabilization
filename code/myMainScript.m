
%% Read Video & Setup Environment
clear
clc
close all hidden
[FileName,PathName] = uigetfile({'*.avi'; '*.mp4'},'Select shaky video file');

cd mmread
vid=mmread(strcat(PathName,FileName));
cd ..
s=vid.frames;

%% Your code here
%translation+rotation model
N=size(s,2);
rang=1:N-1;
F=zeros(size(s(1).cdata,1),size(s(1).cdata,2), N);
imsz=[size(s(1).cdata,1),size(s(1).cdata,2)];
for i=1:N
    F(:,:,i)=im2double(rgb2gray(s(i).cdata));
end
%N=50;
outV=s;
dtheta=zeros(1,N-1);ctheta=dtheta;
dx=zeros(1,N-1);cx=dx;
dy=zeros(1,N-1);cy=dy;
scales=zeros(1,N-1);
win=15;
for i=2:N
    est=motn_est(F(:,:,i-1),F(:,:,i)); 
    %scales(i-1)=est(1);
    dx(i-1)=est(1);
    dy(i-1)=est(2);
    dtheta(i-1)=est(3);
    if i>2
        cx(i-1)=cx(i-2)+dx(i-1);
        cy(i-1)=cy(i-2)+dy(i-1);
        ctheta(i-1)=ctheta(i-2)+dtheta(i-1);
    else
        cx(i-1)=dx(i-1);
        cy(i-1)=dy(i-1);
        ctheta(i-1)=dtheta(i-1);
    end
    if i==2
        res=est;
    end
end
sx=smooth_m(cx);
sy=smooth_m(cy);
stheta=smooth_m(ctheta);

for i=1:N-1
    dx(i)=sx(i)-cx(i);
    dy(i)=sy(i)-cy(i);
    dtheta(i)=stheta(i)-ctheta(i);
end

figure; plot(rang,cx); hold on; plot(rang,sx); hold off;
legend('noisy x','smoothened x')
figure; plot(rang,ctheta); hold on; plot(rang,stheta); hold off;
legend('noisy theta','smoothened theta');

for i=2:N
    Hs = [[1*[cos(dtheta(i-1)) -sin(dtheta(i-1)); ...
            sin(dtheta(i-1)) cos(dtheta(i-1))]; ...
            [dx(i-1),dy(i-1)]], [0 0 1]'];
    Hf = affine2d(Hs);
    imnew = imwarp(F(:,:,i), Hf, 'OutputView', imref2d(imsz));
    imnew=im2uint8(imnew);
    outV(i).cdata=repmat(imnew,1,1,3);
end
N=N-1;
%% Write Video
vfile=strcat(PathName,'combined_',FileName);
ff = VideoWriter(vfile);
ff.FrameRate = 30;
open(ff)

for i=1:N+1
    f1 = s(i).cdata;
    f2 = outV(i).cdata;
    vframe=cat(1,f1, f2);
    writeVideo(ff, vframe);
end
close(ff)

%% Display Video
figure
msgbox(strcat('Combined Video Written In ', vfile), 'Completed') 
displayvideo(outV,0.01)

function smotion = smooth_m(motion)
smotion=motion;
width=15;   
for i=1:length(motion)
    p=max(1,i-width);
    q=min(length(motion),i+width);
    smotion(i)=sum(motion(p:q))/(q-p+1);
end
end