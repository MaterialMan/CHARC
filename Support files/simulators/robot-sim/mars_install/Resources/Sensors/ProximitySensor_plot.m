function [EXP]=ProximitySensor_plot(EXP,n_robot,n_sensor)

if (~isfield(EXP.Agent(n_robot).Sensor(n_sensor),'Plot_handler'))||(isempty(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler))
    Plot_handler=plot(0,0,'LineStyle',':','Color',EXP.Animation.Colors(n_robot));
    EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler=Plot_handler;
end

Sensor=EXP.Agent(n_robot).Sensor(n_sensor);
Plot_handler=Sensor.Plot_handler;
pose=EXP.Pose(:,n_robot);
Range=Sensor.Range;

if EXP.Agent(n_robot).Sensor(n_sensor).Show_range
    t = 0:0.1:2*pi+0.1; x = cos(t); y = sin(t);
    set(Plot_handler,'XData',pose(1)+Range*x,'YData',pose(2)+Range*y,'Visible','on');
else
    set(Plot_handler,'Visible','off');
end
end

