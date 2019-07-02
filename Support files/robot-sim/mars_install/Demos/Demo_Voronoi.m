function [Command, Exp_status]=Demo_Voronoi(Exp_status,Initialization)
% Demo of coverage task.
% The "Voronoi" addon is used in this demo to compute and plot Voronoi cell

%-- Experiment definition
if Initialization
    Command=[];
    Exp_status.Workspace=[0 0; 0 4 ; 4 4; 4 0; 0 0];
%     Exp_status.Workspace=[0 0; 0 4 ; 2 6; 6 5;3 4; 4 0];
%     Exp_status.Initial_pose=[1 1 0; 2 1 0; 3 2 0]';
    Exp_status.Robots=3;  % Number of robot used
    Exp_status.Addons={'Voronoi'};  % Enable voronoi addon
    for k=1:Exp_status.Robots
        Exp_status.Voronoi.Cell(k).Visible_cell=1;
        Exp_status.Voronoi.Cell(k).Enable_centroid_computation=1;
        Exp_status.Voronoi.Cell(k).Visible_centroid=1;
    end
    return
end
%------

%-- circolar trajectories definition
C=[2; 2];   % center
R=1;        % radius
Period=100; % period

for k=1:Exp_status.Robots
    desired_pose(1:2,k)=C+R*[cos((2*pi*Exp_status.Time/Period+(k-1)*2*pi/Exp_status.Robots)) ; sin((2*pi*Exp_status.Time/Period+(k-1)*2*pi/Exp_status.Robots))];
    desired_pose(3,k)=atan2(-(desired_pose(2,k)-C(2)),-(desired_pose(1,k)-C(1)));
    Command(:,k)=move_to(Exp_status,Exp_status.Pose(:,k),desired_pose(:,k),.5);
end
%------
end
