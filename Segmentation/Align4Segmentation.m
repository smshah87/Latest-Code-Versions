function [offsets] = Align4Segmentation(PathName, posnum, imageNames, channelsall, regchan, regimage, offsets)

if ~isempty(regimage)
    regimage = loadtiff([PathName '\Pos' num2str(posnum) '\' regimage]);
end
registered{1} = regimage;

fld = pwd;
Miji;
cd(fld);

for i = 1:length(imageNames)
    
    channels = channelsall{i};
    PathName2 = [PathName '\Pos' num2str(posnum) '\' imageNames{i} '.tif'];
    path_to_fish = ['path=[' PathName2 ']'];
    MIJ.run('Open...', path_to_fish);
    
    if length(channels) > 1 || channels > 1 || ~isempty(regchan{i}) && channels ~= regchan{i}
        MIJ.run('Split Channels');
        for dum = 1:length(channels)
            name = ['C' num2str(channels(dum)) '-' imageNames{i} '.tif'];
            color{dum} = uint16(MIJ.getImage(name));
        end
    else
        color{1} = uint16(MIJ.getCurrentImage);
    end
    
    if ~isempty(regchan{i})
        if channels == regchan{i}
            regis = uint16(MIJ.getImage([imageNames{i} '.tif']));
        else
            regis = uint16(MIJ.getImage(['C' num2str(regchan{i}) '-' imageNames{i} '.tif']));
        end
        [optimizer, metric] = imregconfig('monomodal');
        optimizer.MaximumStepLength = 0.005;
        tformx = imregcorr(imadjust(max(regis,[],3)),imadjust(max(regimage,[],3)),'translation');
    
        dim1 = tformx.T(3,1);
        dim2 = tformx.T(3,2);
        
        re = imwarp(regis,tformx,'OutputView',imref2d(size(max(regimage,[],3))));
        tformz = imregcorr(imadjust(max(permute(re,[1 3 2]),[],3)),imadjust(max(permute(regimage,[1 3 2]),[],3)),'translation');
        tformz2 = imregcorr(imadjust(max(permute(re,[2 3 1]),[],3)),imadjust(max(permute(regimage,[2 3 1]),[],3)),'translation');
        az = [tformz.T(3,1) tformz2.T(3,1)];
        if tformz2.T(3,2) ~= 0
            az(2) = [];
        end
        if tformz.T(3,2) ~= 0
            az(1) = [];
        end
        if size(az,2) == 2
            [~,I] = min(abs(az));
            z = az(I);
        elseif size(az,2) == 1
            z = az;
        else
            z = 100;
        end
        if abs(z)> 6
            tformz = imregtform(imadjust(max(permute(regis,[1 3 2]),[],3)),imadjust(max(permute(regimage,[1 3 2]),[],3)),'translation',optimizer,metric);
            tformz2 = imregtform(imadjust(max(permute(regis,[2 3 1]),[],3)),imadjust(max(permute(regimage,[2 3 1]),[],3)),'translation',optimizer,metric);
            az = [tformz.T(3,1) tformz2.T(3,1)];
            [~,I] = min(abs(az));
            z = az(I);
        end
        if abs(z) > 6
            c = normxcorr2(imadjust(max(permute(regimage,[1 3 2]),[],3)),imadjust(max(permute(regis,[1 3 2]),[],3)));
            [~, imax] = max(abs(c(:)));
            [ypeak, xpeak] = ind2sub(size(c),imax(1));
            corr_offset = [(xpeak-size(max(permute(regimage,[1 3 2]),[],3),2)) (ypeak-size(max(permute(regimage,[1 3 2]),[],3),1))];
            az(1) = corr_offset(1);
            c = normxcorr2(imadjust(max(permute(regimage,[2 3 1]),[],3)),imadjust(max(permute(regis,[2 3 1]),[],3)));
            [~, imax] = max(abs(c(:)));
            [ypeak, xpeak] = ind2sub(size(c),imax(1));
            corr_offset = [(xpeak-size(max(permute(regimage,[2 3 1]),[],3),2)) (ypeak-size(max(permute(regimage,[2 3 1]),[],3),1))];
            az(2) = corr_offset(1);
            [~,I] = min(abs(az));
            z = -1*az(I);
        end
        tform = affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; -28 0 z 1]);
        
    else
        tform = affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; offsets{i}(1) offsets{i}(2) offsets{i}(3) 1]);
    end
    
    MIJ.run('Close All');
    offsets{i} = tform;
    if ~isempty(regchan{i})
        registered{i+1} = imwarp(regis,tform,'OutputView',imref3d(size(regimage)));
    end
    
    hordor = [];
    
    for j = 1:length(channels)
        color{j} = imwarp(color{j},tform,'OutputView',imref3d(size(regimage)));
        %hybnum(i).color{j} = hybnum(i).color{j}(:,:,zstart:end);

        if length(channels) <4 && j == length(channels)
            chnum = 4;
        else
            chnum = j;
        end
        
        MIJ.createImage(num2str(chnum),color{j},true)
        
        temp = ['c' num2str(chnum) '=' num2str(chnum)];
        hordor = [hordor ' ' temp];

    end
    
    if length(channels) == 1
        saveastiff(color{1},[PathName '\Pos' num2str(posnum) '\' imageNames{i} 'Registered.tif']);
    elseif length(channels) > 1 && isempty(regchan{i})
        MIJ.run('Merge Channels...', hordor);
        MIJ.run('Save', ['save=[' PathName '\Pos' num2str(posnum) '\' imageNames{i} 'Registered.tif' ']']);
    else
        MIJ.createImage(num2str(chnum+1),registered{i},true)
        temp = ['c' num2str(chnum+1) '=' num2str(chnum+1)];
        hordor = [hordor ' ' temp];

        MIJ.run('Merge Channels...', hordor);
        MIJ.run('Save', ['save=[' PathName '\Pos' num2str(posnum) '\' imageNames{i} 'Registered.tif' ']']);
    end
    
    MIJ.run('Close All');
    
    za = cellfun(@(x) size(x,3),registered);
    for b = 1:length(registered)
        MIJ.createImage(num2str(b),registered{b}(:,:,1:min(za)),true);
    end

    hordor = [];

    for b = 1:length(registered)
        temp = ['image' num2str(b) '=' num2str(b)];
        hordor = [hordor ' ' temp];
    end

    str = ['title=[Concatenated Stacks] ' hordor];
    MIJ.run('Concatenate...', str);
    MIJ.run('Stack to Hyperstack...', ['order=xyzct channels=' num2str(length(registered)) ' slices=' num2str(min(za)) ' frames=1 display=Grayscale']);

    MIJ.run('Save', ['save=[' PathName '\Pos' num2str(posnum) '\SegRegCheck2.tif' ']']);
    MIJ.run('Close All');
end

MIJ.exit
