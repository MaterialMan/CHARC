function [Command, Exp_Status]=Demo_Peg(Exp_Status,Initialization)
% Demo of pursuit-evasion game (PEG)
% Robots have non-holonomic drive
% The "Peg" addon is used in this demo

%-- Experiment definition
if Initialization
    Command=[];
    Exp_Status.Workspace=[0 0; 0 3 ; 5 3; 5 0; 0 0];
    %     Exp_Status.Initial_pose=[2.5 2.5 0; 4 2 0 ; 1 1.5 0]';
    %     Exp_Status.Duration=60;
    %     Exp_Status.Robot.diameter=0.4;
    Exp_Status.Robots=2;  % Number of robot used
    Exp_Status.Addons={'Peg'};  % Enable pursuer-evader addon
    Exp_Status.Peg.Role='PE';   % Robots roles
    Exp_Status.Peg.Speed=[0.1 ; 0.18];  % Robots speed
    return
end
%------

CommandP =PEG_Pursuer(Exp_Status,Exp_Status.Peg.Speed(1));

CommandE =PEG_Evader(Exp_Status,Exp_Status.Peg.Speed(2));

Command=[CommandP , CommandE, CommandP, CommandE, CommandP];

end

% ************ Pursuer Algorithm ************
function Command=PEG_Pursuer(Exp_status,v_max)
Pose=Exp_status.Pose;

% v_max denote the maximum linear speed.
R=0.05;     % semi-distance between wheels

%-- Set max angular speed (rad/s)
w_max=v_max/R;
if (w_max>1), w_max=1; end

%------
dX=Pose(1,2)-Pose(1,1);
dY=Pose(2,2)-Pose(2,1);
phi=Pose(3,1);          % actual heading
phides=atan2(dY,dX);    % desired heading
W=w_max*(wrapToPi(phides-phi)); % compute angular speed

if abs(W)>w_max, W=w_max*sign(W); end
Command=[v_max ; W];  % linear and angular speed
end
%------

% ************ Evader 4 vertexes ************
function Command=PEG_Evader(EXP,vmax)

persistent des_pose status

DIST_THRESHOLD=.8;
STATUS_THRESHOLD=0.1;
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
Command=my_move_to(Pose(:,2),desired_pose_evader,EXP.Sampling_time,vmax);
end

function [U]=my_move_to(P,desired_pose,Ts,max_speed)
R=0.05;     % semi-distance between wheels
DEFAULT_MAX_SPEED=0.15;
CLOSE_DISTANCE=0.03;
CLOSE_ANGLE=5*pi/180;

if nargin<4, max_speed=DEFAULT_MAX_SPEED; end

desired_heading = atan2(desired_pose(2)-P(2),desired_pose(1)-P(1));
pos_diff = norm(desired_pose(1:2)-P(1:2));
or_diff = wrapToPi(desired_pose(3)-P(3));
heading_diff = wrapToPi(desired_heading-P(3));

if (pos_diff>CLOSE_DISTANCE)
    if heading_diff>0, Vr=max_speed; Vl=max_speed*(1-2*heading_diff/pi);
    else Vl=max_speed; Vr=max_speed*(1+2*heading_diff/pi); end
    if (((Vr+Vl)/2)*Ts)>pos_diff
        reduction_ratio=pos_diff/((Vr+Vl)/2)*Ts;
        Vr=Vr*reduction_ratio;
        Vl=Vl*reduction_ratio;
    end
else  % rotate only
    Vr=or_diff*R/Ts;
    if abs(Vr)>max_speed, Vr=sign(Vr)*max_speed; end
    if (abs(or_diff)<=CLOSE_ANGLE), Vr=0; end
    Vl=-Vr;
end
v=(Vl+Vr)/2;
w=(Vr-Vl)/(2*R);
U=[v ; w];
end
%------
