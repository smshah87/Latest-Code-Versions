function [imagebox,vertices,hyb] = plotrectanglesLinus(PathName,dots,hybrid,channels, vertices, barcodekey)

%vertex = selfseg(PathName);
I = imread([PathName '\' num2str(1) '.png']);
if isempty(vertices)
    [~, xi, yi] = roipoly(I);
    vertices = [xi,yi];
else
    xi = vertices(:,1);
    yi = vertices(:,2);
end

close all;
for j = 1:hybrid
    hyb(j).im = imread([PathName '\' num2str(j) '.png']);
    allcodestp = [];
    allpointstp = [];
    allpointsfp = [];
    for k = 1:channels
        tpptsincell = inpolygon(dots(j).tp(k).channels(:,1),dots(j).tp(k).channels(:,2),xi,yi);
        fpptsincell = inpolygon(dots(j).fp(k).channels(:,1),dots(j).fp(k).channels(:,2),xi,yi);
        allcodestp = [allcodestp; dots(j).tp(k).code(tpptsincell)];
        allpointstp = [allpointstp; dots(j).tp(k).channels(tpptsincell,:)];
        allpointsfp = [allpointsfp; dots(j).fp(k).channels(fpptsincell,:)];
    end
    if ~isempty(dots(j).dropped)
        droppedincell = inpolygon(dots(j).dropped.channels(:,1),dots(j).dropped.channels(:,2),xi,yi);
        hyb(j).allpoints.dropped = dots(j).dropped.channels(droppedincell,:);
        hyb(j).allcodes.dropped = dots(j).dropped.code(droppedincell);
    else
        hyb(j).allpoints.dropped = [];
        hyb(j).allcodes.dropped = [];
    end
    hyb(j).allcodes.tp = allcodestp;
    hyb(j).allpoints.tp = allpointstp;
    hyb(j).allpoints.fp = allpointsfp;

    figure;
    imshow(hyb(j).im)
    hold on;
    s = 4;
    wid = 2;
    w = repmat(s, size(hyb(j).allpoints.tp,1),1);
    p = [hyb(j).allpoints.tp(:,1)-s/2,hyb(j).allpoints.tp(:,2)-s/2,w,w];
    for i = 1:size(hyb(j).allpoints.tp,1)
        as = rectangle('Position', p(i,:),'EdgeColor','w','LineStyle','--','LineWidth',wid);
        alpha(as,.5)
        text(hyb(j).allpoints.tp(i,1),hyb(j).allpoints.tp(i,2),barcodekey.names(hyb(j).allcodes.tp(i)),'Color','w','FontSize',18,'HorizontalAlignment','center','FontWeight','Bold')
    end
    
    if ~isempty(hyb(j).allpoints.dropped)
        w = repmat(s, size(hyb(j).allpoints.dropped,1),1);
        p = [hyb(j).allpoints.dropped(:,1)-s/2,hyb(j).allpoints.dropped(:,2)-s/2,w,w];
        for i = 1:size(hyb(j).allpoints.dropped,1)
            as = rectangle('Position', p(i,:),'EdgeColor','y','LineStyle','--','LineWidth',wid);
            alpha(as,.5)
            text(hyb(j).allpoints.dropped(i,1),hyb(j).allpoints.dropped(i,2),barcodekey.names(hyb(j).allcodes.dropped(i)),'Color','w','FontSize',18,'HorizontalAlignment','center','FontWeight','Bold')
        end
    end
    
    w = repmat(s, size(hyb(j).allpoints.fp,1),1);
    p = [hyb(j).allpoints.fp(:,1)-s/2,hyb(j).allpoints.fp(:,2)-s/2,w,w];
    for i = 1:size(hyb(j).allpoints.fp,1)
        rectangle('Position', p(i,:),'EdgeColor','r','LineStyle','--','LineWidth',wid)
    end
end

LinkFigures(1:hybrid)

xlim([min(xi) max(xi)])
ylim([min(yi) max(yi)])

        figure;
        image2 = I;
        yrange = [floor(min(yi)) ceil(max(yi))];
        xrange = [floor(min(xi)) ceil(max(xi))];
        bw = bwperim(poly2mask([xrange(1) xrange(1) xrange(2) xrange(2)],[yrange(1) yrange(2) yrange(2) yrange(1)],2048,2048));
        red = image2(:,:,1);
        red(bw) = 255;
        green = image2(:,:,2);
        green(bw) = 255;
        blue = image2(:,:,3);
        blue(bw) = 0;
        imagebox(:,:,1) = red;
        imagebox(:,:,2) = green;
        imagebox(:,:,3) = blue;
        imshow(imagebox);
        set(gca,'position',[0 0 1 1], 'units','normalized')