function [ PathName ] = Organize( hyb )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
folder = uigetdir;

range = inputdlg('What Should I Call The New Folder');
mkdir(folder,range{1});

for i = 1:hyb
    listing(i).listing = dir([folder '/' num2str(i) '/*.tif']);
end

% DAPI = dir([folder '/DAPI' '/*.tif']);
% Nissel = dir([folder '/Nissl' '/*.tif']);
% Antibody = dir([folder '/antibodies' '/*.tif']);



for i = 0:length(listing(1).listing)-1
    [a, b] = regexp(listing(1).listing(i+1).name,'\d*');
    roi = ['Pos' listing(1).listing(i+1).name(a(end):b(end))];
    mkdir([folder '/' range{1}], roi);
%     file = strfind({DAPI.name}, roi);
%     pick = ~cellfun(@isempty,file);
%     if sum(pick) > 0 
%     filename = DAPI(pick).name;
%     source = [folder '/DAPI' '/' filename];
%     dest = [folder '/' range{1} '/' roi '/' 'DAPI.tif'];
%     copyfile(source, dest);
%     end
%     file = strfind({Nissel.name}, roi);
%     pick = ~cellfun(@isempty,file);
%     filename = Nissel(pick).name;
%     source = [folder '/Nissl' '/' filename];
%     dest = [folder '/' range{1} '/' roi '/' 'Nissl.tif'];
%     copyfile(source, dest);
%     file = strfind({Antibody.name}, roi);
%     pick = ~cellfun(@isempty,file);
%     filename = Antibody(pick).name;
%     source = [folder '/antibodies' '/' filename];
%     dest = [folder '/' range{1} '/' roi '/' 'Antibody.tif'];
%     copyfile(source, dest);
    for j = 1:hyb
        file = strfind({listing(j).listing.name}, roi);
        pick = ~cellfun(@isempty,file);
        filename = listing(j).listing(pick).name;
        source = [folder '/' num2str(j) '/' filename];
        dest = [folder '/' range{1} '/' roi '/' num2str(j) '.tif'];
        copyfile(source, dest);
    end
end


PathName = [folder '/' range{1}];

end

