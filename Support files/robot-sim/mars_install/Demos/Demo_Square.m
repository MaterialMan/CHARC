function [Command, Exp_status]=Demo_Square(Exp_status,Initialization)
% Four robots moving to the vertex of a square.
% No collision avoidance is implemented

%-- Experiment definition
if Initialization
    Command=[];
    Exp_status.Workspace=[0 0; 0 4 ; 4 4; 4 0; 0 0];
%     Exp_Status.Initial_pose=[3.5 2.5 0; 4 2 0 ; 1 1.5 0 ; 0.5 2 0]';
    Exp_status.Robots=4;  % Number of robot used
    return
end
%------

x0=1.0; y0=1; % bottom-left vertex
R=2;        % side length
s=floor(Exp_status.Time/30);  % time interval
Q(:,1)=[x0 y0 90*pi/180]';
Q(:,2)=[x0 y0+R 0*pi/180]';
Q(:,3)=[x0+R y0+R -90*pi/180]';
Q(:,4)=[x0+R y0 180*pi/180]';
desired_pose(:,4)=Q(:,mod(s,4)+1);
desired_pose(:,2)=Q(:,mod(s+1,4)+1);
desired_pose(:,1)=Q(:,mod(s+2,4)+1);
desired_pose(:,3)=Q(:,mod(s+3,4)+1);
for i=1:Exp_status.Robots
    Command(:,i)=move_to(Exp_status,Exp_status.Pose(:,i),desired_pose(:,i),0.5);
end
end
