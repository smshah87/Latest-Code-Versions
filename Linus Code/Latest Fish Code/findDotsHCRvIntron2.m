function [color, m,dots,BWfull,thresholds, copy, celldata, corr_offset] = findDotsHCRvIntron2(PathName, channels, multiplier, HCRorFISH,BWfull,zmask,corrections,registration,regvec, debug)%,tform3,tform4)
%load('tforms.mat');
%addpath('/Applications/Fiji.app/scripts');
fld = pwd;
Miji;
cd(fld)
if isempty(PathName) 
    [FileName,PathName,FilterIndex] = uigetfile('.tif');
    path_to_fish = ['path=[' PathName FileName ']'];
else
    path_to_fish = ['path=[' PathName ']'];
    C = strsplit(PathName,'\');
    FileName = C{end};
    k = strfind(PathName,'\');
    PathName = PathName(1:k(end)-1);
end

if ~isempty(registration)
    path_to_fish2 = ['path=[' PathName '\ClickDAPI.tif' ']'];
    MIJ.run('Open...', path_to_fish2);
    %range = inputdlg('Where Should I Start In Z');
    %range2 = inputdlg('Where Should I End in Z');
    %MIJ.run('Subtract Background...', 'rolling=3 stack');
    %MIJ.run('Split Channels');
    %name = ['C6-' num2str(registration) '.tif'];
    imtemp = uint16(MIJ.getCurrentImage);
    DAPI = imtemp;
    MIJ.run('Close All');
    MIJ.run('Open...', path_to_fish);
%range = inputdlg('Where Should I Start In Z');
    %MIJ.run('Subtract Background...', 'rolling=3 stack');
    MIJ.run('Split Channels');
    imtemp = uint16(MIJ.getImage(['C' num2str(registration) '-' FileName]));
    imDAPI = imtemp;
    %DAPI = imhistmatch(max(DAPI,[],3),(max(imDAPI,[],3)));
    tform = imregcorr(max(imDAPI,[],3),max(DAPI,[],3),'translation');
    corr_offset = [round(tform.T(3,1)) round(tform.T(3,2))];
else 
    corr_offset = [0 0];
    MIJ.run('Open...', path_to_fish);
%range = inputdlg('Where Should I Start In Z');
MIJ.run('Split Channels');
end

for dum = 1:length(channels)
    name = ['C' num2str(channels(dum)) '-' FileName];
    color{channels(dum)} = uint16(MIJ.getImage(name));
    B = repmat(corrections{channels(dum)},1,1,size(color{channels(dum)},3));
    color{channels(dum)} = double(color{channels(dum)})./B;
    color{channels(dum)} = uint16(color{channels(dum)});
end

MIJ.run('Close All');
FileName(ismember(FileName,' ,.:;!')) = [];
for d = 1:length(channels)
    namesh{channels(d)} = ['C' num2str(channels(d)) '-' FileName];
    MIJ.createImage(namesh{channels(d)}, color{channels(d)}, true);
end
if length(channels) > 1
    hordor = [];
    for i = 1:length(channels)
        if length(channels) <4 && i == length(channels)
           chnum = 4;
        else
           chnum = i;
        end
        temp = ['c' num2str(chnum) '=' namesh{channels(i)}];
        hordor = [hordor ' ' temp];
    end

    MIJ.run('Merge Channels...', hordor); %c4=C4-' FileName '.tif c5=C5-' FileName '.tif']);    
end

MIJ.run('Subtract Background...', 'rolling=3 stack');

if length(channels) > 1 
    MIJ.run('Split Channels');
end

for dum = 1:length(channels)
    name = ['C' num2str(channels(dum)) '-' FileName];
    color{channels(dum)} = imtranslate(uint16(MIJ.getImage(name)),corr_offset);
end


MIJ.run('Close All');

MIJ.exit;

%     for i = 1:length(channels)
%         figure; histogram(double(color{dum}));
%     end
    
    z = size(color{1},3);
%     if z > 1
%         range = inputdlg('Where Should I Start In Z');
%     else
         range{1} = '1';
%     end
%     for i = 1:z
%         color{2}(:,:,i) = imwarp(color{2}(:,:,i),tform3,'OutputView',imref2d(size(color{2})));
%     end

%     for i = 1:z
%        color{3}(:,:,i) = imwarp(color{3}(:,:,i),tform4,'OutputView',imref2d(size(color{2})));
%     end
if isempty(BWfull) == 1    
    figure; imshow(max(color{length(color)},[],3),[0 mean(mean(max(color{length(color)},[],3)))+2000])
    answer = inputdlg('How Many ROIs Will You Choose');
    for i = 1:str2num(answer{1})
        BW(:,:,i) = roipoly;
    end

    BWfull = repmat(max(BW,[],3),1,1,z-str2double(range{1})+1);
    segmentation = 'off';
elseif strcmp('off',BWfull)
    disp('ROI Selector is off')
    segmentation = 'off';
elseif strcmp('roi',BWfull)
    vertex = selfseg([PathName '/RoiSet']);
    for i = 1:length(vertex)
        BWt = poly2mask(vertex(i).x+regvec(1), vertex(i).y+regvec(2), 2048, 2048);
        BW(:,:,i) = imerode(BWt,strel('disk',3));
    end
    %BWfull = imdilate(max(BW,[],3),ones(3,3));
    BWfull = max(BW,[],3);
    segmentation = 'roi';
    disp('ImageJ ROIs being used');
elseif strcmp('roi+3Dmask',BWfull)
    BWfull = zmask;
    segmentation = 'roi';
else
    BWfull = repmat(BWfull(:,:,1),1,1,z-str2double(range{1})+1);  
end

for dee = 1:length(channels)
    
    fish = color{channels(dee)}(:,:,str2double(range{1}):end);
    if ~strcmp('off',BWfull)
        if size(fish,3)>size(BWfull,3)
            BWfull(:,:,size(BWfull,3):size(fish,3)) = repmat(BWfull(:,:,end),1,1,size(fish,3)-size(BWfull,3)+1);
            fish = fish.*uint16(BWfull);
        else
            fish = fish.*uint16(BWfull(:,:,1:size(fish,3)));
        end
    end
    
    if HCRorFISH(dee) == 1
        logFish=[];
        fish=double(fish);
        %fish = double(max(fish,[],3));
        for i=1:size(fish,3)
            logFish(:,:,i)=logMask(fish(:,:,i));
        end
        cands=imregionalmax(logFish);
        thresh=multiplier(dee);
        m{dee}= cands & logFish > thresh(1);
    elseif HCRorFISH(dee) == 2
        logFish = fish;
        %logFish = double(max(fish,[],3));
        thresh = multithresh(logFish,2)*multiplier(dee);
        %# s = 3D array
        msk = true(3,3,3);
        msk(2,2,2) = false;
        %# assign, to every voxel, the maximum of its neighbors
        apply = logFish < thresh(2);
        thresh = thresh(2);
        logFish(apply) = 0;
        s_dil = imdilate(logFish,msk);
        m{dee} = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors
    elseif HCRorFISH(dee) == 3
        logFish = fish;
        thresh = multithresh(logFish,2)*multiplier(dee);
        apply = logFish < thresh(2);
        logFish(apply) = 0;
        cands = imregionalmax(logFish);
        m{dee} = cands;
    elseif HCRorFISH(dee) == 4
        logFish = fish;
        thresh = multithresh(logFish,1)*multiplier(dee);
        apply = logFish < thresh(1);
        logFish(apply) = 0;
        cands = imregionalmax(logFish);
        m{dee} = cands; 
    else
        logFish = fish;
        %logFish = double(max(fish,[],3));
        %sdev = mad(mad(double(max(fish,[],3))));
        %med = median(median(double(max(fish,[],3))));
        %logFish2 = logFish;
        %logFish2(logFish2>5*sdev) = med;
        thresh = multithresh(logFish,1)*multiplier(dee);
        if thresh == 0
            thresh = mean(mean(double(max(fish,[],3))));
        end
        %# s = 3D array
        msk = true(3,3,3);
        msk(2,2,2) = false;
        %# assign, to every voxel, the maximum of its neighbors
        apply = logFish < multiplier;
        %thresh = thresh(th);
        logFish(apply) = 0;
        s_dil = imdilate(logFish,msk);
        m{dee} = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors
    end    

    
    if debug == 1
        figure 
        imshow(max(color{channels(dee)},[],3),[min(min(max(color{channels(dee)},[],3))) mean(mean(max(color{channels(dee)},[],3)))+5000]);
        hold on;
        [v2,v1]=find(max(m{dee},[],3)==1);
        scatter(v1(:),v2(:),75);
        hold off;
        %txt_h = labelpoints(v1+.05, v2+.05, ind2sub(size(v1),v1), 'NE',.01 ,'Color','y');
    end
    
    [y,x,z] = ind2sub(size(m{dee}),find(m{dee} == 1));
    
    dots(dee).channels = [x y z];
    im = max(color{channels(dee)},[],3);
    for i = 1:length(y)
        dots(dee).intensity(i,1) = im(y(i),x(i));
        %dots(dee).integratedintensity(i,1) = sum(sum(im(y(i)-1:y(i)+1,x(i)-1:x(i)+1)));
    end
    thresholds(dee) = thresh(1);
end

if strcmp(segmentation, 'roi')
    vertex = selfseg([PathName '/RoiSet']);
    for i = 1:length(vertex)
            for k = 1:length(channels)
                include = inpolygon(dots(k).channels(:,1),dots(k).channels(:,2),vertex(i).x+regvec(1),vertex(i).y+regvec(2));
                copy(k,i) = sum(include);
                celldata.Positions{k,i} = dots(k).channels(include,:);
                if isfield(dots,'intensity')
                    celldata.Intensity{k,i} = dots(k).intensity(include);
                end
            end
    end
else
    copy = [];
    celldata = [];
end