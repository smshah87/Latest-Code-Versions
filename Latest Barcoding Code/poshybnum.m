
PathName = uigetdir;

    
    listing = dir([PathName '\Pos*']);
    
    for i = 1:length(listing)
        num(i) = str2double(listing(i).name(4:end));
    end

    keep = num <30;

    num = num(keep);
    corrall = [];
    zfocusall = [];
    
    for p = 1:length(num)
        posnum = num(p);
        disp('Processing Images....')
        [ hybnum] = Preprocess( channels, hyb, PathName, posnum,tforms,corrections);

        disp('Registering Images....')
        %Register Images
        [ hybnum, corr_offset, zfocus] = xCorrRegistration(PathName, posnum,hybnum,hyb,channels, 1, 1, debug); % no beads registration

        %[ hybnum, corr_offset ] = xCorrReg( PathName,hybnum,hyb,channels,posnum );  %405 beads registration

        save([PathName '\pos' num2str(posnum) '\hybnum' num2str(posnum) 'v1.mat'],'hybnum','corr_offset','zfocus','-v7.3')
        clear hybnum
        corrall = [corrall; corr_offset];
        zfocusall = [zfocusall, zfocus];
    end
    %save([PathName '\corrfocuspos11.mat'],'corrall','zfocusall')
    
 