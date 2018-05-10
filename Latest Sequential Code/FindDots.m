function FindDots(PathName,posnum, hybs, channels, multiplier, HCRorFISH,BWfull,zmask, debug)

load([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'SequentialHybsNewRegis.mat']);
z = 1;
for num = 1:hybs
    
    color = hybnum(num).color;
    
    if isempty(BWfull) == 1    
        figure; imshow(max(color{length(color)},[],3),[0 mean(mean(max(color{length(color)},[],3)))+2000])
        answer = inputdlg('How Many ROIs Will You Choose');
        for i = 1:str2num(answer{1})
            BW(:,:,i) = roipoly;
        end

        BWfull = repmat(max(BW,[],3),1,1,z);
        segmentation = 'off';
    elseif strcmp('off',BWfull)
        segmentation = 'off';
    elseif strcmp('roi',BWfull)
        BWfull = 'off';
        segmentation = 'roi';
    elseif strcmp('roi+3Dmask',BWfull)
        BWfull = zmask;
        segmentation = 'roi';
    else
        BWfull = repmat(BWfull(:,:,1),1,1,z);  
    end

    for dee = 1:length(channels{num})

        fish = color{channels{num}(dee)};
        if ~strcmp('off',BWfull)
            if size(fish,3)>size(BWfull,3)
                BWfull(:,:,size(BWfull,3):size(fish,3)) = repmat(BWfull(:,:,end),1,1,size(fish,3)-size(BWfull,3)+1);
                fish = fish.*uint16(BWfull);
            else
                fish = fish.*uint16(BWfull(:,:,1:size(fish,3)));
            end
        end

        if HCRorFISH(num,dee) == 1
            logFish=[];
            fish=double(fish);
            %fish = double(max(fish,[],3));
            for i=1:size(fish,3)
                logFish(:,:,i)=logMask(fish(:,:,i));
            end
            cands=imregionalmax(logFish);
            thresh=multiplier(dee);
            m{dee}= cands & logFish > thresh(1);
        elseif HCRorFISH(num,dee) == 2
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
        elseif HCRorFISH(num,dee) == 3
            logFish = fish;
            thresh = multithresh(logFish,2)*multiplier(dee);
            apply = logFish < thresh(2);
            logFish(apply) = 0;
            cands = imregionalmax(logFish);
            m{dee} = cands;
        elseif HCRorFISH(num,dee) == 4
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
            thresh = multiplier(num,dee);
            if thresh == 0
                thresh = mean(mean(double(max(fish,[],3))));
            end
            %# s = 3D array
            msk = true(3,3,3);
            msk(2,2,2) = false;
            %# assign, to every voxel, the maximum of its neighbors
            apply = logFish < thresh;
            %thresh = thresh(th);
            logFish(apply) = 0;
            s_dil = imdilate(logFish,msk);
            m{dee} = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors
        end    


        if debug == 1
            figure 
            imshow(max(color{channels{num}(dee)},[],3),[min(min(max(color{channels{num}(dee)},[],3))) mean(mean(max(color{channels{num}(dee)},[],3)))+5000]);
            hold on;
            [v2,v1]=find(max(m{dee},[],3)==1);
            scatter(v1(:),v2(:),75);
            hold off;
            %txt_h = labelpoints(v1+.05, v2+.05, ind2sub(size(v1),v1), 'NE',.01 ,'Color','y');
        end

        [y,x,z] = ind2sub(size(m{dee}),find(m{dee} == 1));

        dots(dee).channels = [x y z];
        im = max(color{channels{num}(dee)},[],3);
        for i = 1:length(y)
            dots(dee).intensity(i,1) = im(y(i),x(i));
            %dots(dee).integratedintensity(i,1) = sum(sum(im(y(i)-1:y(i)+1,x(i)-1:x(i)+1)));
        end
        %thresholds(dee) = thresh(1);
    end

    if strcmp(segmentation, 'roi')
        vertex = selfseg([PathName '/RoiSet']);
        for i = 1:length(vertex)
                for k = 1:length(channels{num})
                    include = inpolygon(dots(k).channels(:,1),dots(k).channels(:,2),vertex(i).x,vertex(i).y);
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
    Data(num).copy = copy;
    Data(num).celldata = celldata;
    Data(num).dots = dots;
    clear dots;
end

save([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'AllCounts2.mat'], 'Data')