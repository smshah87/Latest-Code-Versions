function [tform, controlimage] = findtform(filename1,filename2,slice)

%first use imageJ to do a 10 pixel background subtraction
%save individual channels
%Filename2 is reference image

img = loadtiff(filename1);
img2 = loadtiff(filename2);

I = multithresh(img,2);
bw1 = img>I(1)*1;
I2 = multithresh(img2,2);
bw2 = img2>I2(1)*1;

s = regionprops(bw1,'centroid');
centroids = cat(1, s.Centroid);
figure; imshow(bw1)
hold on
plot(centroids(:,1),centroids(:,2), 'b*')
hold off

s2 = regionprops(bw2,'centroid');
centroids = cat(1, s2.Centroid);
figure; imshow(bw2)
hold on
plot(centroids(:,1),centroids(:,2), 'b*')
hold off

centroids = cat(1, s.Centroid);
centroids2 = cat(1, s2.Centroid);

%while
    %[indexPairs] = matchFeatures(centroids,centroids2);%,'Method','NearestNeighborSymmetric');
    indexPairs = knnsearch(centroids,centroids2,'NSMethod','Exhaustive');
    matchedPoints1 = centroids(indexPairs,:);
    matchedPoints2 = centroids2;
    dist = sum((matchedPoints1 - matchedPoints2).^2,2);
    dist = dist<70;
    matchedPoints1 = matchedPoints1(dist,:);
    matchedPoints2 = matchedPoints2(dist,:);
    moving_pts_adj= cpcorr(matchedPoints1, matchedPoints2, bw1, bw2);
    figure; showMatchedFeatures(bw1, bw2, moving_pts_adj, matchedPoints2);
%end

tform = fitgeotrans(matchedPoints1,matchedPoints2,'polynomial',4); %matchedpoints2 is reference channel
%tform = fitgeotrans(matchedPoints1,matchedPoints2,'nonreflectivesimilarity');
controlimage = imwarp(img(:,:,slice),tform,'OutputView',imref2d(size(img2)));

falsecolorOverlay1 = imfuse(img2(:,:,slice),controlimage);
falsecolorOverlay2 = imfuse(img2(:,:,slice),img(:,:,slice));
figure('name','Corrected');
imshow(falsecolorOverlay1,'InitialMagnification','fit');
figure('name','Uncorrected');
imshow(falsecolorOverlay2,'InitialMagnification','fit');


