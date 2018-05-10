function [hybnum, corr_offset, zfocus] = xCorrRegistration(PathName,posnum, hybnum,hyb,channels, Zdim, Autofocus, debug)

%[sub_hyb2,rect_hyb2] = imcrop(uint8(hybrid2(:,:,2))); %smaller
%[sub_hyb1,rect_hyb1] = imcrop(uint8(hybrid1(:,:,2))); %larger
hybnumtemp = hybnum;
for j = 1:hyb
    for i = 1:length(channels)
        test(:,:,i) = max(hybnum(j).color{i},[],3);
    end
    maxim{j} = max(test,[],3);
end

for i = 1:hyb
    %c = normxcorr2(maxim{i},maxim{hyb});
    c = normxcorr2(maxim{i},maxim{hyb});
    [~, imax] = max(abs(c(:)));
    [ypeak, xpeak] = ind2sub(size(c),imax(1));
    corr_offset{i} = [(xpeak-size(maxim{hyb},2)) (ypeak-size(maxim{hyb},1))];
%     tform = imregcorr(maxim{i},maxim{hyb});
%     corr_offset{i} = [round(tform.T(3,1)) round(tform.T(3,2))];
end

for i = 1:hyb
    for j = 1:length(channels)
            hybnum(i).color{j} = imtranslate(hybnumtemp(i).color{j},corr_offset{i});
    end
end

if Zdim == 1
    
    hybnumtemp = hybnum;
    clear test;
    for j = 1:hyb
        for i = 1:length(channels)
            test(:,:,i) = permute(max(hybnum(j).color{i},[],2),[1 3 2]);
        end
        maxim{j} = max(test,[],3);
        clear test;
    end

    for i = 1:hyb
        %c = normxcorr2(maxim{i},maxim{hyb});
        template = size(maxim{i},2);
        A = size(maxim{hyb},2);
        if template > A
            maxim{i} = maxim{i}(:,1:A);
        end
        c = normxcorr2(maxim{i},maxim{hyb});
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offsetxz{i} = [(xpeak-size(maxim{hyb},2)) (ypeak-size(maxim{hyb},1))];
    end
    
        clear test;
    for j = 1:hyb
        for i = 1:length(channels)
            test(:,:,i) = permute(max(hybnum(j).color{i},[],1),[2 3 1]);
        end
        maxim{j} = max(test,[],3);
        clear test;
    end

    for i = 1:hyb
        %c = normxcorr2(maxim{i},maxim{hyb});
        template = size(maxim{i},2);
        A = size(maxim{hyb},2);
        if template > A
            maxim{i} = maxim{i}(:,1:A);
        end
        c = normxcorr2(maxim{i},maxim{hyb});
        [max_c, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offsetyz{i} = [(xpeak-size(maxim{hyb},2)) (ypeak-size(maxim{hyb},1))];
    end
    
    for i = 1:hyb
        z(i) = round((corr_offsetyz{i}(1) + corr_offsetxz{i}(1))/2);
    end
    
    for i = 1:hyb
        for j = 1:length(channels)
            hybnum(i).color{j} = imtranslate(hybnumtemp(i).color{j},[0 0 z(i)]);
        end
        corr_offset{i} = [corr_offset{i} z(i)];
    end
    
end

if Autofocus == 1
    zstart = AutoFocus(hybnum, hyb, channels,debug);
    for i = 1:hyb
        for j = 1:length(channels)
            zfocus = min(zstart);
            hybnum(i).color{j} = hybnum(i).color{j}(:,:,min(zstart):end);
        end
    end
else
    zfocus = [];
end
maxim = [];
for j = 1:hyb
    for i = 1:length(channels)
        test(:,:,i) = max(hybnum(j).color{i},[],3);
    end
    maxim(:,:,j) = uint16(max(test,[],3));
end

saveastiff(uint16(maxim),[PathName '\Pos' num2str(posnum) '\BarcodingRegistrationCheck.tif'])

for i = 1:hyb
    za = size(hybnum(i).color{1},3);
end

for j = 1:hyb
    for i = 1:min(za)
        for k = 1:length(channels)
            test(:,:,k) = hybnum(j).color{k}(:,:,i);
        end
        im(:,:,i) = max(test,[],3);
    end
    registration{j} = im;
end

fld = pwd;
Miji;
cd(fld);

for i = 1:length(registered)
    MIJ.createImage(num2str(i),registered{i},true);
end

hordor = [];

for i = 1:length(registered)
    temp = ['image' num2str(i) '=' num2str(i)];
    hordor = [hordor ' ' temp];
end

str = ['title=[Concatenated Stacks] ' hordor];
MIJ.run('Concatenate...', str);
MIJ.run('Stack to Hyperstack...', ['order=xyzct channels=' num2str(length(registered)) ' slices=' num2str(min(za)) ' frames=1 display=Grayscale']);

MIJ.run('Save', ['save=[' PathName '\Pos' num2str(posnum) '\BarcodingRegistrationCheckZdim.tif' ']']);

MIJ.run('Close All')

MIJ.exit
