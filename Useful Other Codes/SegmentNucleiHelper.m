

PathName = uigetdir;
str = inputdlg('How Many Hybridizations?','s');
str2 = inputdlg('Which Listing to Start From?','s');
listing = dir([PathName '\Pos*']);

for i = num2str(str2{1}):length(listing)-1
    Miji;
    path_to_fish = ['path=[' PathName '\Pos' num2str(i) '\' num2str(str{1}) '.tif' ']'];
    MIJ.run('Open...', path_to_fish);
    %MIJ.run('Z Project...', 'projection=[Max Intensity]');
    MIJ.run('Duplicate...', 'duplicate channels=5');
    MIJ.run('Save', ['save=[' PathName '\Pos' num2str(i) '\LastHybDAPI.tif' ']']);
    MIJ.run('Close All');
    path_to_fish = ['path=[' PathName '\Pos' num2str(i) '\LastHybDAPI.tif' ']'];
    MIJ.run('Open...', path_to_fish);
    MIJ.run('Z Project...', 'projection=[Max Intensity]');
    MIJ.run('Enhance Contrast...', 'saturated=0.01 normalize equalize');
    MIJ.run('Gaussian Blur...', 'sigma=1');
    MIJ.run('Auto Threshold', 'method=MaxEntropy');
    %MIJ.run('Convert to Mask');
    %MIJ.run('Close')
    MIJ.run('Watershed')
    MIJ.run('Fill Holes');
    MIJ.run('Analyze Particles...', 'size=500-Infinity pixel exclude clear add');
    MIJ.run('Close All')
    MIJ.run('Open...', path_to_fish);
    pause('on');
    pause;
    MIJ.run('Close All')
    MIJ.exit;
end
