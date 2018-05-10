function CompileImages(PathName,posnum, hybnums, channelsall,registration, corrections, tforms)

fld = pwd;
Miji;
cd(fld);

corrections = corrections(1).corrections;

for num = 1:length(hybnums)
    channels = channelsall{num};
    PathName2 = [PathName '\Pos' num2str(posnum) '\' num2str(hybnums(num)) '.tif'];
    path_to_fish = ['path=[' PathName2 ']'];
    MIJ.run('Open...', path_to_fish);
    MIJ.run('Split Channels');
    for dum = 1:length(channels)
        name = ['C' num2str(channels(dum)) '-' num2str(hybnums(num)) '.tif'];
        color{channels(dum)} = uint16(MIJ.getImage(name));
        B = repmat(corrections{channels(dum)},1,1,size(color{channels(dum)},3));
        color{channels(dum)} = double(color{channels(dum)})./B;
        color{channels(dum)} = uint16(color{channels(dum)});
    end
    
    if registration(num) ~= 0
        regis{num} = uint16(MIJ.getImage(['C' num2str(registration(num)) '-' num2str(hybnums(num)) '.tif']));
    else
        regis{num} = [];
    end
    
    MIJ.run('Close All');
    
    for d = 1:length(channels)
        namesh{channels(d)} = ['C' num2str(channels(d)) '-' num2str(num) '.tif'];
        MIJ.createImage(namesh{channels(d)}, color{channels(d)}, true);
    end
    
    if length(channels) > 1
        hordor = [];
        for i = 1:length(channels)
            if length(channels) <4 && i == length(channels)
                chnum = 4;
            else
                chnum = i;
            end
            temp = ['c' num2str(chnum) '=' namesh{channels(i)}];
            hordor = [hordor ' ' temp];
        end

        MIJ.run('Merge Channels...', hordor);   
    end

    MIJ.run('Subtract Background...', 'rolling=3 stack');

    if length(channels) > 1 
        MIJ.run('Split Channels');
    end
    
    for dum = 1:length(channels)
        name = ['C' num2str(dum) '-' num2str(num) '.tif'];
        color{channels(dum)} = uint16(MIJ.getImage(name));
    end

    MIJ.run('Close All');
    
    %z = size(color{2},3);
    
    for j = 1:length(channels)
        %for k = 1:z
            %color{j}(:,:,k) = imwarp(color{j}(:,:,k),tforms{j},'OutputView',imref2d(size(color{2}(:,:,1))));
            color{j} = imwarp(color{j},tforms{j},'OutputView',imref3d(size(color{2})));
        %end
    end
    
    hybnum(num).color = color;
    clear color;
end

MIJ.exit;

save([PathName '\Pos' num2str(posnum) '\Pos' num2str(posnum) 'Images.mat'], 'hybnum', 'regis','-v7.3')

