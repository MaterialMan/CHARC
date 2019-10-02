function [EXP]=RangeFinder_plot(EXP,n_robot,n_sensor)

%-- Initialize handler for range plot
if (~isfield(EXP.Agent(n_robot).Sensor(n_sensor),'Plot_handler'))||(isempty(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler))
    Plot_handler=plot(0,0,'LineStyle','--','Color',EXP.Animation.Colors(n_robot));
    EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler=Plot_handler;
    for j=1:EXP.Agent(n_robot).Sensor(n_sensor).Number_of_measures
        EXP.Agent(n_robot).Sensor(n_sensor).Beam_handler(j)=plot(0,0,'LineStyle',':','Color',EXP.Animation.Colors(n_robot));
    end
end

%-- Check and plot sensor range
if EXP.Agent(n_robot).Sensor(n_sensor).Show_range
    angle_final=EXP.Pose(3,n_robot)-EXP.Agent(n_robot).Sensor(n_sensor).Measured_angle(end);
    angle_iniz=EXP.Pose(3,n_robot)-EXP.Agent(n_robot).Sensor(n_sensor).Measured_angle(1);
    t=linspace(angle_iniz,angle_final,ceil((angle_iniz-angle_final)*20));
    x = cos(t); y = sin(t);
    xd=[EXP.Pose(1,n_robot) EXP.Pose(1,n_robot)+EXP.Agent(n_robot).Sensor(n_sensor).Range*x EXP.Pose(1,n_robot)];
    yd=[EXP.Pose(2,n_robot) EXP.Pose(2,n_robot)+EXP.Agent(n_robot).Sensor(n_sensor).Range*y EXP.Pose(2,n_robot)];
    set(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler,'XData',xd,'YData',yd,'Visible','on');
else
    set(EXP.Agent(n_robot).Sensor(n_sensor).Plot_handler,'Visible','off');
end

%-- Check and plot sensor beam
if (EXP.Agent(n_robot).Sensor(n_sensor).Show_beam)
    x0=EXP.Pose(1,n_robot); y0=EXP.Pose(2,n_robot);
    for j=1:EXP.Agent(n_robot).Sensor(n_sensor).Number_of_measures
        if EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j)~=-1
            x1=x0+cos(EXP.Pose(3,n_robot)-EXP.Agent(n_robot).Sensor(n_sensor).Measured_angle(j))*EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j);
            y1=y0+sin(EXP.Pose(3,n_robot)-EXP.Agent(n_robot).Sensor(n_sensor).Measured_angle(j))*EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j);
            set(EXP.Agent(n_robot).Sensor(n_sensor).Beam_handler(j),'XData',[x0 x1],'YData',[y0 y1],'Visible','on');
        else
            set(EXP.Agent(n_robot).Sensor(n_sensor).Beam_handler(j),'XData',[],'YData',[],'Visible','on');
        end
    end
else
    for j=1:EXP.Agent(n_robot).Sensor(n_sensor).Number_of_measures
        set(EXP.Agent(n_robot).Sensor(n_sensor).Beam_handler(j),'Visible','off');
    end
end
%------
end

