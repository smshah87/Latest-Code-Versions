PathName = uigetdir;

listing = dir([PathName '/pos*']);

for i = 1:length(listing)
    num(i) = str2double(listing(i).name(4:end));
end

keep = num < 10 ;

num = num(keep);

offtarget = [];
ontarget = [];
dropped = [];
copynumofftargetall = [];

for i = 1:length(num)

    load([PathName '\' 'pos' num2str(num(i)) '\' 'pos' num2str(num(i)) 'Offtarget02132017.mat'])
    
    offtarget = [offtarget,percell];
    ontarget = [ontarget,calledpercell];
    dropped = [dropped, numdropped];
    copynumofftargetall = [copynumofftargetall copynumofftarget(:,2:end)];
    
end