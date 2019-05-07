function domination_matrix = calc_dommat(num_violations, violation_sum, objectives)

% Calculate the domination matrix using constrained-domination.
% domination_matrix(p,q)=1:  p dset q
% domination_matrix(p,q)=-1: q dset p
% domination_matrix(p,q)=0: no domination

num_individuals = size(objectives, 1);
num_objectives  = size(objectives, 2);
domination_matrix  = zeros(num_individuals, num_individuals);

for p = 1:num_individuals-1
    
    for q = p+1:num_individuals
        
        % p and q are both feasible
        if(num_violations(p) == 0 && num_violations(q)==0)
            pdomq = false;
            qdomp = false;
            for i = 1:num_objectives
                if( objectives(p, i) < objectives(q, i) )    % minimization!
                    pdomq = true;
                elseif(objectives(p, i) > objectives(q, i))
                    qdomp = true;
                end
            end
            
            if( pdomq && ~qdomp )
                domination_matrix(p, q) = 1;
            elseif(~pdomq && qdomp )
                domination_matrix(p, q) = -1;
            end
            
            % p is feasible, and q is infeasible
        elseif(num_violations(p) == 0 && num_violations(q)~=0)
            domination_matrix(p, q) = 1;
            
            % q is feasible, and p is infeasible
        elseif(num_violations(p) ~= 0 && num_violations(q)==0)
            domination_matrix(p, q) = -1;
            
            % p and q are both infeasible
        else
            if(violation_sum(p) < violation_sum(q))
                domination_matrix(p, q) = 1;
            elseif(violation_sum(p) > violation_sum(q))
                domination_matrix(p, q) = -1;
            end
        end
    end
end

domination_matrix = domination_matrix - domination_matrix';
end
