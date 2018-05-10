function [three, four, one, total, incellbar3, incellbar4,congratulations, playedyourself, anotherone] = otherstuff(PathName, field, allcodes, barcodekey)

load([PathName '\pos' num2str(field) '\pos' num2str(field) 'Barcodesrad6ScaledOn.mat'])
load([PathName '\pos' num2str(field) '\pos' num2str(field) 'PointsBarcodesrad6ScaledOn.mat'])
        fullpath = [PathName '/pos' num2str(field) '/RoiSet'];
        vertex = selfseg(fullpath);
        incellbar3 = zeros(1,length(vertex));
        incellbar4 = zeros(1,length(vertex));
                congratulations = zeros(size(barcodekey.barcode,1),1);
                        playedyourself = zeros(size(allcodes,1),1);
for i = 1:length(foundbarcodes)
    for j = 1:length(foundbarcodes(i).found)
        call = foundbarcodes(i).found(j).consensus > 0;
        meas = foundbarcodes(i).found(j).idx(call,:);
        abba = cellfun(@any,meas);
        c = histcounts(sum(abba,2),[0:length(foundbarcodes)]+.1);
        four(j,i) = c(end);
        three(j,i) = c(end-1);
        one(j,i) = c(1);
        total(j,i) = length(abba);
        ab = sum(cellfun(@any,foundbarcodes(i).found(j).idx),2);
        baba = ab == length(foundbarcodes)-1;
        blacksheep = ab == length(foundbarcodes);
        threepts = points(i).dots(j).channels(baba,:);
        fourpts = points(i).dots(j).channels(blacksheep,:);
        var = [];
        for k = 1:length(vertex)
            include3 = inpolygon(threepts(:,1),threepts(:,2),vertex(k).x,vertex(k).y);
            incellbar3(k) = incellbar3(k)+ sum(include3);
            include4 = inpolygon(fourpts(:,1),fourpts(:,2),vertex(k).x,vertex(k).y);
            incellbar4(k) = incellbar4(k)+ sum(include4);
            incells = inpolygon(points(i).dots(j).channels(:,1),points(i).dots(j).channels(:,2),vertex(k).x,vertex(k).y);
            var = [var incells];
        end
         var = sum(var,2) >0;
         foundbarcodes(i).found(j).channel(~var,:) = [];
        %match on target

%         for l = 1:size(barcodekey.barcode,1)
%             youjust(l,1) = sum(ismember(cell2mat(foundbarcodes(i).found(j).channel),barcodekey.barcode(l,:),'rows'));
%         end
        [~, bt] = ismember(cell2mat(foundbarcodes(i).found(j).channel),barcodekey.barcode,'rows');
        c = histcounts(bt,[0:length(barcodekey.barcode)]+.1);
        youjust = c;
        congratulations = congratulations + youjust';
        
        %match on off-target
        buch = cellfun(@(x) length(x)> 1,rawfound(i).found(j).channel);
        rawfound(i).found(j).channel(buch) = {0};
        
%         for m = 1:size(allcodes,1)
%             anotherone(m,1) = sum(ismember(cell2mat(rawfound(i).found(j).channel),allcodes(m,:),'rows'));
%         end
        [~, bt] = ismember(cell2mat(rawfound(i).found(j).channel),allcodes,'rows');
        c = histcounts(bt,[0:length(allcodes)]+.1);
        anotherone = c;
        playedyourself = playedyourself+anotherone';
        
    end
end