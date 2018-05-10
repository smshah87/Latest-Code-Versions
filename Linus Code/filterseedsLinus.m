function numtotal = filterseedsLinus(numseeds,seedlist)
b = cellfun(@(x) x >= numseeds,seedlist(:,2:end),'UniformOutput',0);
num = cellfun(@sum,b);
numtotal = sum(num,2);