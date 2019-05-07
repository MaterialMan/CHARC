
function [quality,stats] = measureSearchSpace(metrics,resolution,temp)

if nargin > 2
    
    for m = 1:length(metrics)
        
        behaviours = round(metrics{m});
        metrics_cmp = behaviours;
        
        covered_space = 0; rep_behaviour =[];
        for i = 1:size(behaviours,1)
            if sum(sum(behaviours(i,:) == metrics_cmp,2) == size(behaviours,2)) < 2
                covered_space = covered_space +1;
            else
                rep_behaviour = [rep_behaviour; behaviours(i,:)];
            end
        end
        
        num_orig_rep_behaviour = unique(rep_behaviour,'rows');
        
        quality(m) = covered_space + size(num_orig_rep_behaviour,1);
        
        %% collect additional stats
        for i = 1:size(behaviours,2)
            stats(:,i) = [iqr(behaviours(:,i)),mad(behaviours(:,i)),range(behaviours(:,i)),std(behaviours(:,i)),var(behaviours(:,i))];
        end
        
    end
else
    
    % minimise or grow the voxel size using the resolution parameter
    metrics = round(metrics/resolution)*resolution;
    
    metrics_cmp = metrics;
    
    voxels_occupied = 0; rep_behaviour =[];
    for i = 1:size(metrics,1)
        if sum(sum(metrics(i,:) == metrics_cmp,2) == size(metrics,2)) < 2
            voxels_occupied = voxels_occupied +1;
        else
            rep_behaviour = [rep_behaviour; metrics(i,:)];
        end
    end
    
    num_orig_rep_behaviour = unique(rep_behaviour,'rows');
    
    voxels_occupied = voxels_occupied + size(num_orig_rep_behaviour,1);
    
    %% collect additional stats
    for i = 1:size(metrics,2)
        stats(:,i) = [iqr(metrics(:,i)),mad(metrics(:,i)),range(metrics(:,i)),std(metrics(:,i)),var(metrics(:,i))];
    end
    
    quality = voxels_occupied;% * sum(std(metrics));
    
end

% if nargin > 2
%
%     for m = 1:length(metrics)
%
%         met = metrics{m};
%         divSize = spaceSize(m);
%         met(:,1:2) = (met(:,1:2)/divSize)*100;
%         met(:,3) = (met(:,3)/100)*100;
%
%         space = zeros(100,100,100);
%         for i = 1:size(met,1)
%             tmp = round(met(i,:))+1;
%             space(tmp(1),tmp(2),tmp(3)) = 1;
%         end
%         covered = sum(sum(sum(space)));
%
%         %total_space_covered(m) = covered/100^3;
%     end
% else
%     for m = 1:length(metrics)
%
%         met = metrics{m};
%
%         space = zeros(100,100,spaceSize(m));
%         space_cnt = zeros(101,101,spaceSize(m)+1);
%         for i = 1:size(met,1)
%             tmp(1:2) = round(met(i,1:2)*100)+1;
%             tmp(3) = round(met(i,3))+1;
%             space(tmp(1),tmp(2),tmp(3)) = 1;
%             space_cnt(tmp(1),tmp(2),tmp(3)) = space_cnt(tmp(1),tmp(2),tmp(3))+1;
%         end
%         covered = sum(sum(sum(space)));
%
%         %total_space_covered(m) = covered;
%
%     end
% end
%
%
%
%
