function [copynumfinal,copynumfinalsum, numdropped, percell, percellsum, rawfound] = offtarget(rawfound, allcodes, hyb,channum,segmentation,PathName,posnum,points,conthresh,scaled,regvec)

for k = 1:hyb
    for j = 1:channum
        rawfound(k).found(j).dropped = zeros(length(rawfound(k).found(j).idx),1);
    end
end


%match uncalled codes to uncalled barcodes
for k = 1:hyb
    for j = 1:channum
        drop = [];
        bobo = [];
        bratat = [];
        br = [];
        len = [];
        multi = [];
        rows = [];
     
        lentemp = length(rawfound(k).found(j).channel);
        for i = 1:lentemp
            bobo = cell2mat(rawfound(k).found(j).channel(i,:)); 
            bratat{i,1} = bobo; 
        end
        br = cellfun(@(x) sum(x == 0),bratat,'UniformOutput',0);
        
        %remove uncallable dots
        called = zeros(lentemp,1);
        drop=cellfun(@(x) x>1,br);
        rawfound(k).found(j).channel(drop,:) ={0};
        rawfound(k).found(j).idx(drop,:) ={0};
        bratat(drop) = {[0 0 0 0]};
        %reduce multiple matches
        br2 = cellfun(@removezeros2,bratat,'UniformOutput',0);
        len = cellfun(@length,br2);
        multi = len+cell2mat(br)>hyb;
        [rows] = find(multi ==1);
        for l = 1:length(rows)
            possbarcodes = [];
            Dposs = [];
            A = [];
            posscell = [];
            code = [];
            gene = [];
            possreal = [];
            vernoi = [];
            vernoiz = [];
            ind = [];
            set = [];
            vari = [];
            variz = [];
            possbarcodes = combvec(rawfound(k).found(j).channel{rows(l),:})';
            Dposs = pdist2(possbarcodes,allcodes,'hamming');
            A = Dposs == min(min(Dposs));
            [code, ~] = find(A == 1);
            if length(code) == 1 && Dposs(A)*hyb < 2
                posscell = num2cell(possbarcodes);
                rawfound(k).found(j).channel(rows(l),:) = posscell(code,:);
                bratat{rows(l)} = cell2mat(posscell(code,:));
                %called(rows(l)) = gene;
            else
                possreal = possbarcodes(code,:);
                ind = rawfound(k).found(j).idx(rows(l),:);
                caca = zeros(1,channum);
                caca(1,j) = ind{k};
                ind{k} = caca;
                for p = 1:size(possreal,1)
                    for h = 1:hyb
                        if possreal(p,h) > 0
                            set(p).set(h,:) = points(h).dots(possreal(p,h)).channels(ind{h}(possreal(p,h)),:);
                        else 
                            set(p).set(h,:) = zeros(1,3);
                        end
                    end
                    vari(p) = sum(var(set(p).set));
                    variz(p) = var(set(p).set(:,3));
                end
                vernoi = vari == min(vari);
                vernoiz = variz == min(variz);
                if sum(vernoi) == 1
                    rawfound(k).found(j).channel(rows(l),:) = num2cell(possreal(vernoi',:));
                    bratat{rows(l)} = possreal(vernoi',:);
                elseif sum(vernoi) > 1 && sum(vernoiz) == 1
                    rawfound(k).found(j).channel(rows(l),:) = num2cell(possreal(vernoiz',:));
                    bratat{rows(l)} = possreal(vernoiz',:);
                else
                    if scaled== 1
                        for hybrid = 1:hyb
                            for numposs = 1:size(possreal,1)
                                if possreal(numposs,hybrid) == 0
                                    intensity(numposs,hybrid) = NaN;
                                else
                                    intensity(numposs,hybrid) = points(hybrid).dots(possreal(numposs,hybrid)).scaledIntensity(ind{hybrid}(possreal(numposs,hybrid)));
                                end
                            end
                        end
                        intdif = sum(abs(intensity-intensity(1,k)),2,'omitnan');
                        intensity = [];
                        if sum(intdif == min(intdif)) == 1
                            [~,I]=min(intdif);
                            rawfound(k).found(j).channel(rows(l),:) = num2cell(possreal(I,:));
                            bratat{rows(l)} = possreal(I,:);
                        else
                            rawfound(k).found(j).channel(rows(l),:) ={0}; % remove ambiguous dots
                            rawfound(k).found(j).idx(rows(l),:) ={0};
                            bratat(rows) = {[0 0 0 0]};
                        end
                    end
                end
            end
        end
        % Fill in dropped cells
        br2 = cellfun(@removezeros2,bratat,'UniformOutput',0);
        len = cellfun(@length,br2);
        missing = len == 3;
        [rows] = find(missing ==1);
        for l = 1:length(rows)
            possbarcodes = [];
            Dposs = [];
            A = [];
            posscell = [];
            code = [];
            gene = [];
            possbarcodes = combvec(rawfound(k).found(j).channel{rows(l),:})';
            Dposs = pdist2(possbarcodes,allcodes,'hamming');
            A = Dposs == min(min(Dposs));
            [code, gene] = find(A == 1);
            if length(gene) == 1 && Dposs(A)*hyb < 2
                %posscell = num2cell(possbarcodes);
                rawfound(k).found(j).channel(rows(l),:) = num2cell(allcodes(gene,:));
                bratat{rows(l)} = allcodes(gene,:);
                %called(rows(l)) = gene;
            else
                rawfound(k).found(j).channel(rows(l),:) ={0}; % remove ambiguous dots
                rawfound(k).found(j).idx(rows(l),:) ={0};
                bratat(rows(l)) = {[0 0 0 0]};
                %rawfound(k).found(j).dropped = zeros(length(rawfound(k).found(j).idx),1);
                rawfound(k).found(j).dropped(rows(l),:) = 1;
%                 for n = 1:hyb
%                     mu = zeros(1,channum);
%                     mu(1,posscell{code,n}) = 1; 
%                     cell2{1,n} = mu;
%                 end
%                 rawfound(k).found(j).idx(rows(l),:) = cellfun(@(x,y) x.*y,rawfound(k).found(j).idx(rows(l),:),cell2,'UniformOutput',0);
            end
        end 
        % call barcodes
        cell2 = [];
        minmat = [];
        tester = [];
        logicalstuff = [];
        posscell = {};
        [posscell{1:length(rawfound(k).found(j).channel),1:hyb}] = deal(0);
        %call dots
        D = pdist2(cell2mat(rawfound(k).found(j).channel),allcodes,'hamming');
        [r,c] = size(D);
        %minmat = cellfun(@(x) x == min(x,[],2) & x<=.25,mat2cell(D,ones(1,r),c),'UniformOutput',0);
        minmat = cellfun(@(x) x == 0,mat2cell(D,ones(1,r),c),'UniformOutput',0);
        [re, co] = cellfun(@(x) find(x),minmat,'UniformOutput',0);
        dasdf = cellfun(@isempty,re,'UniformOutput',0);
        re(logical(cell2mat(dasdf))) = {0};
        rows = find(cell2mat(re));
        posscell(rows,:) = num2cell(allcodes(cell2mat(co(rows)),:));
        co(logical(cell2mat(dasdf))) = {0};
        rawfound(k).found(j).called = cell2mat(co);
        %awe = called > 0;
        %rawfound(k).found(j).channel(awe,:) = {0};
        for m = 1:length(rawfound(k).found(j).channel)
            for n = 1:hyb
                mu = zeros(1,channum);
                if posscell{m,n} > 0
                    mu(1,posscell{m,n}) = 1;
                end
                cell2{m,n} = mu;
            end
        end
        rawfound(k).found(j).idx = cellfun(@(x,y) x.*y,rawfound(k).found(j).idx,cell2,'UniformOutput',0);   
    end
end

%consensus point calling
for i = 1:hyb
    for j = 1:channum
        rawfound(i).found(j).compiled = zeros(length(rawfound(i).found(j).called),hyb);
    end
end

for i = 1:hyb
    for j = 1:channum
        calledrows = find(rawfound(i).found(j).called>0);
        [r,c,v]=cellfun(@(x) find(x),rawfound(i).found(j).idx,'UniformOutput',0);
        for k = 1:length(calledrows)
            for l = 1:hyb
                if ~isempty(c{calledrows(k),l})
                    rawfound(l).found(c{calledrows(k),l}).compiled(v{calledrows(k),l},i) = rawfound(i).found(j).called(calledrows(k));
                end
            end
        end
    end
end

for i = 1:hyb
    for j = 1:channum
        % Drop Ambigous Matches
        cellver = mat2cell(rawfound(i).found(j).compiled,ones(length(rawfound(i).found(j).compiled),1),hyb);
        cellver = cellfun(@removezeros, cellver,'UniformOutput',0);
        [M,F,C] = cellfun(@mode,cellver,'UniformOutput',0);
        eq = cellfun(@(x) length(x{1}),C);
        M = cell2mat(M);
        M(eq>1)=0;
        M(cell2mat(F)<conthresh) = 0;
        rawfound(i).found(j).consensus = M;
    end
end

if strcmp(segmentation, 'roi')
    fullpath = [PathName '/pos' num2str(posnum) '/RoiSet'];
    vertex = selfseg(fullpath);
    copynumfinal(:,:) = num2cell([1:length(allcodes)]');
    copynumfinalsum(:,:) = num2cell([1:length(allcodes)]');
    for i = 1:length(vertex)
        for j = 1:hyb
            allcalled = [];
            for k = 1:channum
                include(j).points(k).channel = inpolygon(points(j).dots(k).channels(:,1),points(j).dots(k).channels(:,2),vertex(i).x+regvec(1),vertex(i).y+regvec(2));
                %include(j).points(k).channel = inpolygon(points(j).dots(k).channels(:,1),points(j).dots(k).channels(:,2),vertex(i).x,vertex(i).y);
                allcalled = [allcalled; rawfound(j).found(k).consensus(include(j).points(k).channel,:)];
            end
            copy = histc(allcalled(:),0:length(allcodes));
            copynum(:,j) = copy(2:end);
        end
        copynumfinal(:,i+1) = num2cell(max(copynum,[],2));
        copynumfinalsum(:,i+1) = num2cell(sum(copynum,2));
        for wa = 1:channum
            incelldropped = inpolygon(points(hyb).dots(wa).channels(:,1),points(hyb).dots(wa).channels(:,2),vertex(i).x,vertex(i).y);
            numdropped(1,i) = sum(logical(rawfound(hyb).found(wa).dropped) & incelldropped);
        end
   end
            
else

    copynumfinal = num2cell([1:length(allcodes)]');

    for j = 1:hyb
        allcalled = [];
        for i = 1:channum
            allcalled = [allcalled; rawfound(j).found(i).called];
        end
        a = unique(allcalled);
        copy = [a(2:end),histc(allcalled(:),a(2:end))];
        copynum(copy(:,1),j+1) = copy(:,2);
    end

    dasdf = cellfun(@isempty,num2cell(copynum),'UniformOutput',0);
    copynum(logical(cell2mat(dasdf))) = 0;

    copynumfinal(:,2) = num2cell(max(copynum,[],2));

end

percellsum = sum(cell2mat(copynumfinalsum(:,2:end)));
percell = sum(cell2mat(copynumfinal(:,2:end)));
