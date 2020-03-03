
for i = 1:length(genotype)
    
    M =  nonzeros(genotype(i).w);%full(genotype(i).w);%connectWeights{1,1}
    
    s = svd(M);
    
    tmp_rank_sum = 0;
    full_rank_sum = 0;
    
    e_rank = 1;
    for j = 1:length(s)
        full_rank_sum = full_rank_sum +s(j);
        while (tmp_rank_sum < full_rank_sum * 0.99)
            tmp_rank_sum = tmp_rank_sum + s(e_rank);
            e_rank= e_rank+1;
        end
    end
    
    W_rank(i) = sum(var(M))/length(M)% + sum(var(M,0,2));%sum(pdist(M))/size(M,1)*size(M,1);%e_rank-1;
    
end

figure
scatter3(W_rank,kernel_rank, gen_rank)
xlabel('var(W)')
ylabel('KR')
zlabel('GR')

figure
scatter3(W_rank,kernel_rank, MC)
xlabel('var(W)')
ylabel('KR')
zlabel('MC')
figure
corrplot([W_rank' kernel_rank' gen_rank'],'type','Spearman')