function [tform, controlimage] = findtformV2(filename1,filename2)

%first use imageJ to do a 10 pixel background subtraction
%save individual channels
%Filename2 is reference image

img = loadtiff(filename1);
img2 = loadtiff(filename2);

logFish = max(img,[],3);
%logFish = double(max(fish,[],3));
thresh = multithresh(logFish,2);
%# s = 3D array
msk = true(3,3,3);
msk(2,2,2) = false;
%# assign, to every voxel, the maximum of its neighbors
apply = logFish < thresh(1);
logFish(apply) = 0;
s_dil = imdilate(logFish,msk);
m = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors

[y,x] = ind2sub(size(m),find(m == 1));
        figure 
        imshow(max(img,[],3));
        hold on;
        [v2,v1]=find(max(m,[],3)==1);
        scatter(v1(:),v2(:),75);
        hold off;
centroids = [x,y];
logFish = max(img2,[],3);
%logFish = double(max(fish,[],3));
thresh = multithresh(logFish,2);
%# s = 3D array
msk = true(3,3,3);
msk(2,2,2) = false;
%# assign, to every voxel, the maximum of its neighbors
apply = logFish < thresh(1);
logFish(apply) = 0;
s_dil = imdilate(logFish,msk);
m = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors

[y,x] = ind2sub(size(m),find(m == 1));

centroids2 = [x,y];

        figure 
        imshow(max(img2,[],3));
        hold on;
        [v2,v1]=find(max(m,[],3)==1);
        scatter(v1(:),v2(:),75);
        hold off;

%while
    %[indexPairs] = matchFeatures(centroids,centroids2);%,'Method','NearestNeighborSymmetric');
    indexPairs = knnsearch(centroids,centroids2,'NSMethod','Exhaustive');
    matchedPoints1 = centroids(indexPairs,:);
    matchedPoints2 = centroids2;
    dist = sum((matchedPoints1 - matchedPoints2).^2,2);
    dist = dist<70;
    matchedPoints1 = matchedPoints1(dist,:);
    matchedPoints2 = matchedPoints2(dist,:);
    moving_pts_adj= cpcorr(matchedPoints1, matchedPoints2, img, img2);
    figure; showMatchedFeatures(img, img2, moving_pts_adj, matchedPoints2);
%end

%tform = fitgeotrans(matchedPoints1,matchedPoints2,'polynomial',4); %matchedpoints2 is reference channel
tform = fitgeotrans(matchedPoints1,matchedPoints2,'projective');
controlimage = imwarp(img,tform,'OutputView',imref2d(size(img2)));

falsecolorOverlay1 = imfuse(img2,controlimage);
falsecolorOverlay2 = imfuse(img2,img);
figure;
imshow(falsecolorOverlay1,'InitialMagnification','fit');
figure;
imshow(falsecolorOverlay2,'InitialMagnification','fit');

LinkFigures(4:5)
