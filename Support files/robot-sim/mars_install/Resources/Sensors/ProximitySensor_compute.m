function [EXP]=ProximitySensor_compute(EXP,n_robot,n_sensor)

EXP.Agent(n_robot).Sensor(n_sensor).Presence=false;
EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots=[];
EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles=[];

%-- Compute sensor output
%-- Check robots
for i=1:EXP.Robots
    if (i~=n_robot)
        if (norm(EXP.Pose(1:2,n_robot)-EXP.Pose(1:2,i))<=EXP.Agent(n_robot).Sensor(n_sensor).Range)
            EXP.Agent(n_robot).Sensor(n_sensor).Presence=true;
            EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots=[EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots , i];
        end
    end
end
EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots=unique(EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots);
%------

%-- Check obstacles
if isfield(EXP,'Map')
    for i=1:length(EXP.Map.Obstacle)
        if (EXP.Map.Obstacle_distance(n_robot,i).Min_dist<=EXP.Agent(n_robot).Sensor(n_sensor).Range)
            EXP.Agent(n_robot).Sensor(n_sensor).Presence=true;
            EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles=[EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles , i];
        end
    end
end
%------


