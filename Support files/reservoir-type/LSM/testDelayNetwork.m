
N = 10;
Dmax = 10;

config.dataSet = 'Laser';                 % Task to evolve for
config.discrete = 0;               % binary input for discrete systems
config.nbits = 16;                       % if using binary/discrete systems 
config.preprocess = 1;                   % basic preprocessing, e.g. scaling and mean variance

% get dataset 
[config] = selectDataset(config);

input = config.trainInputSequence;

W = 2*rand(N)-1;
Win = 2*rand(N,size(input,2))-1;

Din = randi([1 Dmax],size(input,2),N);
Dw = randi([1 Dmax],size(input,2),N);

x = zeros(size(input,1),N);

for t = Dmax+1:size(input,1)
    for i = 1:N
        u(i) = input(t-Din(i),:);
        xd(i) = x(t-Dw(i),i);
    end
    z = Win.*u + W*xd;
    x(t,:) = tanh(z);   
end

figure
plot(x)