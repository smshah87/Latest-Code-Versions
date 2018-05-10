function unzipallNuclei()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
PathName = uigetdir;
listing = dir([PathName '/pos*']);

for i = 1:length(listing)
    num(i) = str2double(listing(i).name(4:end));
end

keep = num < 32;

num = num(keep);

for i = 1:length(num)
    listing2 = dir([PathName '\pos' num2str(num(i)) '\RoiSetNuc.zip']);
    if ~isempty(listing2)
        unzip([PathName '\pos' num2str(num(i)) '\' listing2.name],[PathName '\pos' num2str(num(i)) '\RoiSetNuclei'])
        %unzip([PathName '\pos' num2str(num(i)) '\' listing2.name],['F:\05262016 - 250 genes brain\Organize Manual Z\pos' num2str(num(i)) '\RoiSet'])
    end    
end

