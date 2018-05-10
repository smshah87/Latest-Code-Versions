function [seeds] = numseeds(PosList,dotlocations)

%load([PathName '\Pos' num2str(Posnum) '\pos' num2str(Posnum) 'Barcodes11092016.mat']);


seeds = PosList;
for i = 1:size(dotlocations,2)
    for j = 1:size(dotlocations(i).cell,1)
        ind = find(strcmpi(dotlocations(i).cell{j,1},PosList));
        if size(PosList{ind,i+1},1) == 1
            seeds{ind,i+1} = size(dotlocations(i).cell{j,4},1);
        else
            [idx, C] = kmeans(dotlocations(i).cell{j,2},size(PosList{ind,i+1},1));
            holder = [];
            for k = 1:size(PosList{ind,i+1},1)
                ella = find(ismember(cell2mat(dotlocations(i).cell(j,5)),C(k,:),'rows'));
                holder(1,ella) = sum(idx==k);
            end
            seeds{ind,i+1} = holder;
        end
    end
end
%save([PathName '\Pos' num2str(Posnum) '\pos' num2str(Posnum) 'Barcodes11092016.mat'],'seeds','-append');