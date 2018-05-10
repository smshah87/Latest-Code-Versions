PathName = uigetdir;


folders = dir([PathName '/pos*']);

for i = 1:length(folders)
    num(i) = str2double(folders(i).name(4:end));
end

keep = num <100000;

folders = folders(keep);

counts = [];
centroids = [];
area = [];
field = [];
for i = 1:length(folders)
    if exist([PathName '\' folders(i).name '\ZHigh.zip'])
        load([PathName '\' folders(i).name '\' folders(i).name 'AllCells2.mat'])
        counts = [counts DataH.copy DataL.copy];
        centroids = [centroids;DataH.centroid;DataL.centroid];
        area = [area DataH.area DataL.area];
        field = [field DataH.field DataL.field];
    end
end