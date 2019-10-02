function [Exp_Status]=Peg_Loop(Exp_Status)
% Check bounds, collisions, timeout and winner

%-- Check bounds
[outside,idx]=Check_bounds(Exp_Status);
if outside
    msg=['\nRobot #',num2str(idx),' outside bounds.\n'];
    if Exp_Status.Peg.Role(idx)=='P', msg=[msg, 'EVADER WINS!\n\n']; else msg=[msg, 'PURSUER WINS!\n\n']; end
    Exp_Status.Exp_over=true;
    Exp_Status.Exp_over_msg=msg;
    return
end
%------

%-- Check collisions
[collision, M_idx]=Check_collision(Exp_Status);
if collision
    E_collision=false;
    msg='\nCollision detected.\n';
    for i=1:Exp_Status.Robots
        if Exp_Status.Peg.Role(i)=='E'
            if any(M_idx(i,:)), E_collision = true; end
        end
    end
    if E_collision, msg=[msg, 'PURSUER WINS!\n\n'];
    else msg=[msg, 'EVADER WINS!\n\n']; end
    Exp_Status.Exp_over=true;
    Exp_Status.Exp_over_msg=msg;
    return
end
%------

%-- Check timeout
if Exp_Status.Time>=Exp_Status.Stop_time
    msg='\nTime is over.\nEVADER WINS!\n\n';
    Exp_Status.Exp_over=true;
    Exp_Status.Exp_over_msg=msg;
end
%------
end

