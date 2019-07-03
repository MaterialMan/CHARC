function [Command, Exp_status]=Demo_Sensor(Exp_status,Initialization)
% Demo of sensor use.
% The "Peg" and "Map" addons are used in this demo
% It consists in a pursuit-evasion game where the pursuer is equipped with
% a range finder sensor.

% In this demo, such a sensor is not used to compute the pursuer command,
% but only to show its use and the corresponding animation.


%-- Experiment definition
if Initialization
    Command=[];
    Exp_status.Workspace=[0 0; 0 2.8 ; 4.3 2.8; 4.3 0; 0 0];
    Exp_status.Initial_pose=[0.5 2.5 0; 3 1.5 0 ]';
    % Exp_status.Initial_pose=[4 1.5 0; .2 .2 0 ; 1 1.5 0]';
    % Exp_status.Duration=60;
    % Exp_status.Robot.Diameter=0.3;
    Exp_status.Robots=2;  % Number of robot used
    Exp_status.Addons={'Peg','Map'};  % Enable pursuer-evader addon
    Exp_status.Peg.Role='PE';   % Robots roles
    Exp_status.Peg.Speed=[0.1 ; 0.18];  % Robots speed
    Exp_status.Animation.Grid=0;
    
    V(1).Vertex=[2.75         1.75
        3.25         1.75
        3.25         2.25
        2.75         2.25];
    V(2).Vertex=[1.75         1.75
        2.25         1.75
        2.25         2.25
        1.75         2.25];
    
    Exp_status.Map.Obstacle=V;
    
    Exp_status=Add_sensor(Exp_status,1,{'RangeFinder','ProximitySensor'});  % add sensors to robot 1
    Exp_status.Agent(1).Sensor(1).Range=1.5;
    Exp_status.Agent(1).Sensor(1).Angle_span=pi/4;
    Exp_status.Agent(1).Sensor(1).Number_of_measures=46;
    Exp_status.Agent(1).Sensor(1).Show_beam=1;
    Exp_status.Agent(1).Sensor(1).Show_range=1;
    Exp_status.Agent(1).Sensor(2).Range=0.4;
    Exp_status.Agent(1).Sensor(2).Angle_span=pi/4;
    Exp_status.Agent(1).Sensor(2).Number_of_measures=46;
    Exp_status.Agent(1).Sensor(2).Show_range=1;
    Exp_status.Agent(1).Sensor(2).Show_beam=1;
    
    return
end
%------


%[Exp_status.Agent(1).Sensor(1).Presence  Exp_status.Agent(1).Sensor(1).Presence]
%detected_robot=Exp_status.Agent(1).Sensor(1).Detected_robots
%detected_obstacles=Exp_status.Agent(1).Sensor(1).Detected_obstacles


CommandP=PEG_Pursuer(Exp_status,Exp_status.Peg.Speed(1));
CommandE=PEG_Evader(Exp_status,Exp_status.Peg.Speed(2));
Command=[CommandP , CommandE, CommandP, CommandE, CommandP];

end

% ************ Pursuer Algorithm ************
function Command=PEG_Pursuer(Exp_status,v_max)

Pose=Exp_status.Pose;

% v_max denote the maximum linear speed.
R=0.05;     % semi-distance between wheels
%-- Set max angular speed (rad/s)
w_max=v_max/R;
if (w_max>1) 
    w_max=1; 
end

%------
%replace with controller
dX=Pose(1,2)-Pose(1,1);
dY=Pose(2,2)-Pose(2,1);

phi=Pose(3,1);          % actual heading
phi_des= atan2(dY,dX);    % desired heading
W = w_max*(wrapToPi(phi_des-phi)); % compute angular speed

if abs(W) > w_max, W=w_max*sign(W); end
Command=[v_max ; W];  % linear and angular speed
end
%------

% ************ Evader 4 vertexes ************
function Command=PEG_Evader(EXP,vmax)
persistent des_pose status
DIST_THRESHOLD=.8;
STATUS_THRESHOLD=0.1;
Q(:,1)=[4   2.5 5*pi/4]';
Q(:,2)=[0.5 2.5 -pi/4]';
Q(:,3)=[0.5 0.5 pi/4]';
Q(:,4)=[4   0.5 3*pi/4]';

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
