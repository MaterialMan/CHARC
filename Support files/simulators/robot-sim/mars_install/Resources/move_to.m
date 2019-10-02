function [Command]=move_to(Exp_status,P,desired_pose,gain)
% Implement the algorithm reported in
% Cortes, J., Martynez, S., Karatas, T., and Bullo, F. [2004]
% Coverage control for mobile sensing networks, IEEE Transactions on Robotics and Automation, 20(2), 243–255.
% with some changes

max_speed=Exp_status.Robot.Max_linear_speed;

% Move the robot to a desired position
Q=P(1:2)-desired_pose(1:2);
theta=wrapToPi(P(3));
s=sin(theta);
c=cos(theta);
SC=[-s c];
CS=[c s];

% if (gain>1/pi), gain=1/pi; end  % reduce gain if greater than (1/pi)  (see book Bullo, Cortes, Martinez, "Distributed Control of Robotic Networks")
if abs(gain*(CS*Q))>max_speed, gain=abs(max_speed/(CS*Q)); end % reduce gain if v exceeds limits

%-- Control law
v=-gain*(CS*Q);               % Linear speed
w=2*gain*atan((SC*Q)/(CS*Q)); % Angular speed
if (v==0), w=0; end
%------

%if abs(Q(1))<0.02 && abs(Q(2))<0.02, v=0; w=0;end %Stop if target is near (<2mm)
Command=[v;w]; % Update Command
%------
end