function [EXP]=RangeFinderIdeal_compute(EXP,n_robot,n_sensor)

EXP.Agent(n_robot).Sensor(n_sensor).Presence=false;
EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots=[];
EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles=[];

range=EXP.Agent(n_robot).Sensor(n_sensor).Range;

%-- Compute sensor output
%-- Check robots
idx=0;
for i=1:EXP.Robots  % for all robots
    if (i~=n_robot)
        distance=norm(EXP.Pose(1:2,i)-EXP.Pose(1:2,n_robot));
        if (distance<=range)  % check if robot inside distance range
            target_angle=atan2(EXP.Pose(2,i)-EXP.Pose(2,n_robot),EXP.Pose(1,i)-EXP.Pose(1,n_robot));
            diff_angle=wrapToPi(target_angle-EXP.Pose(3,n_robot));
            if (abs(diff_angle)<=EXP.Agent(n_robot).Sensor(n_sensor).Angle_span/2)   % check if robot inside cone
                idx=idx+1;
                EXP.Agent(n_robot).Sensor(n_sensor).Presence=true;
                EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots(idx).Index=i;
                EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots(idx).Distance=distance;
                EXP.Agent(n_robot).Sensor(n_sensor).Detected_robots(idx).Angular_distance=diff_angle;
            end
        end
    end
end

% %-- Check obstacles (TO BE CHECKED]
% if isfield(EXP,'Map')&& isfield(EXP.Map,'Obstacle_distance')
%     warning off MATLAB:nearlySingularMatrix
%     for s=1:length(EXP.Map.Obstacle)  % ciclo sugli ostacoli
%         if EXP.Map.Obstacle_distance(n_robot,s).Min_dist<=range % controllo che l'ostacolo sia dentro il range
%             V=[EXP.Map.Obstacle(s).Vertex; EXP.Map.Obstacle(s).Vertex(1,1:2)];  % aggiungo il primo vertice alla fine
%             for k=1:length(V)-1 % ciclo sui lati dell'ostacolo
%                 x2=V(k,1);
%                 x3=V(k+1,1);
%                 y2=V(k,2);
%                 y3=V(k+1,2);
%                 for j=1:Number_of_measures % ciclo sull'angolo
%                     A=[cos(a0-G(j)), -(x3-x2); sin(a0-G(j)), -(y3-y2)];
%                     B=[x2-x0; y2-y0];
%                     X=A\B;
%                     t=X(1);
%                     fi=X(2);
%                     if (0<=t)&&(t<=range)&&(0<=fi)&&(fi<=1)
%                         distanza=t;
%                         %-- controllo se aggiornare la distanza
%                         if (distanza<=range)&&((EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j)>distanza)||(EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j)==-1))
%                             EXP.Agent(n_robot).Sensor(n_sensor).Presence=true;  % segnalo presenza di qualcosa nel campo visivo
%                             EXP.Agent(n_robot).Sensor(n_sensor).Measured_distance(j)=distanza;
%                             EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles=[EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles , s];
%                         end
%                     end
%                 end
%             end
%         end
%     end
%     warning on MATLAB:nearlySingularMatrix
% end
% EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles=unique(EXP.Agent(n_robot).Sensor(n_sensor).Detected_obstacles);
% %------
end