function internalWeights = generate_internal_weights(nInternalUnits, ...
    connectivity) 
% GENERATE_INTERNAL_WEIGHTS creates a random reservoir for an ESN
%
% inputs:
% nInternalUnits = the number of internal units in the ESN
% connectivity \in [0,1], says how many weights should be non-zero
%
% output:
% internalWeights = matrix of size nInternalUnits x nInternalUnits
% internalWeights(i,j) = value of weight(synapse) from unit i to unit j
% internalWeights(i,j) might be different from internalWeights(j,i)

%
% Created April 30, 2006, D. Popovici
% Copyright: Fraunhofer IAIS 2006 / Patent pending
% Revision 1, Feb 23, 2007, H. Jaeger
% Revision 2, March 10, 2007, H. Jaeger (replaced eigs by myeigs)
% Revision 3, May 10, 2014, H. Jaeger (replaced myeigs again by eigs)
if nInternalUnits ~= 0
    success = 0 ;
    while success == 0
        % following block might fail, thus we repeat until we obtain a valid
        % internalWeights matrix
        try,
            if isinf(connectivity) || isnan(connectivity)|| connectivity > 1 || connectivity == 0
                connectivity = 1;
            end
            internalWeights = sprand(nInternalUnits, nInternalUnits, connectivity);
            internalWeights(internalWeights ~= 0) = ...
                internalWeights(internalWeights ~= 0)  - 0.5;
            opts.disp = 0;
            maxVal = max(abs(eigs(internalWeights,1, 'lm', opts)));
            internalWeights = internalWeights/maxVal;
            if sum(isnan(internalWeights)) < 1
                success = 1 ;
            end
        catch,
            success = 0 ;  
        end
    end
end
