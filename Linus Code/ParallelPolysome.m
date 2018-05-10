PathName = uigetdir;

listing = dir([PathName '/Pos*']);

for i = 1:length(listing)
    num(i) = str2double(listing(i).name(4:end));
end

keep = num <20;

num = num(keep);

for i = 1:length(num)
    
    dotlocations =  load_for_Polysome(PathName, num(i));
    
    dotlocationsPolysome = LinusPolysome(PathName, num(i), dotlocations, corrections);
    
    all{i} = dotlocationsPolysome;
    
    save_for_Polysome(PathName,num(i),dotlocationsPolysome);
    
end

for i = 1:length(barcodekey.names)
    gene = barcodekey.names{i};
    kato = [];
    for j = 1:length(all)
        for k = 1:length(all{j})
            Lia = ismember(all{j}(k).cell(:,1),gene);
            kato = [kato; all{j}(k).cell{Lia,6}];
        end
    end
    Polysome(i).Gene = gene;
    Polysome(i).Intensity = kato;
    Polysome(i).Mean = mean(Polysome(i).Intensity);
    Polysome(i).Stdev = std(double(Polysome(i).Intensity));
    Polysome(i).Median = median(Polysome(i).Intensity);
    Polysome(i).MAD = mad(double(Polysome(i).Intensity),1);
end

c = struct2cell(Polysome);
cp = permute(c,[3 1 2]);