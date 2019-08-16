%%%%%%%%%%%%%%%% SWITCH CONFIGURATION for 64 electrodes - for Mk2 board %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function preps the DAQ cards to output a bit-stream that sets each of the
% different switches, i.e. crosspoint and quad switches (via shift
% registers).
% Crosspoint switches are serially loaded by daisy-chaining SIN to SOUT -
% only 4 crosspoint switches on this board

% tip: To check function run time use 'timeit' func
% e.g. timeit(@() setUp64Switch(genotype(1,:,1)))
% 64x1 input
function [inputArray]= setUpSwitch(switch_session,electrode_type)

%% Assign switch config from genotype
switch_config = zeros(1024,1);

%identify what genes are being used as inputs
inputArray = find(electrode_type);

%encode into string
xpos = [16:-1:1 16:-1:1 16:-1:1 16:-1:1];
for i = 1:length(inputArray)
    ypos(i) = 1024-inputArray(i)*16;
    switch_config((ypos(i)+xpos(inputArray(i)))) = 1;
end


%% Load crosspoint switches - Brute force
cpswSIN=[1 0 0]; % set PLCK high before transfer
for t = 1:1024
    cpswSIN = [cpswSIN; 1 0 switch_config(t); 1 1 switch_config(t); 1 0 switch_config(t)]; % %set initial config, output one bit of config data
end
cpswSIN = [cpswSIN; 0 0 0; 1 0 0]; % pulse PLCK low to transfer

%% Setup DAQ IN/OUT switches (74HC595 8-bit shift register and ADG1634 Quad SPDT switch) serial load - MSbit first
%SHCP = SRCLK; STCP = held LOW when writing to shift register, lathced when
%HIGH; OE = data at output when LOW, HIGH high impedance OFF state (clear shift reg); MR = LOW is SR reset (cleared shift reg sent to storage reg); DS = Data line & Q7* (daisy chain), stored on the rising-edge

%example: shiftConfig = round(rand(64,1));

% Reset shift reg and shift memory, i.e. OE = HIGH Z-state, MR = LOW reset 
shift_config = electrode_type > 0;

%NEW setup%[MR SD SHCP STCP OE]
shift_reg = [1 0 1 0 0 ; 0 0 0 0 0; 0 0 1 0 0; 1 shift_config(length(shift_config)) 1 0 0]; 

for r = length(shift_config):-1:1 
      %push & latch previous data      clock data (SHCP HIGH)        
      shift_reg = [shift_reg;   1 shift_config(r) 0 1 0;      1 shift_config(r) 1 0 0];  
end
 
shift_reg = [shift_reg;   1 shift_config(1) 0 1 0];  

%% % Queue all data outputs
switch_session.queueOutputData([cpswSIN [shift_reg; ones(length(cpswSIN)-length(shift_reg),1) zeros(length(cpswSIN)-length(shift_reg),4)]]);

%% Output the queued data at SclkFreq rate
switch_session.startForeground;

release(switch_session);

