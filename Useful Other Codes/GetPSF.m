function PSF = GetPSF(PathName,channels)
fld = pwd;
Miji;
cd(fld);

path_to_fish = ['path=[' PathName ']'];
MIJ.run('Open...', path_to_fish);
MIJ.run('Split Channels');
C = strsplit(PathName,'\');
FileName = C{end};

for i = 1:channels
    im{i} = uint16(MIJ.getImage(['C' num2str(i) '-' FileName]));
end

MIJ.run('Close All')

MIJ.exit

for i = 1:channels
    figure; imshow(im{i},[0 .3*max(max(im{i}))])
    answer = inputdlg('How Many ROIs Will You Choose');
    for j = 1:str2double(answer{1})
        BW(:,:,j) = roipoly;
        bb = regionprops(BW,'BoundingBox');
        a = im{i}(round(bb.BoundingBox(2)):round(bb.BoundingBox(2))+bb.BoundingBox(4), round(bb.BoundingBox(1)):round(bb.BoundingBox(1))+bb.BoundingBox(3));
        [fitresult, gof] = Gauss2DRotFit(im);
    end
end
    
    
    