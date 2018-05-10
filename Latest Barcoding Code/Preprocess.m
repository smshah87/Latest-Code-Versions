function [ hybnum] = Preprocess( channels, hyb, PathName, posnum,tforms,corrections)
%Preprocess Summary of this function goes here
%   Detailed explanation goes here

fld = pwd;
Miji;
cd(fld);

for i = 1:hyb
    corrections(i).corrections = corrections(1).corrections;
end


for loop = 1:hyb


    path_to_fish = ['path=[' PathName '\' 'pos' num2str(posnum) '\' num2str(loop) '.tif' ']'];

    MIJ.run('Open...', path_to_fish);

    MIJ.run('Split Channels');
    for c = 1:length(channels)
        name = ['C' num2str(channels(c)) '-' num2str(loop) '.tif'];
        img(loop).color{channels(c)} = uint16(MIJ.getImage(name));
    end
    MIJ.run('Close All');
    
    img(loop) = correctbackground(img(loop), corrections(loop),channels);
    
    for d = 1:length(channels)
        namesh{channels(d)} = ['C' num2str(channels(d)) '-'  num2str(loop) '.tif'];
        MIJ.createImage(namesh{channels(d)}, img(loop).color{channels(d)}, true);
    end
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
    
    MIJ.run('Subtract Background...', 'rolling=3 stack');
    MIJ.run('Split Channels');
    

    for dum = 1:length(channels)
        name = ['C' num2str(dum) '-' num2str(loop) '.tif'];
        im = uint16(MIJ.getImage(name));
        hybnum(loop).color{dum} = im;
    end
    
    
    
    MIJ.run('Close All');

    

    %z = size(hybnum(loop).color{2},3);
    for j = 1:length(channels)
        %for i = 1:z
            %hybnum(loop).color{j}(:,:,i) = imwarp(hybnum(loop).color{j}(:,:,i),tforms{j},'OutputView',imref2d(size(hybnum(loop).color{2}(:,:,1))));
            hybnum(loop).color{j} = imwarp(hybnum(loop).color{j},tforms{j},'OutputView',imref2d(size(hybnum(loop).color{2}(:,:,1))));
        %end
    end

end
MIJ.exit


