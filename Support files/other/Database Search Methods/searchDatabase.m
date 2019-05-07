
function [final_error, final_metrics,output] =  searchDatabase(config,database,genotype)

rng(config.rngState,'twister');

fun = @(x) getError(x);

x0 = length(database);

options = optimoptions('fminunc','Algorithm','quasi-newton');

options.Display = 'iter';

[final_metrics, final_error, ~, output] = fminunc(fun,x0,options);

function y = getError(x)
    %distances = pdist2(database,x);%[round(x(1)) x(2)]);
    %[~,indx] = min(distances);
    indx = round(x);
    
    %evaluate ESN on task
    task_error = assessDBonTasks(config,genotype(indx),database(indx,:));
    
    y = task_error.outputs;
end
end