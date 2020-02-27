function [collision, M_idx]=Check_collision(EXP)
% check if collision between robots is occurred (or is going to occur)

if EXP.Robots==1
    collision=false; 
    M_idx=0; 
    return; 
end

collision=false;
M_idx=zeros(EXP.Robots);

cx=EXP.Geometric_center(1,:);
cy=EXP.Geometric_center(2,:);

for i=1:EXP.Robots-1
    for j=i+1:EXP.Robots
        dist=norm([cx(i) ; cy(i)]-[cx(j) ; cy(j)]);
        if dist<=EXP.Robot.Diameter 
            collision=true; 
            M_idx(i,j)=1;
        end
    end
end
end