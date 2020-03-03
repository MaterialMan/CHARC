%% This function calculates the Largest Lyapunov Exponent of the provided reservoir.
% The calculation is done by applying a sinewave to two identical
% reservoirs with one experiencing a small perturbation. Therefore, the LE
% is representative of the difference in distance between resulting
% trajectories

function [LE] = lyapunovExponent(individual,config,seed)

%% Define two identical input sequences, but the second is perturbed at some time T
rng(seed,'twister');
config.wash_out = 50;

n_internal_units = individual.total_units;
n_input_units = individual.n_input_units;

data_length = n_internal_units*2 + config.wash_out;%400; 
data_sequence = 2*rand(data_length,n_input_units)-1;

T = data_length/2; % perturbation time

% rescale for each reservoir
data_sequence_1 = data_sequence.*config.scaler;
data_sequence_2 = data_sequence.*config.scaler;

%perturb signal at time T
pert = 10e-6;
data_sequence_2(T,:) =  data_sequence_2(T,:) + pert; 

X_unpert =  config.assessFcn(individual,data_sequence_1,config);
X_pert =  config.assessFcn(individual,data_sequence_2,config);

for i = 1:size(X_pert,1)
    d(i,:) = norm(X_unpert(i,:)-X_pert(i,:));
end

% lambda = lim(k->inf) 1/k ln(yk/y0)
LE =  log(mean(nonzeros(d))/pert); % rate of divergence, with ?0 being the 
%initial distance between the perturbed and the unperturbed trajectory, 
%and ? k being the distance at time k

