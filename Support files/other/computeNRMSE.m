function [NRMSE] = computeNRMSE(estimated_output, correct_output)
% Computes the NRMSE between estimated and correct ESN outputs.
% 
% input arguments:
% estimatedOutput: array of size N1 x outputDimension, containing network
% output data. Caution: it is assumed that these are un-rescaled and
% un-shifted, that is, the transformations from the original data format
% via esn.teacherScaling and esn.teacherShift are undone. This happens
% automatically when the estimatedOutput was obtained from calling
% test_esn.
%
% correctOutput: array of size N2 x outputDimension, containing the
% original teacher data. 
%
% output:
% err: a row vector of NRMSE's, each corresponding to one of the output
% dimensions.
%
% If length(correctOutput) > length(estimatedOutput), the first
% elements from correctOutput are deleted. This accounts for cases where
% some (nForgetPoints many) initial transient data points were cancelled
% from estimatedOutput, as occurs in calls to test_esn.
%
% Version 1.0, June 6, 2006, H. Jaeger (as compute_error)
% Revision 1, August 17, 2007, H. Jaeger (renamed to compute_NRMSE,
%                    changed length to size)
% Copyright: Fraunhofer IAIS 2006 / Patents pending

[n_estimate_points, num_eval]= size(estimated_output) ; 
wash_out = size(correct_output, 1) - n_estimate_points ; 
correct_output = correct_output(wash_out+1:end,:) ; 
correctVariance = var(correct_output) ; 
meanerror = sum((estimated_output - correct_output).^2)/n_estimate_points ; 
NRMSE = (sqrt(meanerror./correctVariance)) ;  

%NRMSE = sqrt(immse(estimatedOutput,correctOutput));
for i = 1:num_eval
    if isnan(NRMSE(i))
        NRMSE(i) = 1;
    end
end

if NRMSE > 1000
    NRMSE = 1;
end

%%
NMSE = (sum((estimated_output - correct_output).^2)/n_estimate_points)/var(estimated_output);
