
function G = createLattice(N,type,self_loop,num_ensemble)

    grid = zeros(N*N);
    
    switch(type)
        case 'basicLattice'
            % version 1
            for i = 1:N*N
                for j = 1:N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                end
            end
            G = graph(grid);
            %plot(G,'Layout','force')
            
        case 'partialLattice'
            % version 2
            for i = 1:N*N
                for j = 1:N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                    if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                end
            end
            G = graph(grid);
            %plot(G)
            
        case 'fullLattice'
            %version 3
            for i = 1:N*N
                for j = 1:N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                    if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                        grid(i,j) = 1;
                    end
                end
            end
            G = graph(grid);
            %plot(G,'Layout','force3')
            
        case 'ensembleLattice'
            grid = [];
            for ensnemble = 1:num_ensemble
                for i = (ensnemble-1)*N*N+1:ensnemble*N*N
                    for j = (ensnemble-1)*N*N+1:ensnemble*N*N
                        if self_loop % add self loop
                            if i == j
                                grid(i,j) = 1;
                            end
                        end
                        if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N || i+N == j)
                            grid(i,j) = 1;
                        end
                        if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                    end
                end
            end
            G = graph(grid);
            
        case 'basicCube'
            grid = zeros(N*N*N);
            % version 1
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                    if (i == j+N*N || i+N*N == j)
                        grid(i,j) = 1;
                    end
                end
            end
            
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if any((i > (1:N)*N*N-N & i <= (1:N)*N*N) & (j > (1:N)*N*N & j <= (1:N)*N*N+N))
                        grid(i,j) = 0;
                        grid(j,i) = 0;
                    end
                end
            end
            G = graph(grid);
            %plot(G,'Layout','subspace3')
            
        case 'partialCube'
            
            grid = zeros(N*N*N);
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                    if (i == j+N*N || i+N*N == j)
                        grid(i,j) = 1;
                    end
                    
                    %additionals
                    if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                        grid(i,j) = 1;
                    end
                    
                    if (i == j+N*N+1 && sign(mod(j,N))) || (i+N*N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N*N-1 && sign(mod(j-1,N))) || (i+N*N-1 == j && sign(mod(i-1,N)))
                        grid(i,j) = 1;
                    end
                end
            end
            
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if any((i > (1:N)*N*N-N & i <= (1:N)*N*N) & (j > (1:N)*N*N & j <= (1:N)*N*N+N))
                        grid(i,j) = 0;
                        grid(j,i) = 0;
                    end
                end
            end
            G = graph(grid);
            %plot(G,'Layout','subspace3')
            
        case 'fullCube'
            
            grid = zeros(N*N*N);
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if self_loop % add self loop
                        if i == j
                            grid(i,j) = 1;
                        end
                    end
                    
                    if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    
                    if (i == j+N || i+N == j)
                        grid(i,j) = 1;
                    end
                    
                    if (i == j+N*N || i+N*N == j)
                        grid(i,j) = 1;
                    end
                    
                    % - additionals
                    if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                        grid(i,j) = 1;
                    end
                    
                    %y
                    if (i == j+N*N+1 && sign(mod(j,N))) || (i+N*N+1 == j && sign(mod(i,N)))
                        grid(i,j) = 1;
                    end
                    if (i == j+N*N-1 && sign(mod(j-1,N))) || (i+N*N-1 == j && sign(mod(i-1,N)))
                        grid(i,j) = 1;
                    end
                    
                    % z
                    for k = 1:N-1
                        st = (k-1)*(N.^2);
                        ed = (k-1)*(N.^2)+N*(N-1);
                        
                        if j == i+N*(N+1) && i > st && i <= ed %messed here
                            grid(i,j) = 1;
                            grid(j,i) = 1;
                        end
                        
                        if j == i+N*(N-1) && i > st+N && i <= ed+N %messed here
                            grid(i,j) = 1;
                            grid(j,i) = 1;
                        end
                    end
                    
                end
            end
            
            for i = 1:N*N*N
                for j = 1:N*N*N
                    if any((i > (1:N)*N*N-N & i <= (1:N)*N*N) & (j > (1:N)*N*N & j <= (1:N)*N*N+N))
                        grid(i,j) = 0;
                        grid(j,i) = 0;
                    end
                end
            end
            G = graph(grid);
            %plot(G,'Layout','force3')
            
        case 'ensembleCube'
            %grid = zeros(N*N*N);
            grid = [];
            for ensemble = 1:num_ensemble
                for i = (ensemble-1)*N*N*N+1:N*N*N*ensemble
                    for j = (ensemble-1)*N*N*N+1:N*N*N*ensemble
                        if self_loop % add self loop
                            if i == j
                                grid(i,j) = 1;
                            end
                        end
                        
                        if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        
                        if (i == j+N || i+N == j)
                            grid(i,j) = 1;
                        end
                        
                        if (i == j+N*N || i+N*N == j)
                            grid(i,j) = 1;
                        end
                        
                        % - additionals
                        if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                        
                        %y
                        if (i == j+N*N+1 && sign(mod(j,N))) || (i+N*N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N*N-1 && sign(mod(j-1,N))) || (i+N*N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                        
                        % z
                        for k = 1:N-1
                            st = (k-1)*(N.^2);
                            ed = (k-1)*(N.^2)+N*(N-1);
                            
                            if j == i+N*(N+1) && i > st && i <= ed %messed here
                                grid(i,j) = 1;
                                grid(j,i) = 1;
                            end
                            
                            if j == i+N*(N-1) && i > st+N && i <= ed+N %messed here
                                grid(i,j) = 1;
                                grid(j,i) = 1;
                            end
                        end
                        
                    end
                end
                
                for i = (ensemble-1)*N*N*N+1:N*N*N*ensemble
                    for j = (ensemble-1)*N*N*N+1:N*N*N*ensemble
                        if any((i > (1:N)*N*N-N & i <= (1:N)*N*N) & (j > (1:N)*N*N & j <= (1:N)*N*N+N))
                            grid(i,j) = 0;
                            grid(j,i) = 0;
                        end
                    end
                end
            end
            
            G = graph(grid);
            
        case 'ensembleShape'
            
            grid = [];
            
            for ensemble = 1:num_ensemble
                for i = (ensemble-1)*N*N+1:ensemble*N*N
                    for j = (ensemble-1)*N*N+1:ensemble*N*N
                        if self_loop % add self loop
                            if i == j
                                grid(i,j) = 1;
                            end
                        end
                        if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N || i+N == j)
                            grid(i,j) = 1;
                        end
                        if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                    end
                end
            end
            
            last_i = i;
            
            for ensemble2 = 1:num_ensemble
                for i = (ensemble2-1)*N*N*N+last_i+1:N*N*N*ensemble2+last_i
                    for j = (ensemble2-1)*N*N*N+last_i+1:N*N*N*ensemble2+last_i
                        if self_loop % add self loop
                            if i == j
                                grid(i,j) = 1;
                            end
                        end
                        
                        if (i == j+1 && sign(mod(j,N))) || (i+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        
                        if (i == j+N || i+N == j)
                            grid(i,j) = 1;
                        end
                        
                        if (i == j+N*N || i+N*N == j)
                            grid(i,j) = 1;
                        end
                        
                        % - additionals
                        if (i == j+N+1 && sign(mod(j,N))) || (i+N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N-1 && sign(mod(j-1,N))) || (i+N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                        
                        %y
                        if (i == j+N*N+1 && sign(mod(j,N))) || (i+N*N+1 == j && sign(mod(i,N)))
                            grid(i,j) = 1;
                        end
                        if (i == j+N*N-1 && sign(mod(j-1,N))) || (i+N*N-1 == j && sign(mod(i-1,N)))
                            grid(i,j) = 1;
                        end
                        
                        % z
                        for k = 1:N-1
                            st = (k-1)*(N.^2);
                            ed = (k-1)*(N.^2)+N*(N-1);
                            
                            if j == i+N*(N+1) && i > st && i <= ed %messed here
                                grid(i,j) = 1;
                                grid(j,i) = 1;
                            end
                            
                            if j == i+N*(N-1) && i > st+N && i <= ed+N %messed here
                                grid(i,j) = 1;
                                grid(j,i) = 1;
                            end
                        end
                        
                    end
                end
                
                for i = (ensemble2-1)*N*N*N+last_i+1:N*N*N*ensemble2+last_i
                    for j = (ensemble2-1)*N*N*N+last_i+1:N*N*N*ensemble2+last_i
                        if any((i > (1:N)*N*N-N & i <= (1:N)*N*N) & (j > (1:N)*N*N & j <= (1:N)*N*N+N))
                            grid(i,j) = 0;
                            grid(j,i) = 0;
                        end
                    end
                end
            end
            
            G = graph(grid);
            
    end
    


