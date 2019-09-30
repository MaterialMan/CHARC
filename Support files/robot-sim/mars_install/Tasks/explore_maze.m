function [Command, Exp_status,individual,test_states]= explore_maze(Exp_status,Initialization,individual,config)
% Demo of obstacle avoidance
% The "Map" addon is used in this demo

%-- Experiment definition
if Initialization
    Command=[];
    
    m = maze(config.maze_size,config.maze_size,[1,1],[config.maze_size config.maze_size],false);    

    Exp_status.Workspace = [0 0; 0 config.bounds_y; config.bounds_x config.bounds_y; config.bounds_x 0; 0 0];%[min_m min_m; min_m max_m; max_m max_m; max(m) min_m; min_m min_m];
    
    Exp_status.Robots = 1;  % Number of robot used
    
    Exp_status.Addons={'Map'};
   
    cnt = 1;
    m = m.*[config.bounds_x config.bounds_y];
    
    for i = 1:3:length(m)
        V(cnt).Vertex = [m(i,:); m(i+1,:)];
        cnt = cnt +1;
    end
    
    %V.Vertex =  m(~isnan(m(:,1)),:);
    Exp_status.Map.Obstacle= V;
                    
    %inital_position = [rand*config.bounds_x rand*config.bounds_y pi ; rand*config.bounds_x rand*config.bounds_y 0]';
    init_pos = [.5 .5 config.bounds_x-.5 config.bounds_y-.5];
    inital_position = [init_pos(randi([1 length(init_pos)],2,1)) pi; init_pos(randi([1 length(init_pos)],2,1)) 0]';%[.2 .2 pi ; .2 .2 0]';
    
    
    Exp_status.Initial_pose = inital_position;
    
    % set sensors
    Exp_status=Add_sensor(Exp_status,1,{'RangeFinder'});  % add sensors to robot 1
    if config.evolve_sensor_range
        %if isfield(individual,'esnMinor')
         %   Exp_status.Agent(1).Sensor(1).Range= individual.esnMinor.leakRate; % use leakRate as a dummy
        %else
            Exp_status.Agent(1).Sensor(1).Range= individual.leak_rate;
       % end
    else
        Exp_status.Agent(1).Sensor(1).Range= config.sensor_range;
    end
      
    Exp_status.Agent(1).Sensor(1).Angle_span=config.sensor_radius;
    Exp_status.Agent(1).Sensor(1).Number_of_measures = config.num_sensors;
    Exp_status.Agent(1).Sensor(1).Show_beam=1;
    Exp_status.Agent(1).Sensor(1).Show_range=1;
    
    test_states = [];
    return
end
%------
Pose=Exp_status.Pose;

%%
%Obstacle Avoidance Potential Field Method
for j=1:Exp_status.Robots
    
    %input = Exp_status.Agent.Sensor.Measured_distance.*config.scaler;
    
    input_sequence = [0; Exp_status.Agent.Sensor.Measured_distance]'; %add constant input
    
    %-----------insert NN code
    [test_states(j,:),individual] = config.assessFcn(individual,input_sequence,config); %[testStates,genotype]
    
    output = test_states(j,:)*individual.output_weights;
    
    F_rep_obs = output(1:2);
    k_omega = output(3);
    k_vel = output(4); % maybe negative (reverse) and positive (forward)
    
    
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

