PathName = uigetdir;

listing = dir([PathName '/pos*']);

for i = 1:length(listing)
    num(i) = str2double(listing(i).name(4:end));
end

keep = num < 50 ;

num = num(keep);

parfor i = 1:length(num)
    [three, four, one, total, incellbar3, incellbar4,congratulations, playedyourself, anotherone] = otherstuff(PathName, num(i), allcodes, barcodekey);
    field(i).three= three;
    field(i).four=four;
    field(i).one=one;
    field(i).total= total;
    field(i).incellbar3 = incellbar3;
    field(i).incellbar4 = incellbar4;
    field(i).congratulations = congratulations;
    field(i).playedyourself = playedyourself;
    field(i).anotherone = anotherone;
end

