function [inputSequence, outputSequence] = NonLinear_ChanEQ_data(dataLength)

choose = [-3 -1 1 3];

for i = 1:dataLength+2
    d(i) = choose(randi([1 4]));
end


for i = 8:dataLength
    q(i)= 0.08*d(i+2) - 0.12*d(i+1) + d(i) + 0.18*d(i-1) - 0.1*d(i-2) + 0.091*d(i-3) - 0.05*d(i-4) + 0.04*d(i-5) +0.03*d(i-6) +0.01*d(i-7);
    u(i) = q(i)+0.036*(q(i).^2) - 0.011*(q(i).^3);
end

% inputSequence(1,:) = awgn(u,12,'measured');
% inputSequence(2,:) = awgn(u,16,'measured');
% inputSequence(3,:) = awgn(u,20,'measured');
% inputSequence(4,:) = awgn(u,24,'measured');
% inputSequence(5,:) = awgn(u,28,'measured');
% inputSequence(6,:) = awgn(u,32,'measured');
inputSequence = u+30;

outputSequence = [0 0 d(1:dataLength-2)];
    

%remove if not working
% for i = 1:size(inputSequence,1)
%     inputSequence(i,:) = (inputSequence(i,:)-mean(inputSequence(i,:)))/(max(inputSequence(i,:))-min(inputSequence(i,:)));
% end

end