
function [OUTPUT_DATA,individual,states]= robotSim(filename,stop_time,speed,options,individual,config)
%
% MARS Multi-Agent Robot Simulator  -  Simulate and animate a team of robots.
%
%   [OUTPUT_DATA]=mars(FILENAME,STOP_TIME,SPEED,OPTIONS)
%
%   FILENAME is the file containing the robot control law.
%
%   STOP_TIME denotes the length of the simulation (default=100 seconds).
%
%   SPEED denotes the playback speed (default=1).
%       SPEED=0 means "manual mode" (ask for a keypressed at each sampling time).
%       SPEED>0 simulate at a given speed (1=no acceleration/deceleration)
%       SPEED='max' run the simulation at maximum speed.
%
%   OPTION is an optional structure used to override default experiment data.
%       Any field of the experiment status structure can be set.
%
%   OUTPUT_DATA is a struct containing all simulation data.
%
% -- Copyright 2016-19, Marco Casini, Andrea Garulli
%
warning('off','all')
%========================== Set default values ==========================
%-- Experiment variables
EXP.Version='1.7';     % Version of the simulator
EXP.Robots=1;          % Number of robots used
EXP.Workspace=[];      % define polygonal workspace with clockwise vertexes (if empty workspace is open)
EXP.Stop_time=100;     % simulation stop time (sec)
EXP.Command_delay=0;   % delay between robot detection and motor actuation (sec)
EXP.Sampling_time=1;   % control loop sampling time (sec)
EXP.Time=0;            % Actual time of simulation (sec)
EXP.Iteration=0;       % Actual iteration number
EXP.Exp_over=false;    % true if experiment is over
EXP.Non_holonomic=true;% Non-holonomic drive
EXP.Exp_over_msg='Simulation terminated.';   % message when experiment is over
EXP.Default_bounds=[-10 10 -10 10];  % bounds for setting automatic initial conditions for unbounded workspaces
%------
%-- Robot physical characteristics
EXP.Robot.Max_linear_speed=0.2;  % max wheel speed in (m/s)
EXP.Robot.Wheels_semiaxis_length=0.05;   % semi-distance between wheels (m)
EXP.Robot.Diameter=0.18;   % robot diameter (m)
EXP.Robot.Distance_center_barycenter=48.5/1000;  % distance of barycenter from geometric center of big disk
%------
%-- Animation parameters
EXP.Animation.Show_initial_pose=true;    % true=show robot initial poses
EXP.Animation.Show_real_shape=true;      % true=big circles with orientation  false=small circles without orientation
EXP.Animation.Wake=true;                 % true=draw wake
EXP.Animation.Wake_style='-';            % wake style
EXP.Animation.Grid=true;                 % enable/disable grid
EXP.Animation.Title='[Simulation]';      % animation title
EXP.Animation.Base_colors=['k';'r';'g';'b';'m';'c';'y'];    % colors to be used for multi-robot experiments (automatically cycled if needed)
EXP.Animation.Playback_speed=1;          % animation speed (0=manual mode)
if config.run_sim 
    EXP.Animation.Enable=true;               % show/hide animation
else
    EXP.Animation.Enable=false;               % show/hide animation
end

EXP.Animation.Axis_tick=1;               % adaptive axes are rounded to tick
%------
%-- Addons
EXP.Addons=[];
EXP.Addons_suffix={'Initialize','Loop','Plot_Initialize','Plot'};
%------
%========================================================================


%=====================  Simulation Initialization =======================
%-- Preliminary check
if nargin==0
    fprintf('The first argument (filename) is mandatory. Program aborted.\n'); 
    return; 
end

EXP.Filename=filename;
%------
%-- Read experiment data from user function (run user function with second argument = true)
clear global

eval(['[Command , EXP,individual,test_states]=' EXP.Filename '(EXP,true,individual,config);']);
%[Command, EXP]= Demo_Obstacles_Sensor(EXP,1,genotype,config);

%------
%-- Check and set input argument
if nargin>=2 
    if ~isempty(stop_time)
        EXP.Stop_time=stop_time; 
    end
end
if nargin>=3
    if ~isempty(speed)
        EXP.Animation.Playback_speed=speed; 
    end
end
if nargin==4  % override fields defined in options
    fields=fieldnames(options);
    for i=1:length(fields)
        field_data=getfield(options,fields{i});
        if isstruct(field_data)
            fields2=fieldnames(field_data);
            for j=1:length(fields2)
                eval(['EXP.',char(fields{i}),'.',char(fields2{j}),'=options.',char(fields{i}),'.',char(fields2{j}),';']);
            end
        else
            EXP=setfield(EXP,fields{i},field_data);
        end
    end
end
%------

% Determine the type of environment and set Workspace_type field (open=0, unbounded=1, bounded=2)
EXP=Compute_environment(EXP);
%------

%-- for holonomic drive remove orientation if present
if (EXP.Non_holonomic==0)  % Holonomic drive
    EXP.Initial_pose=EXP.Initial_pose(1:2,:);
end
%------

%-- Set initial pose
if (isfield(EXP,'Initial_pose'))
    EXP.Pose=EXP.Initial_pose(:,1:EXP.Robots);
else
    EXP.Pose=Set_initial_pose(EXP);
end
%------
%-- Set robot colors for animation
if ~isfield(EXP.Animation,'Colors') 
    EXP.Animation.Colors=repmat(EXP.Animation.Base_colors,ceil(EXP.Robots/length(EXP.Animation.Base_colors)),1); 
end
% set robot colors
EXP.Animation.Colors=EXP.Animation.Colors(1:EXP.Robots);
%------
%-- compute the geometric center of robots
EXP=Compute_geometric_center(EXP);
%------
%-- for holonomic drive set Distance_center_barycenter to 0
if (EXP.Non_holonomic==0)  % Holonomic drive
    EXP.Robot.Distance_center_barycenter=0;
end
%------

clear functions
EXP=Run_Functions(EXP,1);     % run addons initialization functions (index=1)
EXP=Run_Functions(EXP,2);     % run addons loop functions (index=2) ATTENZIONE AGGIUNTA DOPO XXXX

Command=zeros(2,EXP.Robots);  % set initial command to 0
tic
%========================================================================

% assign target points
x = linspace(0,config.bounds_x,floor(sqrt(config.num_target_points)));
y = linspace(0,config.bounds_y,floor(sqrt(config.num_target_points)));
%create grid
[X,Y] = meshgrid(x,y);
point = [X(:) Y(:)];
EXP.Target_points = point; 
EXP.total_points = size(EXP.Target_points,1);
fitness = 0;

%====================  Simulation Loop (Main loop) ======================
for T1=0:EXP.Sampling_time:EXP.Stop_time
   
    EXP.Iteration=EXP.Iteration+1;
    Command_old=Command;
    T2=T1+EXP.Command_delay;
    
    EXP.History.Time(EXP.Iteration,1)=T1;
    EXP.History.Pose(EXP.Iteration,:,:)=EXP.Pose;
    EXP.History.Command_time(EXP.Iteration,1)=T2;
    
    delta_T=T2-T1;
    EXP.Time=T1;
    
    EXP=Compute_geometric_center(EXP);  % compute the geometric center of robots
    
    if (EXP.Animation.Enable)
        if mod(T1,config.sim_speed) == 0
            EXP=plot_robots(EXP,config.figure_array(1));        % draw animation at time T1
        end
        EXP=Run_Functions(EXP,2);    % run addons loop functions (index=2)
        if EXP.Exp_over             % Check if the experiment is termitated (XXXX)
            break; 
        end  
        EXP=Manage_sensors(EXP);     % run sensors functions
        Synchronize_simulation(EXP); % synchronize the simulation
    else
        EXP=Run_Functions(EXP,2);   % run addons loop functions (index=2)
        EXP=Manage_sensors(EXP);    % run sensors functions
    end
    
    eval(['[Command, EXP,individual,test_states]=' EXP.Filename '(EXP,false,individual,config);']); %-- Run user-defined function
    
    Command=check_saturation(EXP,Command);
    EXP.History.Command(EXP.Iteration,:,:)=Command;
    
    %-- Check if the experiment is termitated
    if EXP.Exp_over
        break; 
    end
    
    if Check_bounds(EXP) 
        EXP.Exp_over=true; 
        EXP.Exp_over_msg='Robots out of bounds! Simulation stopped.\n'; 
        break; 
    end
    
    if Check_Obs_collision(EXP) 
        EXP.Exp_over=true; 
        EXP.Exp_over_msg='Robot collision with obstacle! Simulation stopped.\n'; 
        break; 
    end
        
    if (T1>=EXP.Stop_time)
        EXP.Exp_over=true; 
        EXP.Exp_over_msg='Time is over! Simulation stopped.\n'; 
        break;
    end % exit from loop and stop simulation
    %------
    
    EXP=compute_dynamics(EXP,Command_old,delta_T); % Compute pose at time T1+Command_delay
    delta_T=T1+EXP.Sampling_time-T2;
    EXP=compute_dynamics(EXP,Command,delta_T);  % Compute pose at time T1+Sampling_time
    
    % check if robot reaches close to a target point. Add visited points to
    % fitness
    indx = [];
    prox = abs(EXP.History.Pose(T1+1,1:2) - EXP.Target_points) < 0.1;
    indx = find(sum(prox,2) == 2);
    %prox(indx,:) = [];
    if length(indx) >= 1
        fitness = fitness + 1;
        EXP.Target_points(indx,:) = [];
    end
    
    states(T1+1,:) = test_states;
end

%=== calculate fitness

% calculate fitness
% fitness = 0;
% for p = 1:T1
%     a = abs(EXP.History.Pose(p,1:2) - EXP.Target_points)< 0.1;
%     indx = find(sum(a) == 2);
%     a(indx,:) = [];
%     if length(indx) >= 1
%         fitness = fitness + 1;
%     end
% end

%======
EXP.Elapsed_time=toc;
%fprintf(EXP.Exp_over_msg);  % print the "experiment over" message
OUTPUT_DATA=orderfields(EXP); % sort and return output data

% calculate final fitness w.r.t. all target points and speed to collect
base = EXP.total_points/EXP.Stop_time;
f1 = (EXP.total_points-fitness)/EXP.total_points;
f2 = (base - fitness/T1)/base;
error = 1*f1;% + 0*(1-f2);
%error = (config.num_target_points-fitness)/config.num_target_points;%-sum(dist);%1 - sum(dist)/T1;

individual.train_error = error;
individual.val_error = error;
individual.test_error = error;

end
%========================================================================
%============================  END MAIN  ================================
%========================================================================


%==============================
%== Simulator Main Functions ==
%==============================

function EXP=Run_Functions(EXP,idx)
% Run functions with predefined names (if exist)
for i=1:length(EXP.Addons)
    fz_name=char(strcat(EXP.Addons(i),'_',EXP.Addons_suffix(idx)));
    addon_dir=['./',char(EXP.Addons(i))];
    function_executed=false;
    %-- Look for function in specified directory
    try
        if exist(addon_dir,'dir')
            cd(['./',char(EXP.Addons(i))]);
            if exist(fz_name,'file')
                eval(['[EXP]=',fz_name,'(EXP);']);
                function_executed=true;
            end
            cd('..');
        end
    catch ME1
        full_path=which(fz_name);
        fprintf('Error in Addon function in "%s"\n',full_path);
        rethrow(ME1);
    end
    %------
    if function_executed, continue; end
    %-- look for function in Matlab path
    try
        if ~isempty(which(fz_name)), eval(['[EXP]=',fz_name,'(EXP);']); end
    catch ME2
        full_path=which(fz_name);
        fprintf('Error in Addon function in "%s"\n',full_path);
        fprintf(['Error in Addon function "',fz_name,'"\n']);
        rethrow(ME2);
    end
    %------
end
end

function Synchronize_simulation(EXP)
% Synchronize the simulation depending on the simulation speed

if (strcmp(EXP.Animation.Playback_speed,'max')), drawnow;  return;
end
if (EXP.Animation.Playback_speed==0), pause; return; end
if (EXP.Animation.Playback_speed>0), pause(EXP.Time/EXP.Animation.Playback_speed-toc); return; end
end

function Pose=Set_initial_pose(EXP)
% Set the initial pose of robots around a circle
SHRINK_FACTOR=0.7;

N=EXP.Robots;
bounds=EXP.Bounds;
if isempty(bounds), bounds=EXP.default_bounds; end
cx=(bounds(2)+bounds(1))/2;
cy=(bounds(4)+bounds(3))/2;
R=min([(bounds(2)-bounds(1))/2 , (bounds(4)-bounds(3))/2])*SHRINK_FACTOR;

theta=0:360/N:360; theta=theta(1:end-1);
X=cx+R*cosd(theta);
Y=cy+R*sind(theta);
theta_rad=(theta+180)*pi/180;
Pose=[X;Y;theta_rad];
end

function EXP=Compute_geometric_center(EXP)
% compute the geometric center of the robot
if EXP.Non_holonomic
    cx=EXP.Pose(1,:)-EXP.Robot.Distance_center_barycenter.*cos(EXP.Pose(3,:));
    cy=EXP.Pose(2,:)-EXP.Robot.Distance_center_barycenter.*sin(EXP.Pose(3,:));
else
    cx=EXP.Pose(1,:);
    cy=EXP.Pose(2,:);
end
EXP.Geometric_center=[cx;cy];
end

function Usat=check_saturation(EXP,U)
% Check command saturation

if (EXP.Non_holonomic)  % Non-holonomic drive
    R=EXP.Robot.Wheels_semiaxis_length;  % semi-distance between wheels
    satV=EXP.Robot.Max_linear_speed;      % saturation on linear speed for each wheel
    for k=1:EXP.Robots
        V=U(1,k);
        W=U(2,k);
        Vl=V-R*W;
        Vr=V+R*W;
        if abs(Vl)>satV, Vl=sign(Vl)*satV; end
        if abs(Vr)>satV, Vr=sign(Vr)*satV; end
        Usat(1,k)=(Vl+Vr)/2;
        Usat(2,k)=(Vr-Vl)/(2*R);
    end
else % Holonomic drive
    for k=1:EXP.Robots
        if (norm(U(:,k))>EXP.Robot.Max_linear_speed)
            Usat(:,k)=EXP.Robot.Max_linear_speed*U(:,k)/norm(U(:,k));
        else
            Usat(:,k)=U(:,k);
        end
    end
end
end

function EXP=compute_dynamics(EXP,Command,delta_T)
% Computes robots dynamics

Pose=EXP.Pose;
if (EXP.Non_holonomic)  % Non-holonomic drive
    for h=1:EXP.Robots
        x_t=Pose(1,h);
        y_t=Pose(2,h);
        theta_t=Pose(3,h);
        c=cos(theta_t);
        s=sin(theta_t);
        v=Command(1,h);
        w=Command(2,h);
        
        theta_out(h)=theta_t+w*delta_T;
        theta_out(h)=angle(exp(1i*theta_out(h)));  % manage phase wrap
        
        if (w~=0)
            x_out(h)=x_t+v./w.*(sin(theta_out(h))-sin(theta_t));
            y_out(h)=y_t+v./w.*(-cos(theta_out(h))+cos(theta_t));
        else
            x_out(h)=x_t+v*delta_T*c;
            y_out(h)=y_t+v*delta_T*s;
        end
    end
else % Holonomic drive
    for h=1:EXP.Robots
        x_out(h)=Pose(1,h)+Command(1,h)*delta_T;
        y_out(h)=Pose(2,h)+Command(2,h)*delta_T;
        %         theta_out(h)=Pose(3,h);
        theta_out=[];
    end
end

EXP.Pose=[x_out;y_out;theta_out];
end

function EXP=plot_robots(EXP,figureHandle)
persistent hpwake hfig hpb hps htitle X Y str_title P_init

N=EXP.Robots;
T=EXP.Time;
P=EXP.Pose;
P(1:2,:)=P(1:2,:);

R_big=EXP.Robot.Diameter/2;    % radius of big disk
R_small=R_big/3.5;  % radius of barycenter disk (true value is 15)
dbar=EXP.Robot.Distance_center_barycenter;   % distance of barycenter from center of big disk
circle_aus=0:0.01:2*pi+0.1;
circle=[cos(circle_aus) ; sin(circle_aus)];

colors=EXP.Animation.Colors;

%====== Figure initialization
if EXP.Time==0
    X=[]; Y=[];
    P_init=P;
    
    %close % close current figure (if any)
    hfig=figure(figureHandle);
    
    set(hfig,'Name',['Automatic Control Telelab  (ver. ' EXP.Version ')  ' EXP.Animation.Title],'NumberTitle','off');
    clf
    axis equal
    subplot(2,2,[1 2])
    switch EXP.Workspace_type
        case 0  % open space
            Pax=EXP.Pose(1:2,:);
            EXP.Animation.Axis=[min(Pax(1,:)) max(Pax(1,:)) min(Pax(2,:)) max(Pax(2,:))];
        case 1  % unbounded region
            fprintf('Warning! Workspace region not closed.\nIn the present version of MARS boundary collision has not been implemented yet.\n');
            Pax=EXP.Pose(1:2,:);
            EXP.Animation.Axis=[min(Pax(1,:)) max(Pax(1,:)) min(Pax(2,:)) max(Pax(2,:))];
            line(EXP.Workspace(:,1),EXP.Workspace(:,2),'Color','k','LineWidth',2);  % draw the polygonal workspace
        case 2  % bounded polygon
            line(EXP.Workspace(:,1),EXP.Workspace(:,2),'Color','k','LineWidth',2);  % draw the polygonal workspace
            tick=EXP.Animation.Axis_tick;  % axis rounded on tick value
            ax_old=EXP.Bounds;
            EXP.Animation.Axis=[floor(min(ax_old(1)-tick)) ceil(max(ax_old(2)+tick)) floor(min(ax_old(3)-tick)) ceil(max(ax_old(4)+tick))];
            axis(EXP.Animation.Axis);
    end
    
    if EXP.Animation.Grid
        grid on 
    else
        grid off; 
    end
    
    %-- remove axis box
    set(gca,'Box','on')
    %------
    
    hold on
    htitle=title('','Interpreter','none');
    xlabel('X [m]');
    ylabel('Y [m]');
    
    if isempty(EXP.Animation.Title)
        str_title=['   [' EXP.Filename ']'];
    else
        str_title=EXP.Animation.Title;
    end
    
    EXP=Run_Functions(EXP,3);  % run addons initialization_plot functions (index=3)
    
    for h=1:N
        hpwake(h)=plot(0,0,[EXP.Animation.Wake_style colors(h)]);
        hpb(h)=patch(0,0,colors(h),'LineStyle','none');
        hps(h)=patch(0,0,colors(h),'LineStyle','none');
    end
    
    if EXP.Animation.Show_initial_pose
        if EXP.Non_holonomic
            cx_big_circle=P_init(1,:)-dbar.*cos(P(3,:));
            cy_big_circle=P_init(2,:)-dbar.*sin(P(3,:));
        else
            cx_big_circle=P_init(1,:);
            cy_big_circle=P_init(2,:);
        end
        
        for h=1:N
            circle_big=[R_big*circle(1,:)+cx_big_circle(h) ; R_big*circle(2,:)+cy_big_circle(h)];
            circle_small=[R_small*circle(1,:)+P_init(1,h) ; R_small*circle(2,:)+P_init(2,h)];
            
            if (EXP.Animation.Show_real_shape)
                plot(circle_big(1,:),circle_big(2,:),colors(h));
                plot(circle_small(1,:),circle_small(2,:),colors(h));
            else
                plot(circle_small(1,:),circle_small(2,:),colors(h));
            end
        end
    end
    tic
end
%======

%====== Figure updating
X=[X;P(1,:)]; Y=[Y;P(2,:)];

%-- Plot wake
if EXP.Animation.Wake  
    for h=1:N 
        set(hpwake(h),'XData',X(:,h),'YData',Y(:,h)) 
    end 
end
%------

EXP=Run_Functions(EXP,4); % run addons plot functions (index=4)

%-- Plot robots
if EXP.Non_holonomic
    cx_big_circle=P(1,:)-dbar.*cos(P(3,:));
    cy_big_circle=P(2,:)-dbar.*sin(P(3,:));
else
    cx_big_circle=P(1,:);
    cy_big_circle=P(2,:);
end

for h=1:N
    circle_big=[R_big*circle(1,:)+cx_big_circle(h) ; R_big*circle(2,:)+cy_big_circle(h)];
    circle_small=[R_small*circle(1,:)+P(1,h) ; R_small*circle(2,:)+P(2,h)];
    if (EXP.Animation.Show_real_shape)
        set(hpb(h),'XData',circle_big(1,:),'YData',circle_big(2,:));
        set(hps(h),'XData',circle_small(1,:),'YData',circle_small(2,:),'FaceColor','y');
    else
        set(hps(h),'XData',circle_small(1,:),'YData',circle_small(2,:),'FaceColor',colors(h));
    end
end
%------

%-- Resize axis for unbounded workspaces
if EXP.Workspace_type~=2
    tick=EXP.Animation.Axis_tick;  % axis rounded on tick value
    ax_old=EXP.Animation.Axis;
    EXP.Animation.Axis=[floor(min([P(1,:)-tick,ax_old(1)])) ceil(max([P(1,:)+tick,ax_old(2)])) floor(min([P(2,:)-tick,ax_old(3)])) ceil(max([P(2,:)+tick,ax_old(4)]))];
    axis(EXP.Animation.Axis);
end
%------

% display other variables
switch(EXP.Filename)
    case 'explore_behaviour'
        if EXP.Time >= 1
        subplot(2,2,3)
        % points reached
        scatter(EXP.Target_points(:,1),EXP.Target_points(:,2),5)
        axis(EXP.Animation.Axis);
        
        %bar([EXP.History.Command(end,:)])
        title(strcat('Fitness = ',num2str(EXP.total_points-size(EXP.Target_points,1))))
        xlabel('Last command')
        ylabel('Obj proximity')
        
        subplot(2,2,4)
        bar([double(EXP.Agent(1).Sensor(1).Measured_distance>0).*EXP.Agent(1).Sensor(1).Measured_distance])
        xlabel('Sim step')
        ylabel('Sensor proximity angle')
        end    
        
    otherwise 
        if EXP.Time >= 1
            subplot(2,2,3)
            % points reached
            scatter(EXP.Target_points(:,1),EXP.Target_points(:,2),5)
            axis(EXP.Animation.Axis);
            
            %bar([EXP.History.Command(end,:)])
            title(strcat('Fitness = ',num2str(EXP.total_points-size(EXP.Target_points,1))))
            xlabel('target x')
            ylabel('target y')
            
            subplot(2,2,4)
            bar([double(EXP.Agent(1).Sensor(1).Measured_distance>0).*EXP.Agent(1).Sensor(1).Measured_distance])
            xlabel('Sim step')
            ylabel('Sensor proximity angle')
        end
        
end

if (strcmp(EXP.Animation.Playback_speed,'max'))
    set(htitle,'String',['T=' sprintf('%1.1f',T)   ' sec   (max speed) ' str_title]); 
    return; 
end
if (EXP.Animation.Playback_speed==0)
    set(htitle,'String',['T=' sprintf('%1.1f',T)   ' sec   (manual mode) ' str_title]); 
    return; 
end
if (EXP.Animation.Playback_speed>0)
    set(htitle,'String',['T=' sprintf('%1.1f',T)   ' sec   (' num2str(EXP.Animation.Playback_speed) 'x) ' str_title]); 
    return; 
end
%======

end


function EXP=Compute_environment(EXP)
% Determine the type of environment and set Workspace_type field (open=0, unbounded=1, bounded=2)
%-- check if the polygon defining the workspace if unbounded
if isempty(EXP.Workspace)
    EXP.Workspace_type=0; % open space
else
    if (sum(EXP.Workspace(1,:)==EXP.Workspace(end,:))~=2)
        EXP.Workspace_type=1; % unbounded region
    else
        EXP.Workspace_type=2; % bounded polygon
    end
end
%------
%-- compute outer box of the workspace
if EXP.Workspace_type>0
    EXP.Bounds=[min(EXP.Workspace(:,1)) max(EXP.Workspace(:,1)) min(EXP.Workspace(:,2)) max(EXP.Workspace(:,2))];
else
    EXP.Bounds=EXP.Default_bounds;
end
%------
end
