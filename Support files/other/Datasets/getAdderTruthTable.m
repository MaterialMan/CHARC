%% Create binary adder truth table
function truth_table = getAdderTruthTable(type,input)

switch(type)
    
    case 'half_adder'
        % half adder
        output = [];
        %input = de2bi(0:3,'left-msb');
        [output(:,1), output(:,2)] = half_adder(input(:,1),input(:,2));
        truth_table = [input output];
        
    case 'full_adder'
        % full adder
        output = [];
        %input = de2bi(0:7,'left-msb');
        [output(:,1), output(:,2)] = full_adder(input(:,1),input(:,2),input(:,3));
        truth_table = [input output];
        
    case 'nbit_adder'
        % cascading adder - n-bit binary adder
        bit = input(1);
        A = input(2);
        B = input(3);
        input_A = de2bi(A,bit);
        input_B = de2bi(B,bit);
        Answer = A + B;     
        
        for n = 1:bit
            if n ==1
                [S(n),Cout(n)] = full_adder(input_A(n),input_B(n),0);
            else
                [S(n),Cout(n)] = full_adder(input_A(n),input_B(n),Cout(n-1));
            end
        end
        
        pred = bi2de([S Cout(n)],2);
        Correct = pred == Answer;
        
        truth_table = [S Cout(n)];
end


%% functions
    function [S,C] = half_adder(A,B)
        
        S = xor(A,B);
        C = and(A,B);
        
    end

    function [Sout,Cout] = full_adder(A,B,C)
        
        [S_1,C_1] = half_adder(A,B); % first half adder
        
        [Sout,C_2] = half_adder(S_1,C); % second half adder
        
        Cout = or(C_1,C_2); %final carry
        
    end

end