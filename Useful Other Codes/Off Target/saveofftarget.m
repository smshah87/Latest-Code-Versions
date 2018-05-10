function saveofftarget( PathName, field, calledpercell, copynumofftarget,copynumofftargetsum, numdropped, percell, percellsum)

save([PathName '\' 'pos' num2str(field) '\' 'pos' num2str(field) 'Offtarget02132017.mat'],'copynumofftarget','copynumofftargetsum', 'numdropped', 'percell', 'percellsum','calledpercell' );
