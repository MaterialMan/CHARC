%% Not finished- weighted needs fixing

function [outputData,inputLoc,queue] = createOuputQueue(inputSequence,weightedSequence,maxInputs,queueType,genotype,inputLoc,queue)
%% Create output queue for DAQ OUT
%if isempty(inputLoc) && isempty(queue)
    switch(queueType)
        case 'simple'
            queue = zeros(32,1); inputLoc = zeros(32,1);
            for i = 1:length(genotype)
                if genotype(i,2) == 1
                    if genotype(i,3) == 1 %input weight
                        if genotype(i,1) > 32
                            if mod(genotype(i,1),16) == 0
                                pos = 32;
                            else
                                pos = mod(genotype(i,1),16)+16;
                            end
                            queue(pos) = genotype(i,5);
                            outputData(:,pos) = inputSequence*queue(pos);
                            inputLoc(pos) = 1;
                        else
                            if mod(genotype(i,1),16) == 0
                                pos = 16;
                            else
                                pos = mod(genotype(i,1),16);
                            end
                            queue(pos) = genotype(i,5);
                            outputData(:,pos) = inputSequence*queue(pos);
                            inputLoc(pos) = 1;
                        end
                    else % control input
                        if genotype(i,1) > 32
                            if mod(genotype(i,1),16) == 0
                                pos = 32;
                            else
                                pos = mod(genotype(i,1),16)+16;
                            end
                            queue(pos) = genotype(i,4);
                            outputData(:,pos) = ones(size(inputSequence))*queue(pos);
                            inputLoc(pos) = 1;
                        else
                            if mod(genotype(i,1),16) == 0
                                pos = 16;
                            else
                                pos = mod(genotype(i,1),16);
                            end
                            queue(pos) = genotype(i,4);
                            outputData(:,pos) = ones(size(inputSequence))*queue(pos);
                            inputLoc(pos) = 1;
                        end
                    end
                end
            end
        case 'Weighted'
            queue = zeros(32,1); inputLoc = zeros(32,1);
            for i = 1:length(genotype)
                if genotype(i,2) == 1
                    if genotype(i,3) == 1 %input weight
                        if genotype(i,1) > 32
                            if mod(genotype(i,1),16) == 0
                                pos = 32;
                            else
                                pos = mod(genotype(i,1),16)+16;
                            end
                            queue(pos) = genotype(i,5);
                            outputData(:,pos) = weightedSequence(:,i)*queue(pos);
                            inputLoc(pos) = 1;
                        else
                            if mod(genotype(i,1),16) == 0
                                pos = 16;
                            else
                                pos = mod(genotype(i,1),16);
                            end
                            queue(pos) = genotype(i,5);
                            outputData(:,pos) = weightedSequence(:,i)*queue(pos);
                            inputLoc(pos) = 1;
                        end
                    else % control input
                        if genotype(i,1) > 32
                            if mod(genotype(i,1),16) == 0
                                pos = 32;
                            else
                                pos = mod(genotype(i,1),16)+16;
                            end
                            queue(pos) = genotype(i,4);
                            outputData(:,pos) = ones(size(inputSequence,1),1)*queue(pos);
                            inputLoc(pos) = 1;
                        else
                            if mod(genotype(i,1),16) == 0
                                pos = 16;
                            else
                                pos = mod(genotype(i,1),16);
                            end
                            queue(pos) = genotype(i,4);
                            outputData(:,pos) = ones(size(inputSequence,1),1)*queue(pos);
                            inputLoc(pos) = 1;
                        end
                    end
                end
            end
        otherwise
    end
    
% else
%     %% replace input data
%     switch(queueType)
%         case 'simple'
%             outputData = [];
%             for i = 1:length(queue)
%                 if inputLoc(i) == 1
%                     outputData(:,i) = inputSequence*queue(i);
%                 else
%                     outputData(:,i) = ones(size(inputSequence))*queue(i);
%                 end
%             end
%         case 'Weighted'
%             outputData = [];
%             for i = 1:length(queue)
%                 if inputLoc(i,1) == 1
%                     outputData(:,i) = weightedSequence(:,inputLoc(i,2))*queue(i);
%                 else
%                     outputData(:,i) = ones(size(inputSequence,1),1)*queue(i);
%                 end
%             end
%         otherwise
%     end
%     
% end

% Append zeros to any unused input channels
[len,wid]=size(outputData);
if wid < maxInputs
    outputData = [outputData zeros(len,maxInputs-wid)];
end