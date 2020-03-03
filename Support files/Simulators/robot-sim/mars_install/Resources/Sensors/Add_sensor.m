function [Exp_status]=Add_sensor(Exp_status,n_robot,sensors)
% Add sensors to a given robot.
% n_robot denote the robot number
% sensors contains codes of sensors

%-- load sensor characteristics if needed
if (~isfield(Exp_status,'Sensor')) 
    Exp_status=Load_sensors(Exp_status); 
    Exp_status.Agent(Exp_status.Robots).Sensor=[];  % initialize sensor structure for all robots
end
%------

num_sensors=length(sensors);

for i=1:num_sensors
    code=char(sensors(i));  % sensor code
    sensor_found=false;
    id=1;
    while (~sensor_found)&&(id<=length(Exp_status.Sensor))
        if strcmp(Exp_status.Sensor(id).Code,code)
            S=Exp_status.Sensor(id);
            if (i==1), Exp_status.Agent(n_robot).Sensor=S; else Exp_status.Agent(n_robot).Sensor(i)=S; end
            sensor_found=true;
        end
        id=id+1;
    end
    if ~sensor_found
        error('Sensor "%s" not found!\nSimulation aborted!\n',code);
    end
end
end