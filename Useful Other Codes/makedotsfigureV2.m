function dots = makedotsfigureV2(PathName, foundbarcodes,rawfound,points,hybrid,channels,z)

cf = pwd;
Miji;
cd(cf);
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
MIJ.run('Open...', path_to_fish);

MIJ.run('Split Channels')

im = MIJ.getImage(['C5-' FileName]);

MIJ.run('Close All');
counter = 0;
for i = 1:channels
    keep = foundbarcodes(1).found(i).compiled(:,1)>0;
    comp = foundbarcodes(1).found(i).compiled(keep,1);
    ptsi = points(1).dots(i).channels(keep,:);
    india = foundbarcodes(1).found(i).idx(keep,:);
    pos = cellfun(@find,india,'UniformOutput',0);
    for k = 1:size(india,1)
        for l = 1:hybrid
            if ~isempty(pos{k,l})
                ptsz(l) = points(l).dots(pos{k,l}).channels(india{k,l}(pos{k,l}),3);
            else
                ptsz(l) = z(1);
            end
        end
        for j = 1:hybrid
            if sum(ptsz<z(1)) == 0 && sum(ptsz>z(2))==0
                if ~isempty(pos{k,j})
                    dots(j).tp(pos{k,j}).channels(counter+k,:) = points(j).dots(pos{k,j}).channels(india{k,j}(pos{k,j}),:);
                    dots(j).tp(pos{k,j}).code(counter+k,1) = comp(k);
                else
                    dots(j).dropped.channels(counter+k,:) = ptsi(k,:);
                    dots(j).dropped.code(counter+k,:) = comp(k);
                end
            end
        end
    end
    counter = counter+k;
end
vertex = selfseg([PathName '\RoiSet']);

for j = 1:hybrid
    for i = 1:channels
        keep = foundbarcodes(j).found(i).consensus == 0;
        fp = zeros(1,hybrid);
        fp(j) = i;
        keep2 = cellfun(@(x,y) ismember(x,y),rawfound(j).found(i).channel,num2cell(repmat(fp,size(rawfound(j).found(i).channel,1),1)),'UniformOutput',0);
        keep2 = cellfun(@sum,keep2);
        keep2 = sum(keep2,2);
        keep2 = keep2 >hybrid-1;
        keepf = keep2 & keep;
        dots(j).fp(i).channels = points(j).dots(i).channels(keepf,:);
    end
end

for i = 1:hybrid
    if ~isempty(dots(i).dropped)
        drop = dots(i).dropped.code == 0;
        dots(i).dropped.channels(drop,:) = [];
        dots(i).dropped.code(drop) = [];
    end
    for j = 1:channels
        drop = dots(i).tp(j).code ==0;
        dots(i).tp(j).code(drop,:) = [];
        dots(i).tp(j).channels(drop,:) = [];
    end
end

if ~isempty(z)
    for j = 1:hybrid
        for i = 1:channels
            dots(j).fp(i).channels(dots(j).fp(i).channels(:,3)<z(1) | dots(j).fp(i).channels(:,3)>z(2),:) = [];
        end
    end
end

for j = 1:hybrid
    for i = 1:channels
        lin = sub2ind([1024 1024], dots(j).tp(i).channels(:,2),dots(j).tp(i).channels(:,1));
        lin2 = sub2ind([1024 1024], dots(j).fp(i).channels(:,2),dots(j).fp(i).channels(:,1));
        m = zeros(1024);
        m(lin) = 1;
        m(lin2) = 1;
        MIJ.createImage(num2str(i),uint16(m*2^16-1),true);
        MIJ.run('Gaussian Blur...','sigma=1.25');
    end
    MIJ.createImage('DAPI',max(im,[],3),true);
    MIJ.run('Merge Channels...','c1=2 c2=3 c3=DAPI c4=1 c7=4 create');
    mkdir(PathName,'Ploted')
    MIJ.run('Save', ['save=[' PathName '\Ploted\' num2str(j) '.tif' ']']);
    MIJ.run('Close All')
end
MIJ.exit