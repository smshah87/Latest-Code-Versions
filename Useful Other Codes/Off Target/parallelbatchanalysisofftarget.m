PathName = uigetdir;

listing = dir([PathName '/pos*']);

for i = 1:length(listing)
    num(i) = str2double(listing(i).name(4:end));
end

keep = num <36 ;

num = num(keep);

parfor i = 1:length(num)
    
    fprintf('Analyzing Field %d\r', num(i))
    [rawfound, points, calledpercell] = loadofftarget(PathName, num(i));
    % offtarget(rawfound, allcodes, hyb,channum,segmentation,PathName,posnum,points)
    [copynumofftarget,copynumofftargetsum, numdropped, percell, percellsum] = offtarget(rawfound, allcodes, 5,12,'roi',PathName,num(i),points,4,1,[0 0])
    fprintf('Saving Field %d\r', num(i))
    saveofftarget( PathName, num(i), calledpercell, copynumofftarget,copynumofftargetsum, numdropped, percell, percellsum)

end    