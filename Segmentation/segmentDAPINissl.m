function segmentDAPINissl(PathName,DAPI,Nissl,channelDAPI,channelNissl,offsets)
fld = pwd;
Miji;
cd(fld);
path_to_fish = ['path=[' PathName '\' DAPI ']'];
MIJ.run('Open...', path_to_fish);
%MIJ.run('Auto Crop')
MIJ.run('Duplicate...', ['duplicate channels=' num2str(channelDAPI)]);
MIJ.run('Gaussian Blur 3D...', 'x=2 y=2 z=2');
MIJ.run('Auto Threshold', 'method=Triangle white stack use_stack_histogram');    
ij = MIJ.getCurrentImage();
%illog = imdilate(~logical(ij),[1 1 1; 1 1 1; 1 1 1]);
%for i=1:size(illog,3); illog(:,:,i) = ~imfill(~illog(:,:,i),'holes'); end
for i=1:size(ij,3); illog(:,:,i) = ~bwareaopen(ij(:,:,i),100); end
% D2 = bwdist(illog);
% D = -D2;
% D(illog) = Inf; 
% D = imhmin(D,.25);%increase if oversegmented
% L = watershed(D);
% L(illog) = 0; 


MIJ.run('Close All');
path_to_fish = ['path=[' PathName '\' Nissl ']'];
MIJ.run('Open...', path_to_fish);
MIJ.run('Duplicate...', ['duplicate channels=' num2str(channelNissl)]);
nissel = MIJ.getCurrentImage();
MIJ.run('Gaussian Blur...', 'sigma=1');
MIJ.run('Auto Threshold', 'method=Yen white stack use_stack_histogram');    
nissl1 = MIJ.getCurrentImage();
if size(nissl1,3)>size(ij,3)
    nissl1 = nissl1(:,:,1:size(ij,3));
elseif size(nissl1,3)<size(ij,3)
    nissl1(:,:,size(nissl1,3):size(ij,3)) = repmat(nissl1(:,:,end),1,1,size(ij,3)-size(nissl1,3)+1);
end
MIJ.run('Close All');
nissl1 = imtranslate(nissl1,offsets{2});
illog = ~imtranslate(~illog,offsets{1});
%L = imtranslate(L,offsets{1});
illog2 = imdilate(~illog,ones(3));
full = illog2 | logical(nissl1);
full = bwareaopen(full,500);
%full = imdilate(full,ones(3,3));
edge = bwperim(full);

files = dir([PathName '\RoiSet\*.roi']);
[sROI] = ReadImageJROI(strcat(PathName, '\RoiSet\', {files.name}));
if length(sROI) == 1
    Aint = [sROI{1}.mnCoordinates sROI{1}.vnSlices];
else
    for yoyo = 1:length(sROI)
        Aint(yoyo,:) = [sROI{yoyo}.mnCoordinates sROI{yoyo}.vnSlices];
    end
end
for i = 1:length(Aint); lin(i)= sub2ind(size(illog2),Aint(i,2),Aint(i,1),Aint(i,3)); end

newIm = zeros(size(illog2));
newIm(lin) = 1;
newIm = imdilate(newIm, strel('sphere',5));

MIJ.createImage('p',uint16(newIm),true)
MIJ.createImage('f',uint16(edge*200),true)
MIJ.createImage('mask',uint16(full),true)
if size(nissel,3)>size(ij,3)
    nissel = nissel(:,:,1:size(ij,3));
elseif size(nissel,3)<size(ij,3)
    nissel(:,:,size(nissel,3):size(ij,3)) = repmat(nissel(:,:,end),1,1,size(ij,3)-size(nissel,3)+1);
end
MIJ.run('Marker-controlled Watershed', 'input=f marker=p mask=mask binary calculate use');
w = MIJ.getImage('f-watershed');
MIJ.run('Close All')
MIJ.createImage('p',uint16(newIm),true)
MIJ.createImage('edge',uint16(bwperim(logical(w))),true)
nissel = imtranslate(nissel,offsets{2});
MIJ.createImage('ce',nissel,true)
MIJ.run('Merge Channels...', 'c1=p c2=edge c4=ce create');
MIJ.run('Save', ['save=[' PathName '\SegmentationCheck2.tif' ']']);
MIJ.run('Close All')
save([PathName '\Segmentation.mat'],'w')

MIJ.exit

