function Register2Sequential(PathName, posnum, num, channel)

fld = pwd;
Miji;
cd(fld)
path_to_fish = ['path=[' PathName '\Pos' num2str(posnum) '\' num2str(num) '.tif]'];
MIJ.run('Open...', path_to_fish);
MIJ.run('Split Channels');
name = ['C' num2str(channel) '-' num2str(num) '.tif'];
Image = uint16(MIJ.getImage(name));
MIJ.run('Close All')
imagey(1).color{1} = Image;
zstart = AutoFocus(imagey, 1, 1,0);
Image = Image(:,:,zstart:end);
saveastiff(Image,[PathName '\Pos' num2str(posnum) '\Registration.tif'])

MIJ.exit