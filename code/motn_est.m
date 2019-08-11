function est = motn_est(im1, im2)
%sz(1,:)=size(im1); sz(2,:)=size(im2); 
%% feature extr
points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);
[f1,vpts1] = extractFeatures(im1,points1);
[f2,vpts2] = extractFeatures(im2,points2);
indexPairs12 = matchFeatures(f1,f2) ;
matchedPoints11 = vpts1(indexPairs12(:,1));
matchedPoints12 = vpts2(indexPairs12(:,2));
%thresh=10.0;
H=ransac_rigid_trans(matchedPoints11.Location,matchedPoints12.Location,5);
%[tform, ~, ~] = estimateGeometricTransform(...
%    matchedPoints12.Location, matchedPoints11.Location, 'affine');
%H=ransacHomography(matchedPoints11.Location,matchedPoints12.Location,20.0);
%H = tform.T;
H=H';

R = H(1:2,1:2);
theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);

%scale = mean(R([1 4])/cos(theta));

dx = H(3, 1);
dy = H(3, 2);
est=[dx, dy, theta];

%{
HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
  [dx,dy]], [0 0 1]'];
tformsRT = affine2d(HsRt);
imgBold1 = imwarp(im2, tformsRT, 'OutputView', imref2d(size(im2)));
%}
end