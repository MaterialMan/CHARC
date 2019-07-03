function [EXP]=RangeFinderIdeal_plot(EXP,n_robot,n_sensor)

arc_resolution=20;  % resolution for drawing the arc of circonference

%-- Initialize handler for range plot
if (~isfield(EXP.Agent(n_robot).Sensor(n_sensor),'Plot_handler'))||(isempty(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler))
    Plot_handler=plot(0,0,'LineStyle','--','Color',EXP.Animation.Colors(n_robot));
    EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler=Plot_handler;
    for j=1:EXP.Agent(n_robot).Sensor(n_sensor).Number_of_measures
        EXP.Agent(n_robot).Sensor(n_sensor).Beam_handler(j)=plot(0,0,'LineStyle',':','Color',EXP.Animation.Colors(n_robot));
    end
end
%------

%-- Check and plot sensor range
if EXP.Agent(n_robot).Sensor(n_sensor).Show_range
    angle_final=EXP.Pose(3,n_robot)-EXP.Agent(n_robot).Sensor(n_sensor).Angle_span/2;
    angle_iniz=EXP.Pose(3,n_robot)+EXP.Agent(n_robot).Sensor(n_sensor).Angle_span/2;
    t=linspace(angle_iniz,angle_final,ceil((angle_iniz-angle_final)*arc_resolution));
    x = cos(t); y = sin(t);
    xd=[EXP.Pose(1,n_robot) EXP.Pose(1,n_robot)+EXP.Agent(n_robot).Sensor(n_sensor).Range*x EXP.Pose(1,n_robot)];
    yd=[EXP.Pose(2,n_robot) EXP.Pose(2,n_robot)+EXP.Agent(n_robot).Sensor(n_sensor).Range*y EXP.Pose(2,n_robot)];
    set(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler,'XData',xd,'YData',yd,'Visible','on');
else
    set(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler,'Visible','off');
end
%------
end

