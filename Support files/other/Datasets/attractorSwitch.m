
function [out] = attractorSwitch(data_length,num_attractors,to_plot)

rng(1,'twister')
out = [];
t = linspace(-10,10,data_length/num_attractors);
out(:,1) = sin(t*2*pi) + 2*rand*cos(t*2*pi)-1;
out(:,2) = cos(t*2*pi) + 2*rand*sin(t*2*pi)-1;

for i = 1:num_attractors-1
    ex = [2*rand*sin(t*2*pi) + randi([-8 8]);...
        2*rand*cos(t*2*pi) + randi([-8 8])]';
    out = [out; ex];
end

if to_plot
    tail = 50;
    for k = tail+1:10:length(out)-1
        plot(out(k-tail:k,1),out(k-tail:k,2))
        xlim([-10 10])
        ylim([-10 10])
        drawnow
    end
end