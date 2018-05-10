function gename = showchromosome(PosList,dotlocations,genelist,chromosome,cell,consensus, vertex,regvec)
cell = cell+1;
s = cell2mat(genelist(:,2)) == chromosome;

ch = PosList(s,:);


%points = cell2mat(ch(:,cell));
tex = ~cellfun(@isempty,(ch(:,cell)));
gename = ch(tex,1);

if ~isempty(gename)
    for i = 1:length(gename); 
        a(i) = find(strcmpi(dotlocations(cell-1).cell(:,1),gename{i})); 
    end
    b = dotlocations(cell-1).cell(a,:);
    len = cellfun(@length,b(:,3));
    len2 = cellfun(@(x) size(x,1) ,b(:,5));
    drop = len./len2 < consensus | len2 > 2;
    b(drop,:) = [];
    points = ch(tex,cell);
    points(drop,:) = [];
    gename(drop) = [];
end
figure;
hold on;
if ~isempty(gename)
    for i = 1:size(gename)
        scatter3(points{i}(:,1),points{i}(:,2),points{i}(:,3),'.')
        text(points{i}(:,1),points{i}(:,2),points{i}(:,3),gename{i})
    end
end
plot(vertex(cell-1).x+regvec(1),vertex(cell-1).y+regvec(2))
