close all;
clc;
%clearvars -except Colors2 Colors4;
%iptsetpref('ImshowBorder','tight');
clusterlevel = 1;
%load('mappingdata.mat')
r = cellclass250brain;
%clear Colors
if clusterlevel == 2
    IDX = r(:,2);
    bahn = IDX == 92;
    IDX(~bahn)=0;
    un = unique(IDX);
    k=max(IDX);
    Colors=hsv(k);
    Colors=Colors(randi(k,1,length(un)),:);
else
    IDX = r(:,1);
    k=max(IDX);
%     Colors=hsv(k);
%     Colors = Colors(1:end,:);
    un = unique(IDX);
%     for i = 1:5
%          Colors=Colors(randperm(k),:);
%          %Colors = Colors2;
%     end
    Colors = Colors;
end
visualize = 3;
PathName = uigetdir;
folders = dir(PathName);
for i = 1:length(folders)
    num(i) = str2double(folders(i).name(4:end));
end

%keep = num < 27;
keep = num > 32 & num < 55;
lookup = [12 11 13 15 18 9 14 16 5 6 7 8 10 17 1 2 3 4];
num = num(keep);
for posnum = 1:length(num)
    figure;
%     set(gca,'color',[0 0 0])
%     set(gca,'XTick',[]);
%     set(gca,'YTick',[]);
%     axis off
    
    load([PathName '/pos' num2str(num(posnum)) '/pos' num2str(num(posnum)) 'HippoBarcoded06312016.mat'])
    %load([PathName '/pos' num2str(num(posnum)) '/pos' num2str(num(posnum)) 'HippoSurMapping3.mat'])
    im = loadtiff(['I:\05262016 - 250 genes brain\Organized - Hyb 2\pos' num2str(num(posnum)) '\Composite.tif']);
    %im = imread([PathName '/pos' num2str(num(posnum)) '/DAPI.png']);
    iptsetpref('ImshowBorder','tight')
    imshow(im(:,:,2),[350 2800])
    axis square
    hold on
    ind = f(:,1)==num(posnum) & f(:,2) ==1;
    ind2 = f(:,1)==num(posnum) & f(:,2) ==2;
    IDXfield = IDX(ind);
    IDXfield2 = IDX(ind2);
    if visualize == 3;
        if ~isempty(IDXfield);
            for i = 1:max(un);
                inclus = IDXfield==i;
                newind = find(lookup==i);
                inclusface = face(inclus);%(1:length(face))
                inclusptsincell = ptsincell(inclus);
                for j = 1:size(inclusface,2)
                    %inclusptsincell(j).cell = [inclusptsincell(j).cell(:,2),inclusptsincell(j).cell(:,1),inclusptsincell(j).cell(:,3)];
                    patch('Faces',inclusface(j).cell,'Vertices',inclusptsincell(j).cell,'FaceColor',Colors(i,:),'EdgeColor',Colors(i,:),'EdgeAlpha',.3,'FaceAlpha',.2)%,'EdgeLighting', 'gouraud')
                    ctext = mean(inclusptsincell(j).cell,1);
                    text(ctext(1),ctext(2),35,num2str(i),'FontWeight','bold','Rotation',180,'FontSize',16,'Color',[.99 1 1],'Interpreter','none');
                end
                ax = gca;
                ax.YDir = 'reverse';
            end
        end
%         vertex = selfseg([PathName '\pos' num2str(num(posnum)) '\RoiSet']);
%         for i = 1:length(vertex)
%             BW = poly2mask(vertex(i).x,vertex(i).y,1024,1024);
%             if length(regionprops(BW,'Centroid')) > 1
%                 a = regionprops(BW,'Area');
%                 [~,dada] = max([a.Area]);
%                 temp = regionprops(BW,'Centroid');
%                 cent(i) = temp(dada);
%                 clear temp
%             else
%                 cent(i) = regionprops(BW,'Centroid');
%             end
%         end
%         for i = 1:length(cent)
%            xq(i) = cent(i).Centroid(1);
%            yq(i) = cent(i).Centroid(2);
%         end
%         clear cent;
%         vertex = selfseg([PathName '\pos' num2str(num(posnum))]);
%         for i = 1:length(vertex)
%             in(:,i) = inpolygon(xq,yq,vertex(i).x,vertex(i).y);
%         end
%         xq = [];
%         yq = [];
%         deez = sum(in,2) >0;
%         in = [];
%         IDXfield2(deez) = 0;
%         for i = 2:max(un);
%             inclus2 = IDXfield2 ==i;
%             newind = find(lookup == i);
%             %vertexkeep = vertex(inclus(1:length(vertex)));
%             inclusface2 = faceSur(inclus2);%(1:length(faceSur));
%             inclusptsincell2 = ptsincellSur(inclus2);
%             for j = 1:size(inclusface2,2)
%                 %inclusptsincell(j).cell = [inclusptsincell(j).cell(:,2),inclusptsincell(j).cell(:,1),inclusptsincell(j).cell(:,3)];
%                 patch('Faces',inclusface2(j).cell,'Vertices',inclusptsincell2(j).cell,'FaceColor',Colors(i,:),'EdgeColor',Colors(i,:),'EdgeAlpha',.3,'FaceAlpha',.2)%,'EdgeLighting', 'gouraud')
%                 ctext = mean(inclusptsincell2(j).cell);
%                 text(ctext(1),ctext(2),35,num2str(newind),'FontWeight','bold','Rotation',90,'FontSize',16,'Color',[.99 1 1],'Interpreter','none');
%             end
%         end
        hold off;
    else
        for i = 2:length(un);
            inclus = IDXfield==un(i);
            inclusface = face(inclus(1:length(face)));
            inclusptsincell = ptsincell(inclus(1:length(face)));
            for j = 1:size(inclusface,2)
%                 norep = boundary(inclusptsincell(j).cell(:,1),inclusptsincell(j).cell(:,2),0);
%                 %inclusptsincell(j).cell = [inclusptsincell(j).cell(:,2),inclusptsincell(j).cell(:,1),inclusptsincell(j).cell(:,3)];
%                 patch(inclusptsincell(j).cell(norep,1),inclusptsincell(j).cell(norep,2),Colors(i,:),'FaceAlpha',.2,'EdgeAlpha',.3)
%                 norep = [];
            end
        end
        hold off;
    end
    if num(posnum)> 21
        set(gcf,'PaperPositionMode','auto')
        savename = ['C:\Users\Sheel\Desktop\Fig7 w text\' num2str(num(posnum)) '.png'];
        print(savename,'-dpng','-r512');
        close all;
    else
        set(gcf,'PaperPositionMode','auto')
        savename = ['C:\Users\Analysis\Desktop\Fig5 2.7 v4\' num2str(num(posnum)) '.png'];
        print(savename,'-dpng','-r512');
    end
end
