function plotfound(PosList,genename,cell,barcodekey,hyb, channels,hybnum)
cell = cell+1;
genepos = strcmpi(PosList(:,1),genename);
genebar = strcmpi(barcodekey.names,genename);
ch = cell2mat(PosList(genepos,cell));
barc = barcodekey.barcode(genebar,:);

for i = 1:hyb
    hm(i) = figure;
    for j = 1:channels
        hybplot(i).h(j) = subplot(2,2,j);
        title(['Channel' num2str(j)])
        if ch(:,3)-1 < 1
            z1 = 1;
            z2 = ch(:,3)+1;
        elseif ch(:,3)+1 > size(hybnum(i).color{j},3)
            z1 = ch(:,3)-1;
            z2 = size(hybnum(i).color{j},3);
        else
            z1 = ch(:,3)-1;
            z2 = ch(:,3)+1;
        end
        imshow(imadjust(max(hybnum(i).color{j}(:,:,round(z1):round(z2)),[],3)))
    end
    linkaxes(hybplot(i).h,'xy')
end
LinkFigures(1:hyb,'xy')        

for i = 1:hyb
    for j = 1:channels
        if j == barc(i)
            figure(hm(i))
            subplot(hybplot(i).h(j))
            hold on;
            scatter(ch(:,1),ch(:,2),'go')
        else
            figure(hm(i))
            subplot(hybplot(i).h(j))
            hold on;
            scatter(ch(:,1),ch(:,2),'ro')
        end
    end
end


