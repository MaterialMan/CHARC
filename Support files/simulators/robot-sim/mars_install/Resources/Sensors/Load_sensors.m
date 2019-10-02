function Exp_status=Load_sensors(Exp_status)
% Load the characteristics of sensors

%-- Proximity sensor
% return true if an obstacle or a robot is within a circle around the robot
Sensor(1).Code='ProximitySensor';
Sensor(1).Description='Sensor able to detect obstacles and/or robots within a circular area around the robot.';
Sensor(1).Range=1;
Sensor(1).Show_range=true;
%------

%-- Range finder sensor (real)
Sensor(2).Code='RangeFinder';
Sensor(2).Description='Sensor implementing a laser range finder.';
Sensor(2).Range=1;  % distance range
Sensor(2).Angle_span=pi; % angle of vision
Sensor(2).Number_of_measures=181;
Sensor(2).Show_range=true;
Sensor(2).Show_beam=false;
%------

%-- Ideal range finder sensor 
Sensor(3).Code='RangeFinderIdeal';
Sensor(3).Description='Sensor implementing an ideal laser range finder, able to return the exact pose of robots inside the visibility cone.';
Sensor(3).Range=1;  % distance range
Sensor(3).Angle_span=pi; % angle of vision
Sensor(3).Show_range=true;
%------


Exp_status.Sensor=Sensor;

