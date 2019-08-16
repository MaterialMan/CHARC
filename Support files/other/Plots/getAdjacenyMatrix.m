function W = getAdjacenyMatrix(individual,res_indx,config)

W = sparse(individual.nodes(res_indx),individual.nodes(res_indx));
source_nodes = repmat(1:individual.nodes(res_indx),config.k,1);
source_nodes = source_nodes(:);

G_in = [individual.RBN_node{res_indx}.input];

for i = 1:length(source_nodes)
    W(source_nodes(i),G_in(i)) = 1;
end

