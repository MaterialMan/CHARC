function [Command, Exp_status]= explore_behaviour(Exp_status,Initialization,genotype,config)
% Demo of obstacle avoidance
% The "Map" addon is used in this demo

%-- Experiment definition
if Initialization
    Command=[];
    Exp_status.Workspace = [0 0; 0 config.bounds_y; config.bounds_x config.bounds_y; config.bounds_x 0; 0 0];
    
    Exp_status.Robots=1;  % Number of robot used
    
      
    if config.num_obstacles > 0
        
         Exp_status.Addons={'Map'};
         
        for obs = 1:config.num_obstacles
            centre = [rand*config.bounds_x rand*config.bounds_y];
            poly_size = randi([1 4]);
            size_range = [0.5 0.75 1];
            poly = nsidedpoly(randi([3 6],1),'Center',centre,'SideLength',size_range(poly_size));
            V(obs).Vertex = poly.Vertices;
        end
        
        Exp_status.Map.Obstacle=V;
        
       
    
        % assign inital position
        inside_poly = 1;
        while(inside_poly)
            inital_position = [rand*config.bounds_x rand*config.bounds_y pi ; rand*config.bounds_x rand*config.bounds_y 0]';
            for i = 1:length(Exp_status.Map.Obstacle)
                inside=inpolygon(inital_position(1,:),inital_position(2,:),V(i).Vertex(:,1)+0.25,V(i).Vertex(:,2)+0.25);
                outside(i)= sum(inside) > 0;
            end
            inside_poly  = sum(outside) > 0;
        end
    else
        inital_position = [rand*config.bounds_x rand*config.bounds_y pi ; rand*config.bounds_x rand*config.bounds_y 0]';
    end
    
    
    
    Exp_status.Initial_pose = inital_position;
    
    % set initial target
    %     inside_poly = 1;
    %     while(inside_poly)
    %         Target = [rand*4; rand*3];
    %         for i = 1:length(Exp_status.Map.Obstacle)
    %             inside=inpolygon(Target(1,:),Target(2,:),Exp_status.Map.Obstacle(i).Vertex(:,1)+0.25,Exp_status.Map.Obstacle(i).Vertex(:,2)+0.25);
    %             outside(i)= sum(inside) > 0;
    %         end
    %         inside_poly  = sum(outside) > 0;
    %     end
    %     Exp_status.Target = Target;
    
    % set sensors
    Exp_status=Add_sensor(Exp_status,1,{'RangeFinder'});  % add sensors to robot 1
    if config.evolve_sensor_range
        if isfield(genotype,'esnMinor')
            Exp_status.Agent(1).Sensor(1).Range= genotype.esnMinor.leakRate; % use leakRate as a dummy
        else
            Exp_status.Agent(1).Sensor(1).Range= genotype.leakRate;
        end
    else
        Exp_status.Agent(1).Sensor(1).Range= config.sensor_range;
    end
    Exp_status.Agent(1).Sensor(1).Angle_span=pi/4;
    Exp_status.Agent(1).Sensor(1).Number_of_measures = config.num_sensors;
    Exp_status.Agent(1).Sensor(1).Show_beam=1;
    Exp_status.Agent(1).Sensor(1).Show_range=1;
    
    return
end
%------

% assign new target
% if mod(Exp_status.Iteration,5) == 0
%     inside_poly = 1;
%     while(inside_poly)
%         Target = [rand*4; rand*3];
%         for i = 1:length(Exp_status.Map.Obstacle)
%             inside=inpolygon(Target(1,:),Target(2,:),Exp_status.Map.Obstacle(i).Vertex(:,1)+0.25,Exp_status.Map.Obstacle(i).Vertex(:,2)+0.25);
%             outside(i)= sum(inside) > 0;
%         end
%         inside_poly  = sum(outside) > 0;
%     end
%     Exp_status.Target = Target;
% else
%     Target = Exp_status.Target;
% end

Pose=Exp_status.Pose;

%%
%ka=.2;  % attraction coefficient
%kr_obs=0.05;  % repulsive coefficient
% kr_rob=kr_obs*20;
% d0_obs=0.4; % region of influence [obstacle]
% d0_rob=0.5; % region of influence [robot]

%%

%N_ob=length(Exp_status.Map.Obstacle);  % number of obstacles

%%
%Obstacle Avoidance Potential Field Method
for j=1:Exp_status.Robots
    
    %if mod(j,
    %F_rep_obs=[0;0];
    %F_rep_rob=[0;0];
    
    %Potenziale Attrattivo del Target------------------------------------------
    %F_att=-ka*(Pose(1:2,j)-Target(:,j));
    
    %Potenziale Repulsivo dell'ostacolo----------------------------------------
    %k_omega=0.15;
    %k_vel=1;
    
    %inputSequence = Exp_status.Agent.Sensor.Range - [Exp_status.Agent.Sensor.Measured_distance]';
    
    inputSequence = [Exp_status.Agent.Sensor.Measured_distance]';
    
    %-----------insert NN code
    [testStates,genotype] = config.assessFcn(genotype,inputSequence,config); %[testStates,genotype]
    
    output = testStates*genotype.outputWeights;
    
    F_rep_obs = output(1:2);
    k_omega = output(3);
    k_vel = abs(output(4));
    
    
    %Forza Totale--------------------------------------------------------------
    F_tot=F_rep_obs;%+F_att;
    
    error_theta = angular_distance(atan2(F_tot(2),F_tot(1)),Pose(3,j));
    
    Command(2,j)=k_omega*error_theta;
    Command(1,j)=k_vel*norm(F_tot);
    
    %scala=500;
    
    %F_rep=[0;0];
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

