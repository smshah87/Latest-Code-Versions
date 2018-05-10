function [hybnum, corr_offset, images] = xCorrRegLinus( PathName,hybnum,hyb,channels,posnum )

%find offsets
for i = 1:hyb
    temp = loadtiff([PathName '\Pos' num2str(posnum) '\hyb' num2str(i) 'RegistrationCheck.tif']);
    if i == 1
        images(:,:,1) = temp(:,:,1);
    else
        tform = imregcorr(temp(:,:,1),images(:,:,1));
        tempreg = imwarp(temp(:,:,1),tform,'OutputView',imref2d(size(images(:,:,1))));
        images = cat(3,images, tempreg);
        corr_offset{i} = tform;
        for j = 1:length(channels)
            hybnum(i).color{j} = imwarp(hybnum(i).color{j},tform,'OutputView',imref2d(size(hybnum(1).color{j})));
        end
    end
end

saveastiff(images, [PathName '\Pos' num2str(posnum) '\AllHybRegistrationCheck.tif']);
