function [tform] = findtformV3(filename1,filenameREF)

im1 = loadtiff(filename1);
imref = loadtiff(filenameREF);
%im1 = imhistmatch(im1,imref);
%im1 = imhistmatch(im1,imref);

[optimizer, metric] = imregconfig('monomodal');
tform = imregtform(im1, imref, 'similarity', optimizer, metric);

im1reg = imwarp(im1,tform,'OutputView',imref2d(size(imref)));

falsecolorOverlay1 = imfuse(im1,imref);
falsecolorOverlay2 = imfuse(im1reg,imref);
figure;
imshow(falsecolorOverlay1,'InitialMagnification','fit');
figure;
imshow(falsecolorOverlay2,'InitialMagnification','fit');

LinkFigures(1:2)