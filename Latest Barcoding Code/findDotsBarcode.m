function [m,dots] = findDotsBarcode(images, multiplier, HCRorFISH,lowerlim,upperlim,debug)%BWfull)%,tform3,tform4)


%     for i = 1:length(channels)
%         figure; histogram(double(color{dum}));
%     end
    
%z = size(images{1},3);
% if isempty(BWfull) == 1    
%     figure; imshow(max(images{1},[],3),[0 mean(mean(max(images{1},[],3)))+2000])
%     answer = inputdlg('How Many ROIs Will You Choose');
%     for i = 1:str2num(answer{1})
%         BW(:,:,i) = roipoly;
%     end
%     BWfull = repmat(max(BW,[],3),1,1,z);
% else
%     BWfull = repmat(BWfull(:,:,1),1,1,z);    
% end

for dee = 1:length(images)
    
    fish = images{dee};
    %fish = fish.*uint16(BWfull);
    
    if HCRorFISH(dee) == 1 %fish
        logFish=[];
        fish=double(fish);
        %fish = double(max(fish,[],3));
        for i=1:size(fish,3)
            logFish(:,:,i)=logMask(fish(:,:,i));
        end
        cands=imregionalmax(logFish);
        sortedValues = unique(logFish(cands));
        p10 = round(length(sortedValues)*.1);
        maxValues = sortedValues(end-p10:end);  
        maxIndex = ismember(logFish,maxValues);  
        logFish2 = logFish;
        logFish2(maxIndex) = mean(mean(mean(logFish)));
        thresh=multithresh(mat2gray(logFish2(cands)),2)*max(logFish2(cands))*multiplier(dee);
        dtf = 0;
        iter = 0;
        while dtf<lowerlim || dtf > upperlim
            m{dee}= cands & logFish > thresh(1);
            bord = ones(size(m{dee}));
            bord(1:5,:,:) = 0;
            bord(end-5:end,:,:) = 0;
            bord(:,end-5:end,:) = 0;
            bord(:,1:5,:) = 0;
            m{dee} = m{dee}.*logical(bord);
            dtf = sum(sum(sum(m{dee})));
            if dtf< lowerlim %28000
                thresh(1) = thresh(1) - 100;
            elseif dtf > upperlim %33000
                thresh(1) = thresh(1) + 150;
            end
            iter = iter + 1;
            if iter == 250
                iter = 0;
                thresh=multithresh(mat2gray(logFish2(cands)),2)*max(logFish2(cands))*multiplier(dee)*rand;
            end
        end
    elseif HCRorFISH(dee) == 2
        logFish = fish;
        %logFish = double(max(fish,[],3));
        baba = sort(logFish(:));
        thresh = multithresh(baba(1:(length(baba)-100)),2)*multiplier(dee);
        %# s = 3D array
        msk = true(3,3,3);
        msk(2,2,2) = false;
        %# assign, to every voxel, the maximum of its neighbors
        apply = logFish < thresh(2);
        logFish(apply) = 0;
        s_dil = imdilate(logFish,msk);
        m{dee} = logFish > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors
        dtf = sum(sum(sum(m{dee})));
        iter = 0;
        while dtf <8000 || dtf > 12000
            if dtf< 8000%28000
                thresh(2) = thresh(2) - 30;
            elseif dtf > 12000 %33000
                thresh(2) = thresh(2) + 53;
            end
            logFish = fish;
            apply = logFish < thresh(2);
            logFish(apply) = 0;
            s_dil = imdilate(logFish,msk);
            m{dee} = logFish > s_dil;
            dtf = sum(sum(sum(m{dee})));
            iter = iter + 1;
            if iter == 250
                iter = 0;
                thresh = multithresh(baba(1:(length(baba)-100)),2)*multiplier(dee)*rand;
            end
        end
    elseif HCRorFISH(dee) == 3
        logFish=[];
        fish=double(fish);
        %fish = double(max(fish,[],3));
        for i=1:size(fish,3)
            logFish(:,:,i)=logMask(fish(:,:,i));
        end
        cands=imregionalmax(logFish);
        sortedValues = unique(logFish(cands));
        p10 = round(length(sortedValues)*.1);
        maxValues = sortedValues(end-p10:end);  
        maxIndex = ismember(logFish,maxValues);  
        logFish2 = logFish;
        logFish2(maxIndex) = mean(mean(mean(logFish)));
        thresh=multithresh(mat2gray(logFish2(cands)),2)*max(logFish2(cands))*multiplier(dee);
        m{dee}= cands & logFish > thresh(1);
        bord = ones(size(m{dee}));
        bord(1:5,:,:) = 0;
        bord(end-5:end,:,:) = 0;
        bord(:,end-5:end,:) = 0;
        bord(:,1:5,:) = 0;
        m{dee} = m{dee}.*logical(bord);
    else
        logFish = fish;
        %logFish = double(max(fish,[],3));
        thresh = multiplier(dee);
        th = 1;
%         while thresh < 200;
%             th = th + 1;
%             thresh = multithresh(logFish,th)*multiplier(dee);
%         end
        %# s = 3D array
        msk = true(3,3,3);
        msk(2,2,2) = false;
        %# assign, to every voxel, the maximum of its neighbors
        dtf = 0;
        while dtf<lowerlim || dtf > upperlim
            logFish2 = logFish;
            apply = logFish < thresh(th);
            logFish2(apply) = 0;
            s_dil = imdilate(logFish2,msk);
            m{dee} = logFish2 > s_dil; %# M is 1 wherever a voxel's value is greater than its neighbors
            bord = ones(size(m{dee}));
            bord(1:5,:,:) = 0;
            bord(end-5:end,:,:) = 0;
            bord(:,end-5:end,:) = 0;
            bord(:,1:5,:) = 0;
            m{dee} = m{dee}.*logical(bord);
            dtf = sum(sum(sum(m{dee})));
            if dtf<lowerlim
                thresh(th) = thresh(th) - 21;
            elseif dtf > upperlim
                thresh(th) = thresh(th) + 29;
            end    
        end
    end   

    
    if debug == 1
        figure 
        imshow(max(images{dee},[],3),[min(min(max(images{dee},[],3))) mean(mean(max(images{dee},[],3)))+5000]);
        hold on;
        [v2,v1]=find(max(m{dee},[],3)==1);
        scatter(v1(:),v2(:),75);
        hold off;
        %txt_h = labelpoints(v1+.05, v2+.05, ind2sub(size(v1),v1), 'NE',.01 ,'Color','y');
    end
    
    [y,x,z] = ind2sub(size(m{dee}),find(m{dee} == 1));
    
    dots(dee).channels = [x y z];
    im = max(images{dee},[],3);
    for i = 1:length(y)
        dots(dee).intensity(i,1) = im(y(i),x(i));
    end
end