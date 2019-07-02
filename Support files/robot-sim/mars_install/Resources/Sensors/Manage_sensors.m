function Exp_status=Manage_sensors(Exp_status)
% Run computation of sensor outputs (for each sensor) and draw plot

if (~isfield(Exp_status,'Agent')), return; end

for n_robot=1:Exp_status.Robots
    for n_sensor=1:length(Exp_status.Agent(n_robot).Sensor)
        eval(['Exp_status=' Exp_status.Agent(n_robot).Sensor(n_sensor).Code '_compute(Exp_status,' num2str(n_robot) ',' num2str(n_sensor)' ');']);
        %--Run plot function if the feature is visible and animation is enabled
        if (Exp_status.Animation.Enable)&&((~isfield(Exp_status.Agent(n_robot).Sensor(n_sensor),'Visible'))||(isempty(Exp_status.Agent(n_robot).Sensor(n_sensor).Visible)||(Exp_status.Agent(n_robot).Sensor(n_sensor).Visible)))
            eval(['Exp_status=' Exp_status.Agent(n_robot).Sensor(n_sensor).Code '_plot(Exp_status,' num2str(n_robot) ',' num2str(n_sensor)' ');']);
        end
        %------
    end
end
