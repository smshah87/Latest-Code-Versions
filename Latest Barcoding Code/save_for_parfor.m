function save_for_parfor(PathName,field,foundbarcodes,points,copynumfinal,copynumfinalsum,totdropped,rawfound,PosList,dotlocations,copynumfinalrevised, seeds)

save([PathName '\' 'pos' num2str(field) '\' 'pos' num2str(field) 'BarcodesAllCodes.mat'],'foundbarcodes', 'copynumfinal', 'copynumfinalsum', 'totdropped','rawfound','PosList','dotlocations','copynumfinalrevised','seeds','-v7.3');

save([PathName '\' 'pos' num2str(field) '\' 'pos' num2str(field) 'PointsBarcodeAllCodes.mat'],'points','-v7.3')
    clear foundbarcodes
    clear points
    clear copynumfinal
    clear rawfound
    clear hybnum
    clear copynumfinalsum
    clear totdropped
    clear dotlocations
    clear copynumfinalrevised
    clear PosList