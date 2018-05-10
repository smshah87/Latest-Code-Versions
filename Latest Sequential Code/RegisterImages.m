function [tformsAll] = RegisterImages(PathName, posnum,regimage,channelsall)

fld = pwd;
Miji;
cd(fld)

rPath = [PathName '\Pos' num2str(posnum) '\' regimage];
path_to_fish = ['path=[' rPath ']'];
MIJ.run('Open...', path_to_fish);
%MIJ.run('Split Channels')
%regimage = MIJ.getImage(['C1-' regimage]);
regimage = uint16(MIJ.getCurrentImage);
MIJ.run('Close All')
MIJ.exit

S = load([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'Images.mat']);
hybnum = S.hybnum;
regis = S.regis;
registered{1} = regimage;

for i = 1:length(hybnum)
    channels = channelsall{i};
%     c = normxcorr2(max(regis{i},[],3),max(regimage,[],3));
%     [~, imax] = max(abs(c(:)));
%     [ypeak, xpeak] = ind2sub(size(c),imax(1));
%     corr_offset = [(xpeak-size(max(regis{i},[],3),2)) 
%                (ypeak-size(max(regis{i},[],3),1))];
%     c = normxcorr2(max(permute(regis{i},[1 3 2]),[],3),max(permute(regimage,[1 3 2]),[],3));
%     [~, imax] = max(abs(c(:)));
%     [ypeak, xpeak] = ind2sub(size(c),imax(1));
%     corr_offset2 = [(xpeak-size(max(regis{i},[],3),2)) 
%                (ypeak-size(max(regis{i},[],3),1))];
%      tform = affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; corr_offset(2) corr_offset(1) corr_offset2(2) 1]);
%     regimage = uint16(regimage);
%     regis{i} = imhistmatchn(uint16(regis{i}),regimage);
%     tformx = imregcorr(max(regis{i},[],3),max(regimage,[],3),'Window',true);
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumStepLength = 0.005;
    tformx = imregcorr(imadjust(max(regis{i},[],3)),imadjust(max(regimage,[],3)),'translation');
    
    dim1 = tformx.T(3,1);
    dim2 = tformx.T(3,2);
%     if norm([dim1 dim2]) > 30
%         c = normxcorr2(max(regis{i},[],3),max(regimage,[],3));
%         [~, imax] = max(abs(c(:)));
%         [ypeak, xpeak] = ind2sub(size(c),imax(1));
%         corr_offset = [(xpeak-size(max(regis{i},[],3),2)) (ypeak-size(max(regis{i},[],3),1))];
%         dim1 = corr_offset(2);
%         dim2 = corr_offset(1);
%         tformx.T(3,1) = dim1;
%         tformx.T(3,2) = dim2;
%     end
%     re = imwarp(regis{i},tformx,'OutputView',imref2d(size(max(regimage,[],3))));
%     tformz = imregcorr(max(permute(re,[1 3 2]),[],3),max(permute(regimage,[1 3 2]),[],3),'translation');
%     tformz2 = imregcorr(max(permute(re,[2 3 1]),[],3),max(permute(regimage,[2 3 1]),[],3),'translation');
%     az = [tformz.T(3,1) tformz2.T(3,1)];
%     [~,I] = min(abs(az));
%     z = az(I);
%     if abs(z)> 4
%         rer = permute(re(512,:,:),[2 3 1]);
%         rec = permute(re(:,512,:),[1 3 2]);
%         tformz = imregcorr(rec,permute(regimage(:,512,:),[1 3 2]),'translation');
%         tformz2 = imregcorr(rer,permute(regimage(512,:,:),[2 3 1]),'translation');
%         az = [tformz.T(3,1) tformz2.T(3,1)];
%         [~,I] = min(abs(az));
%         z = az(I);
%    end
%     tform = affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; dim1 dim2 z 1]);
%    [optimizer, metric] = imregconfig('monomodal'); 
%    tform = imregtform(regis{i},regimage,'translation',optimizer,metric,'InitialTransformation',tform);
    re = imwarp(regis{i},tformx,'OutputView',imref2d(size(max(regimage,[],3))));
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
    if abs(z)> 7
        tformz = imregtform(imadjust(max(permute(regis{i},[1 3 2]),[],3)),imadjust(max(permute(regimage,[1 3 2]),[],3)),'translation',optimizer,metric);
        tformz2 = imregtform(imadjust(max(permute(regis{i},[2 3 1]),[],3)),imadjust(max(permute(regimage,[2 3 1]),[],3)),'translation',optimizer,metric);
        az = [tformz.T(3,1) tformz2.T(3,1)];
        [~,I] = min(abs(az));
        z = az(I);
    end
    tform = affine3d([1 0 0 0; 0 1 0 0; 0 0 1 0; dim1 dim2 z 1]);
    tformsAll{i} = tform;
    registered{i+1} = imwarp(regis{i},tform,'OutputView',imref3d(size(regimage)));

    for j = 1:length(channels)
        hybnum(i).color{j} = imwarp(hybnum(i).color{j}, tform,'OutputView',imref3d(size(regimage)));
    end
end
fld = pwd;
Miji;
cd(fld);
za = cellfun(@(x) size(x,3),registered);
for i = 1:length(registered)
    MIJ.createImage(num2str(i),registered{i}(:,:,1:min(za)),true);
end

hordor = [];

for i = 1:length(registered)
    temp = ['image' num2str(i) '=' num2str(i)];
    hordor = [hordor ' ' temp];
end

str = ['title=[Concatenated Stacks] ' hordor];
MIJ.run('Concatenate...', str);
MIJ.run('Stack to Hyperstack...', ['order=xyzct channels=' num2str(length(registered)) ' slices=' num2str(min(za)) ' frames=1 display=Grayscale']);

MIJ.run('Save', ['save=[' PathName '\Pos' num2str(posnum) '\SequentialRegistrationCheck.tif' ']']);

MIJ.run('Close All')

MIJ.exit

save([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'SequentialHybsNewRegis.mat'], 'hybnum', 'tformsAll','registered','-v7.3')