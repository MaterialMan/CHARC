 function D = recursiveDivision(N)
    if N>1
        M = floor(N/2);
        D = [recursiveDivision(M),M];
    else
        D = N;
    end
 end