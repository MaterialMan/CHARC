function [mean_score, order ] = F1Score(targ,predic)
%F1SCORE 
[input_matrix, order] = confusionmat(targ,predic);
%   Compute F1 score by using precision and recall
score = 2*(precision(input_matrix).*recall(input_matrix))./(precision(input_matrix)+recall(input_matrix));
score(isnan(score)) = 1;
mean_score = mean(score);

end

function p = precision(M)
  p = diag(M) ./ sum(M,2);
end

function r = recall(M)
  r = diag(M) ./ sum(M,1)';
end