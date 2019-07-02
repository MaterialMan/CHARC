function esn = removeWeight_pipeline(esn,type)

switch(type)
    case 'input'
        nonZeroList = find(esn.inputWeights ~= 0);
        
        if ~isempty(nonZeroList)
            insertXY = randi([1 length(nonZeroList)]);
            esn.inputWeights(nonZeroList(insertXY)) = 0;
        end
        
    case 'internal'
        
        nonZeroList = find(esn.internalWeights_UnitSR ~= 0);
        
        if ~isempty(nonZeroList)
            insertXY = randi([1 length(nonZeroList)]);
            esn.internalWeights_UnitSR(nonZeroList(insertXY)) = 0;
            esn.internalWeights(nonZeroList(insertXY)) = 0;
        end
        
end