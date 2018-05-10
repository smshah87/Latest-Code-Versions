function [vertices,hyb] = plotrectangles(PathName,dots,hybrid,channels, vertices)

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
    
    w = repmat(2.5, size(hyb(j).allpoints.tp,1),1);
    p = [hyb(j).allpoints.tp(:,1)-1.25,hyb(j).allpoints.tp(:,2)-1.25,w,w];
    for i = 1:size(hyb(j).allpoints.tp,1)
        rectangle('Position', p(i,:),'EdgeColor','w','LineStyle','--','LineWidth',5)
        text(hyb(j).allpoints.tp(i,1)-.6,hyb(j).allpoints.tp(i,2),num2str(hyb(j).allcodes.tp(i)),'Color','w','FontSize',18)
    end
    
    if ~isempty(hyb(j).allpoints.dropped)
        w = repmat(2.5, size(hyb(j).allpoints.dropped,1),1);
        p = [hyb(j).allpoints.dropped(:,1)-1.25,hyb(j).allpoints.dropped(:,2)-1.25,w,w];
        for i = 1:size(hyb(j).allpoints.dropped,1)
            rectangle('Position', p(i,:),'EdgeColor','y','LineStyle','--','LineWidth',5)
            text(hyb(j).allpoints.dropped(i,1)-.6,hyb(j).allpoints.dropped(i,2),num2str(hyb(j).allcodes.dropped(i)),'Color','w','FontSize',18)
        end
    end
    
    w = repmat(2.5, size(hyb(j).allpoints.fp,1),1);
    p = [hyb(j).allpoints.fp(:,1)-1.25,hyb(j).allpoints.fp(:,2)-1.25,w,w];
    for i = 1:size(hyb(j).allpoints.fp,1)
        rectangle('Position', p(i,:),'EdgeColor','r','LineStyle','--','LineWidth',5)
    end
end

LinkFigures(1:hybrid)

xlim([min(xi) max(xi)])
ylim([min(yi) max(yi)])

        figure;
        image2 = I;
        yrange = min(yi):max(yi);
        xrange = min(xi):max(xi);
        left = uint32(sub2ind([2048 2048], yrange,repmat(min(xi),1,length(yrange))));
        right = uint32(sub2ind([2048 2048], yrange,repmat(max(xi),1,length(yrange))));
        top = uint32(sub2ind([2048 2048],repmat(min(yi),1,length(xrange)),xrange));
        bottom = uint32(sub2ind([2048 2048],repmat(max(yi),1,length(xrange)),xrange));
        red = image2(:,:,1);
        red([left,right,top,bottom]) = 255;
        green = image2(:,:,2);
        green([left,right,top,bottom]) = 255;
        blue = image2(:,:,3);
        blue([left,right,top,bottom]) = 0;
        imagebox(:,:,1) = red;
        imagebox(:,:,2) = green;
        imagebox(:,:,3) = blue;
        imshow(imagebox);
        set(gca,'position',[0 0 1 1], 'units','normalized')