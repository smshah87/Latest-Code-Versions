function correctRegistration(PathName,posnum,B)

S = load([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'Images.mat']);

hybnum = S.hybnum;

for i = 1:length(hybnum)
    for j = 1:length(hybnum(i).color)
        hybnum(i).color{j} = imwarp(hybnum(i).color{j},B{i},'OutputView',imref3d(size(hybnum(i).color{j})));
    end
end

save([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'SequentialRegistered.mat'], 'hybnum', 'B','-v7.3')