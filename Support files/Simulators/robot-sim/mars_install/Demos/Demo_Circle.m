function [Command, Exp_status]=Demo_Circle(Exp_status,Initialization)
% Robots move uniformely distributed around a given circle path.
% No collision avoidance is implemented

%-- Experiment initialization
if Initialization
    Command=[];  
    Exp_status.Workspace=[0 0; 0 4 ; 4 4; 4 0; 0 0];  % Workspace definition
    Exp_status.Robots=4; % Number of robot used
    
    %-- Animation setting
%     Exp_status.Animation.Wake=0; % disable robot wake
%     Exp_status.Animation.Show_initial_pose=0; % hide initial position
%     Exp_status.Animation.Grid=0; % remove grid
    %--
    return
end
%------

% %-- Define circular trajectory to be followed by robots
C=[2; 2];   % center
R=1;        % radius
Period=100; % period
% %------
% 
%-- Robot speed computation
for k=1:Exp_status.Robots
    desired_pose(1:2,k)=C+R*[cos((2*pi*Exp_status.Time/Period+(k-1)*2*pi/Exp_status.Robots)) ; sin((2*pi*Exp_status.Time/Period+(k-1)*2*pi/Exp_status.Robots))];
    desired_pose(3,k)=atan2(-(desired_pose(2,k)-C(2)),-(desired_pose(1,k)-C(1)));
    Command(:,k)=move_to(Exp_status,Exp_status.Pose(:,k),desired_pose(:,k),0.5);
end
%------
end
