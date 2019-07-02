function [collision, M_idx]=Check_Obs_collision(EXP)
% check if collision between robots and objects

collision=false;

if isfield(EXP,'Map')&& isfield(EXP.Map,'Obstacle_distance')
    for s=1:length(EXP.Map.Obstacle)  % ciclo sugli ostacoli
        if abs(EXP.Map.Obstacle_distance(s).Min_dist) < 0.1
            collision=true;
        end
    end
end

end