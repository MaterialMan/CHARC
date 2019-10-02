function [Exp_Status]=Peg_Initialize(Exp_Status)

PEG_default_speed=0.1;    % Default max linear speed (m/s)
if ~isfield(Exp_Status.Peg,'Speed'),
    Exp_Status.Peg.Speed(1: Exp_Status.Robots)=PEG_default_speed;
end
end


