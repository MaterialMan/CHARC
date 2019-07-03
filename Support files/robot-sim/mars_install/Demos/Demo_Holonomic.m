function [Command, Exp_Status]=Demo_Holonomic(Exp_Status,Initialization)
% Demo of pursuit-evasion game (PEG)
% Robots have holonomic drive
% The "Peg" addon is used in this demo

%-- Experiment definition
if Initialization
    Command=[];
    Exp_Status.Workspace=[0 0; 0 3 ; 5 3; 5 0; 0 0];
    Exp_Status.Initial_pose=[1 1.5; 3 1.5]';
    Exp_Status.Robots=2;  % Number of robot used
    Exp_Status.Addons={'Peg'};  % Enable pursuer-evader addon
    Exp_Status.Peg.Role='PE';   % Robots roles
    Exp_Status.Peg.Speed=[0.1 ; 0.15];  % Robots speed
    Exp_Status.Non_holonomic=false;  % holonomic drive
    return
end
%------

CommandP=PEG_Pursuer(Exp_Status,Exp_Status.Peg.Speed(1));
CommandE=PEG_Evader(Exp_Status,Exp_Status.Peg.Speed(2));
Command=[CommandP , CommandE, CommandP, CommandE, CommandP];
end 

% ************ Pursuer Algorithm ************
function Command=PEG_Pursuer(Exp_status,v_max)
dir=(Exp_status.Pose(1:2,2)-Exp_status.Pose(1:2,1));
Command=v_max*dir/norm(dir);
end
%------

% ************ Evader 4 vertexes ************ 
function Command=PEG_Evader(EXP,v_max)
persistent des_pose status
DIST_THRESHOLD=0.7;
STATUS_THRESHOLD=0.2;
Q(:,1)=[4.5   2.5 5*pi/4]';
Q(:,2)=[0.5   2.5 -pi/4]';
Q(:,3)=[0.5   0.5 pi/4]';
Q(:,4)=[4.5   0.5 3*pi/4]';
Pose=EXP.Pose;
if isempty(des_pose), status=4; des_pose=1; end
if norm(Q(1:2,des_pose)-Pose(1:2,2))<STATUS_THRESHOLD, status=des_pose; end
vett=(Pose(1:2,2)-Pose(1:2,1));  % points from pursuer to evader
dist=norm(vett);
if (dist<DIST_THRESHOLD)&&(status==des_pose)
    ang=atan2(vett(2),vett(1));
    switch status
        case 1, if (ang<pi/4), des_pose=4; else des_pose=2; end
        case 2, if (abs(ang)>3*pi/4), des_pose=3; else des_pose=1; end
        case 3, if (abs(ang)>3*pi/4), des_pose=2; else des_pose=4; end
        case 4, if (abs(ang)<pi/4),   des_pose=1; else des_pose=3; end
    end
end
desired_pose_evader=Q(:,des_pose);
dir=desired_pose_evader(1:2)-Pose(1:2,2);
if norm(dir)>v_max,
    dir=(dir/norm(dir))*v_max;
end
Command=dir;
end


