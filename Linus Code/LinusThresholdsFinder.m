function hyb = LinusThresholdsFinder(hybnum, lower, upper, increment)

for i = 1:length(hybnum)
    counter = 1;
    for k = lower:increment:upper
        multiplier = repmat(k,1,length(hybnum(1).color));
        HCRorFISH = zeros(1,length(hybnum(1).color));
        [~,dots] = findDotsBarcodeV2(hybnum(i).color, multiplier, HCRorFISH,0);
        ya = permute(struct2cell(dots),[3 1 2]);
        num(:,counter) = cellfun(@length,ya(:,2));
        counter = counter +1;
    end
    hyb(i).dotnum = num;
    clear num
end
            
            
            
        