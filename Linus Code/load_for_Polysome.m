function dotlocations =  load_for_Polysome(PathName, i)

S = load([PathName '\' 'pos' num2str(i) '\' 'pos' num2str(i) 'Barcodes01312017.mat'],'dotlocations');
dotlocations = S.dotlocations;