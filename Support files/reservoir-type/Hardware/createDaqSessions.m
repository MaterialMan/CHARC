function [read_session,switch_session] = createDaqSessions(AI,AO)

%% Define DAQ sessions
% Assign input and output card channels
if nargin <1
    AI = 0:63;  AO = 0:31;
end

read_session = daq.createSession ('ni');

read_session.addAnalogInputChannel('Dev1', AI, 'Voltage');

%Assign output channels
read_session.addAnalogOutputChannel('Dev2', AO, 'Voltage');% Add a dummy analog channel (so we can use its clock)

%sync devices using triggers
read_session.addTriggerConnection('Dev2/PFI6','Dev1/PFI0','StartTrigger'); %trigger connection

for i = 1:length(AI)
    read_session.Channels(i).TerminalConfig = 'SingleEnded';%NonReferenced
end

% Set card scan freq (to read) should be atleast double target output
%*remember RateLimit is defined by 250000/no. of active channels, e.g. in a
%8 channel setup RateLimit is 31250 per channel
read_session.Rate =max(read_session.RateLimit);

% Initialise switch session for DAQ
switch_session = daq.createSession ('ni');

%%%%%%%%%%%%%%%%% DIGITAL I/O TO CONFIGURE SWITCHES %%%%%%%%%%%%%%%%%%%%%%%
% Configure the digital IO rate: min 20KHz, max 5MHz
sclkFreq = 50e3;
switch_session.Rate = sclkFreq;

% create 3 digital output channels: PCLK SCLK SIN
switch_session.addDigitalChannel('dev1', 'Port0/Line0:7', 'OutputOnly'); %crosspoint channels [PCLK SCLK SIN]

% Add a dummy analog channel (so we can use its clock)
switch_session.addAnalogInputChannel('Dev1',0,'Voltage');