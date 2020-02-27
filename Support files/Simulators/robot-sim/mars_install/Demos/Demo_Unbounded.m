function [Command, Exp_status]=Demo_Unbounded(Exp_status,Initialization)
% Example of unbouded environment
% Robots move uniformely distributed around a given circle path.
% No collision avoidance is implemented
% If Exp_status.Workspace is closed, bounded environment is assumed

%-- Experiment initialization
if Initialization
    Command=[];  
    Exp_status.Workspace=[4 0 ;0 0; 0 4 ; 4 4];  % Workspace definition
    Exp_status.Initial_pose=[3.5 2.5 0; 4 2 0 ; 1 1.5 0 ; 0.5 2 0]';
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
C=[3.5; 2];   % center
R=1.5;       % radius
Period=100; % period
% R=1+Exp_status.Time/30;       % radius
% Period=100+Exp_status.Time/10; % period
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
