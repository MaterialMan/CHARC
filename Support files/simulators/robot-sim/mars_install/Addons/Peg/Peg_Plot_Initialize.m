function [Exp_Status]=Peg_Plot_Initialize(Exp_Status)

Pursuers=(Exp_Status.Peg.Role=='P');
Evaders=(Exp_Status.Peg.Role=='E');
  
Exp_Status.Animation.Colors(Pursuers)='k';  % pursuers = black
Exp_Status.Animation.Colors(Evaders)='b';   % Evader = red
end

