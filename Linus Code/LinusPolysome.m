function dotlocations = LinusPolysome(PathName, posnum, dotlocations, corrections)

polysome = loadtiff([PathName '\Pos' num2str(posnum) '\Polysome.tif']);
im1 = loadtiff([PathName '\Pos' num2str(posnum) '\Hyb1RegistrationCheck.tif']);

regfixed = im1(:,:,1);
regmoving = polysome(:,:,end);

tform = imregcorr(regmoving,regfixed);
regmoving = imwarp(regmoving,tform,'OutputView',imref2d(size(im1(:,:,1))));

images = cat(3,regfixed,regmoving);

saveastiff(images, [PathName '\Pos' num2str(posnum) '\PolysomeRegistrationCheck.tif']);

corrections3D = cat(3,corrections.corrections{1},corrections.corrections{3},corrections.corrections{4});

polysome = uint16(double(polysome)./corrections3D);

fld = pwd;
Miji;
cd(fld);

MIJ.createImage('Polysome',polysome,true);
MIJ.run('Subtract Background...', 'rolling=3 stack');
polysome = uint16(MIJ.getCurrentImage);
MIJ.run('Close All');
MIJ.exit

polysome = imwarp(polysome,tform,'OutputView',imref2d(size(im1(:,:,1))));

for i = 1:length(dotlocations)
    for j = 1:size(dotlocations(i).cell,1)
        for k = 1:size(dotlocations(i).cell{j,5},1)
            x = round(dotlocations(i).cell{j,5}(k,1));
            y = round(dotlocations(i).cell{j,5}(k,2));
            mask = zeros(size(polysome(:,:,1)));
            mask(y-1:y+1,x-1:x+1) = 1;
            mask = logical(mask);
            for l = 1:2
                impoly = polysome(:,:,l);
                pixmax(k,l) = max(impoly(mask));
            end
        end
        dotlocations(i).cell{j,6} = pixmax;
        for l = 1:2
            avg(1,l) = mean(pixmax(:,l));
            avg(2,l) = std(double(pixmax(:,l)));
        end
        dotlocations(i).cell{j,7} = avg;
        clear avg
        clear pixmax
    end
end
            

