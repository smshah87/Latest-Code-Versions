function AndersonAssignCells(PathName,posnum,hybs)

load([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'AllCounts2.mat']);
imsize = [1024 1024];
if exist([PathName '\Pos' num2str(posnum) '\ZHigh.zip'], 'file')
    unzip([PathName '\Pos' num2str(posnum) '\ZHigh.zip'],[PathName '\Pos' num2str(posnum) '\ZHigh'])
    unzip([PathName '\Pos' num2str(posnum) '\ZLow.zip'],[PathName '\Pos' num2str(posnum) '\ZLow'])


    %z high 17-21
    vertexH = selfseg([PathName '\Pos' num2str(posnum) '\ZHigh']);
    vertexL = selfseg([PathName '\Pos' num2str(posnum) '\ZLow']);
    copyHA= [];    
    for i = 1:length(vertexH)
        copyH = [];
        for j = 1:hybs
            copy = [];
            for k = 1:length(Data(j).dots)
                a = Data(j).dots(k).channels(:,3) > 16 &  Data(j).dots(k).channels(:,3) < 22;
                include = inpolygon(Data(j).dots(k).channels(:,1),Data(j).dots(k).channels(:,2),vertexH(i).x,vertexH(i).y);
                copy(k,1) = sum(include & a);
            end
            copyH = [copyH;copy];
        end
        copyHA = [copyHA copyH];
        BW = poly2mask(vertexH(i).x, vertexH(i).y, imsize(1), imsize(2));
        n = regionprops(BW,'Area','Centroid');
        areaH(i) = sum([n.Area]);
        centroidH(i,:) = [n.Centroid 19];
        fieldH(i) = posnum;
    end
    DataH.area = areaH;
    DataH.centroid = centroidH;
    DataH.field = fieldH;
    DataH.copy = copyHA;

    %z low 6-10
    copyLA = [];    
    for i = 1:length(vertexL)
        copyL = [];
        for j = 1:hybs
            copy = [];
            for k = 1:length(Data(j).dots)
                a = Data(j).dots(k).channels(:,3) > 5 &  Data(j).dots(k).channels(:,3) < 11;
                include = inpolygon(Data(j).dots(k).channels(:,1),Data(j).dots(k).channels(:,2),vertexL(i).x,vertexL(i).y);
                copy(k,1) = sum(include & a);
            end
            copyL = [copyL;copy];
        end
        copyLA = [copyLA copyL];
        BW = poly2mask(vertexL(i).x, vertexL(i).y, imsize(1), imsize(2));
        n = regionprops(BW,'Area','Centroid');
        areaL(i) = sum([n.Area]);
        centroidL(i,:) = [n.Centroid 8];
        fieldL(i) = posnum;
    end
    DataL.area = areaL;
    DataL.centroid = centroidL;
    DataL.field = fieldL;
    DataL.copy = copyLA;

    save([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'AllCells2.mat'],'DataL','DataH')
end 



