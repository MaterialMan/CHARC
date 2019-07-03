function [Command, Exp_status]=Demo_Obstacles(Exp_status,Initialization)
% Demo of obstacle avoidance
% The "Map" addon is used in this demo

%-- Experiment definition
if Initialization
    Command=[];
    Exp_status.Workspace=[0 0; 0 3 ; 4.5 3; 4.5 0; 0 0];
    Exp_status.Initial_pose=[3.7 1.7 pi ; 0.5 1.2 0]';
    Exp_status.Robots=1;  % Number of robot used
    
    Exp_status.Addons={'Map'};
    
    V(1).Vertex=[2.75         1.75
        3.25         1.75
        3.25         2.25
        2.75         2.25];
    V(2).Vertex=[2.75         0.75
        3.25         0.75
        3.25         1.25
        2.75         1.25];
    V(3).Vertex=[1.25         1.75
        1.75         1.75
        1.75         2.25
        1.25         2.25];
    V(4).Vertex=[1.25         0.75
        1.75         0.75
        1.75         1.25
        1.25         1.25];
    Exp_status.Map.Obstacle=V;
    return
end
%------

Target= [rand*4;rand*3]; % Target


Map=Exp_status.Map;
Pose=Exp_status.Pose;

%%
ka=.2;  % attraction coefficient
kr_obs=0.05;  % repulsive coefficient
kr_rob=kr_obs*20;
d0_obs=0.4; % region of influence [obstacle]
d0_rob=0.5; % region of influence [robot]

%%

N_ob=length(Exp_status.Map.Obstacle);  % number of obstacles

%%
%Obstacle Avoidance Potential Field Method
for j=1:Exp_status.Robots
    
    %if mod(j,
    F_rep_obs=[0;0];
    F_rep_rob=[0;0];
    
    %Potenziale Attrattivo del Target------------------------------------------
    F_att=-ka*(Pose(1:2,j)-Target(:,j));
    
    %Potenziale Repulsivo dell'ostacolo----------------------------------------
    for w=1:N_ob
        dpi = norm(Pose(1:2,j)-Map.Obstacle_distance(j,w).P_min);
        
        if dpi<=d0_obs
            F_repi_obs= kr_obs*(1/dpi-1/d0_obs)*1/(dpi)^1*((Pose(1:2,j)-Map.Obstacle_distance(j,w).P_min)/norm(Pose(1:2,j)-Map.Obstacle_distance(j,w).P_min));
        else
            F_repi_obs=[0;0];
        end
        F_rep_obs = F_rep_obs + F_repi_obs;
    end
    
    %Potenziale Repulsivo di ogni robot----------------------------------------
    if Exp_status.Robots>1
        for q=1:Exp_status.Robots
            if j~=q
                dpi_rob=Map.Robot_distance(j,q);
                if dpi_rob<=d0_rob
                    F_repi_rob= kr_rob*(1/dpi_rob-1/d0_rob)*1/(dpi_rob)^1*(Pose(1:2,j)-Pose(1:2,q));
                else
                    F_repi_rob=[0;0];
                end
                F_rep_rob=F_rep_rob+F_repi_rob;
            end
        end
    end
    
    %Forza Totale--------------------------------------------------------------
    F_tot=F_rep_obs+F_rep_rob+F_att;
    
    error_theta=angular_distance(atan2(F_tot(2),F_tot(1)),Pose(3,j));
    k_omega=0.15;
    k_vel=1;
    Command(2,j)=k_omega*error_theta;
    Command(1,j)=k_vel*norm(F_tot);
    
    scala=500;
    
    F_rep=[0;0];
    F_att=[0;0];
    F_tot=[0;0];
    
    if(Command(1,j)>0.1) 
        Command(1,j)=0.1*((pi-abs(error_theta))/pi); 
    end
end
end

function [x] = angular_distance(a,b)
% Return the angular difference a-b (in rad) with the proper sign
% a and b are in (-pi,pi]

D=[a-b, a-b-2*pi, a-b+2*pi];
[out, ii] = min(abs(D));
x = D(ii);    %x=a-b
end

