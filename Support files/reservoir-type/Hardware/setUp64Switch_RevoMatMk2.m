%%%%%%%%%%%%%%%% SWITCH CONFIGURATION for 64 electrodes - for Mk2 board %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function preps the DAQ cards to output a bit-stream that sets each of the
% different switches, i.e. crosspoint and quad switches (via shift
% registers).
% Crosspoint switches are serially loaded by daisy-chaining SIN to SOUT -
% only 4 crosspoint switches on this board

% tip: To check function run time use 'timeit' func
% e.g. timeit(@() setUp64Switch(genotype(1,:,1)))
% 64x1 input
function [inputArray]= setUp64Switch_RevoMatMk2(s2,genotype)

%% Assign switch config from genotype
config = zeros(1024,1);
%identify what genes are being used as inputs
inputArray = find(genotype(:,1));

%encode into string
xpos = [16:-1:1 16:-1:1 16:-1:1 16:-1:1];
for i = 1:length(inputArray)
%     if i <= 16
%         ypos(i) = 2048-inputArray(i)*16;
%     else
        ypos(i) = 1024-inputArray(i)*16;
%     end
%    config(ypos(i)) = 1;
    config((ypos(i)+xpos(inputArray(i)))) = 1;
end;


%% Load crosspoint switches - Brute force
cpswSIN=[1 0 0]; % set PLCK high before transfer
for t = 1:1024
    cpswSIN = [cpswSIN; 1 0 config(t); 1 1 config(t); 1 0 config(t)]; % %set initial config, output one bit of config data
end
cpswSIN = [cpswSIN; 0 0 0; 1 0 0]; % pulse PLCK low to transfer

% %% Load switches - partitioned, i.e. identify what chips have been altered and update them 
% cpswSIN = zeros(6147,3); % this can be parsed
% cpswSIN(1,:)=[1 0 0]; % set PLCK high before transfer
% switchFlag = [1 1 1 1 1 1 1 1]; %each positive bit indicates which switch has been changed 
% changedSwitches = ((find(switchFlag)-1)*256); %identify switches that have been changed
% 
% for s = 1:length(changedSwitches)
%     for t = 1:256
%         cpswSIN((changedSwitches(s)*3 +(t-1)*3)+2:changedSwitches(s)*3 +(t*3)+1,:) = [1 0 switchConfig(changedSwitches(s)+t); 1 1 switchConfig(changedSwitches(s)+t); 1 0 switchConfig(changedSwitches(s)+t);]; % %set initial config, output one bit of config data
%     end
% end
% cpswSIN(end-1:end,:) = [0 0 0; 1 0 0]; % pulse PLCK low to transfer
% 

%% Setup DAQ IN/OUT switches (74HC595 8-bit shift register and ADG1634 Quad SPDT switch) serial load - MSbit first
%SHCP = SRCLK; STCP = held LOW when writing to shift register, lathced when
%HIGH; OE = data at output when LOW, HIGH high impedance OFF state (clear shift reg); MR = LOW is SR reset (cleared shift reg sent to storage reg); DS = Data line & Q7* (daisy chain), stored on the rising-edge

%example: shiftConfig = round(rand(64,1));

% Reset shift reg and shift memory, i.e. OE = HIGH Z-state, MR = LOW reset 
shiftConfig = genotype(:,1);

%NEW setup%[MR SD SHCP STCP OE]
shiftReg = [1 0 1 0 0 ; 0 0 0 0 0; 0 0 1 0 0; 1 shiftConfig(length(genotype(:,1))) 1 0 0]; 

for r = length(genotype(:,1)):-1:1 
%      if mod(r,4) == 0 %&& mod(r,16) ~= 0 
%         shiftConfig(r) = 1-genotype(1,r,1); %flip 4th bit - due to reverse connection on the Quad switch
%         if mod(r,16) == 0 %Annoying hardware implementation, shift reg switched for every 16 connection
%             shiftConfig(r) = genotype(1,r,1);
%             shiftConfig(r-1) = 1-genotype(1,r-1,1);
%         end
%      end
                            %push & latch previous data      clock data (SHCP HIGH)        
      shiftReg = [shiftReg;   1 shiftConfig(r) 0 1 0;      1 shiftConfig(r) 1 0 0];  
end
 
shiftReg = [shiftReg;   1 shiftConfig(1) 0 1 0];  

%% % Queue all data outputs
%s2.queueOutputData([cpswSIN [shiftReg; ones(6014,1) zeros(6014,4)]]);
s2.queueOutputData([cpswSIN [shiftReg; ones(length(cpswSIN)-length(shiftReg),1) zeros(length(cpswSIN)-length(shiftReg),4)]]);

%% Output the queued data at SclkFreq rate
s2.startForeground;



