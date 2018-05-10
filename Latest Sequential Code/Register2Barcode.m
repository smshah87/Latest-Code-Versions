function Register2Barcode(PathName, posnum, filename, num, channel)

fld = pwd;
Miji;
cd(fld)
load([PathName '\Pos' num2str(posnum) '\' filename])
path_to_fish = ['path=[' PathName '\Pos' num2str(posnum) '\' num2str(num) '.tif]'];
MIJ.run('Open...', path_to_fish);
MIJ.run('Split Channels');
name = ['C' num2str(channel) '-' num2str(num) '.tif'];
Image = uint16(MIJ.getImage(name));
Image = Image(:,:,zfocus:end);
MIJ.run('Close All')
saveastiff(Image,[PathName '\Pos' num2str(posnum) '\Registration.tif'])

MIJ.exit