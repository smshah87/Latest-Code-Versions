function [tform] = findtformV4(filename1,filenameREF)

im1 = loadtiff(filename1);
imref = loadtiff(filenameREF);

im1 = imhistmatch(im1,imref);

[tform, im1_reg] = imregdemons(im1,imref);

figure;
imshowpair(im1,imref);
figure;
imshowpair(im1_reg,imref)
LinkFigures(1:2)


