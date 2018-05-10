function saveDAPI(PathName,posnum, image, channel, name)

fld = pwd;
Miji;
cd(fld);

path_to_fish = ['path=[' PathName '\Pos' num2str(posnum) '\' image ']'];
MIJ.run('Open...', path_to_fish);
MIJ.run('Split Channels');
DAPI = uint16(MIJ.getImage(['C' num2str(channel) '-' image]));
saveastiff(DAPI,[PathName '\Pos' num2str(posnum) '\' name]);

MIJ.run('Close All');
MIJ.exit
    