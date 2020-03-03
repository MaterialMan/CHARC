
function states = assessDNAreservoir(genotype,inputSequence,config,target_output)

% constants
Beta = genotype.Beta;           % reaction rate constant = 5 � 10-7 nM s-1
e = genotype.e;                 %e is the efflux rate; e = 8.8750�10-2 nL s-1
H = genotype.H;                 % h the fraction of the reactor chamber that is well-mixed; h = 0.7849
V = genotype.V;                 % volume of the reactor; V = 7.54 nL
tau = genotype.tau;
N = genotype.size;

tspan = [0 size(inputSequence,1)*tau+genotype.washout];

%gate concentrations
G = genotype.GateCon;           %nM Units

Sm = zeros((tspan(2)/config.step_size)-genotype.washout,genotype.size);         %nmol s-1

% calculate input
in_data = inputSequence*genotype.w_in';

%base values for substrate-influx rates
cnt = 1;
for i = genotype.washout+1:tau:tspan(2)/config.step_size
    Sm(i:i+tau-1,:) = repmat(in_data(cnt,:).*genotype.Sm0',tau,1);
    cnt = cnt +1;
end

%initial period of 500s
Sm(1:genotype.washout,:) = repmat(genotype.Sm0',genotype.washout,1);

%%
y0 = [genotype.S0 genotype.P0];

[t,y] = rk4_2(@(t,y,Sm) odeF(t,y,Sm),tspan,y0,Sm,config.step_size);
        
for i = 1:genotype.size
    p(:,i) = y(:,i+genotype.size);
    s(:,i) = y(:,i);
end

states = [s p];

states = states(genotype.washout+1:end-1,:);

if config.concatStates
    statesE = zeros(size(inputSequence,1),tau*config.maxMinorUnits*2);
    for i =  1:tau
        statesE(:,((i-1)*config.maxMinorUnits*2)+1:((i-1)*config.maxMinorUnits*2)+config.maxMinorUnits*2) = states(i:tau:end,:);
    end
else   
    statesE = [];
    for i =  1:1%tau
        statesE = [statesE states(i:tau:end,:)];
    end
end
states = statesE;

if config.evolvedOutputStates
    states= states(config.nForgetPoints+1:end,logical(genotype.state_loc));
else
    states= states(config.nForgetPoints+1:end,:);
end

states = states./(max(states)-min(states));

% check if any are NaNs and infs
states(isnan(states)) = 0;
states(isinf(states)) = 0;

if config.leakOn
    leakStates = zeros(size(states));
    for n = 2:size(states,1)
        leakStates(n,:) = (1-genotype.leakRate)*leakStates(n-1,:)+ genotype.leakRate*states(n,:);
    end
    states = leakStates;
end


if config.AddInputStates
    states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) inputSequence(config.nForgetPoints+1:end,:) states];
else
    %states = [ones(size(inputSequence(config.nForgetPoints+1:end,1))) states];
end

%% Functions
    function dydt = odeF(t,y,Sm)
        for j = 1:N
            if j == 1 % use last node
                dydt(j) = (Sm(j)/V) - H*Beta*y(j)*(G(j) - y(N*2)) - y(j)*(e/V);
                
                dydt(j+N) =  H*Beta*y(j)*(G(j) - y(N*2)) - (e/V)*y(j+N);
            else
                dydt(j) = (Sm(j)/V) - H*Beta*y(j)*(G(j) - y(N+j-1)) - y(j)*(e/V);
                
                dydt(j+N) =  H*Beta*y(j)*(G(j) - y((N+j-1))) - (e/V)*y(j+N);
            end
        end
    end
end