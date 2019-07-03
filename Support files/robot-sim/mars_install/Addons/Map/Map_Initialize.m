function [Exp_status]=Map_Initialize(Exp_status)
% Compute Obstacle Grid

%-- Check if the Map field exist
if (~isfield(Exp_status,'Map'))
    Exp_status.Map.Obstacle_grid.Enable=false;
    Exp_status.Map.Obstacle_distance.Enable=false;
    Exp_status.Map.Obstacle=[];
end
%------

%-- if Obstacle_grid is disabled exit
if (isfield(Exp_status.Map,'Obstacle_grid')) && (isfield(Exp_status.Map.Obstacle_grid,'Enable')) && (Exp_status.Map.Obstacle_grid.Enable==false), 
    return, 
else
    Exp_status.Map.Obstacle_grid.Enable=true;
end
%------

%-- set Obstacle_grid resolution
if (~isfield(Exp_status.Map.Obstacle_grid,'Resolution'))
    Exp_status.Map.Obstacle_grid.Resolution=0.01; % cell size 1 centimeter (default)
end
resolution=Exp_status.Map.Obstacle_grid.Resolution;  
%------

%-- compute matrix size and offset
lenx=(Exp_status.Bounds(2)-Exp_status.Bounds(1))/resolution;
leny=(Exp_status.Bounds(4)-Exp_status.Bounds(3))/resolution;
M_offset=Exp_status.Bounds([1,3])';
M_grid=zeros(leny,lenx);
%------

%-- fill in matrix elements cycling for each obstacle
V=Exp_status.Map.Obstacle;
for k=1:length(V)
    V(k).Vertex(:,1)=(V(k).Vertex(:,1)-M_offset(1))/resolution;
    V(k).Vertex(:,2)=(V(k).Vertex(:,2)-M_offset(2))/resolution;
    x=V(k).Vertex(:,1);
    y=V(k).Vertex(:,2);
    M_grid_temp=poly2mask(x,leny-y,leny,lenx);
    M_grid=max(M_grid,k*M_grid_temp);
end
%------

Exp_status.Map.Obstacle_grid.Grid=M_grid;
Exp_status.Map.Obstacle_grid.Offset=M_offset;

[Exp_status]=Map_Loop(Exp_status);  % Run Map_loop to compute initial distances
end
