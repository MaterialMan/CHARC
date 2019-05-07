function assessPopulation(genotype,config)

if config.parallel
    parfor popEval = 1:config.popSize
        genotype(popEval) = testReservoir(genotype(popEval),config);
        fprintf('\n i = %d, error = %.4f\n',popEval,genotype(popEval).testError);
    end
else
    for popEval = 1:config.popSize
        genotype(popEval) = testReservoir(genotype(popEval),config);
        fprintf('\n i = %d, error = %.4f\n',popEval,genotype(popEval).testError);
    end
end
best_error = min([genotype.valError]);
fprintf('\n Starting loop... Best error = %.4f\n',best_error);

end