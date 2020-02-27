%% Assess genotype on robot task
function [individual,states] = robot(individual,config)

% store current seed and reset seed for simulations -- why? robot simulation
% starts from random positions
scurr = rng;
temp_seed = scurr.Seed;
rng(1,'twister');

% If watch simulation, only run one test, else run N tests
if config.run_sim 
    num_tests = config.show_robot_tests; 
else    
    num_tests = config.robot_tests;
end

% run robot simulation
if config.robot_tests <= 4 && config.run_sim == 0
    %temp_geno = genotype;
      for i = 1:num_tests
        [~,temp_geno(i),states]= robotSim(config.robot_behaviour,config.time_steps,'max',[],individual,config);
        
        %record fitness
        train_error(i) = temp_geno(i).train_error;
        val_error(i) = temp_geno(i).val_error;
        test_error(i) = temp_geno(i).test_error;       
      end    
else
    for i = 1:num_tests
        [~,individual,states]= robotSim(config.robot_behaviour,config.time_steps,'max',[],individual,config);
        %record fitness
        train_error(i) = individual.train_error;
        val_error(i) = individual.val_error;
        test_error(i) = individual.test_error;       
    end
end

%assign final fitness
individual.train_error = mean(train_error);
individual.val_error = mean(val_error);
individual.test_error = mean(test_error);

% Go back to old seed
rng(temp_seed,'twister');