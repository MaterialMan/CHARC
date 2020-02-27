# matlab-maze
This function generates a random maze and it's associated result-path.

`[lines,board,hist,result] = maze(rowDim,colDim,start,stop,doPlot,printResult)`

input:

  >optional:

        rowDim: default: 14 
        colDim: default: 14
        start:  startfield of the resultpath;  default: [1,1] (down-left)
        stop:   targetfield of the resultpath; default: [rowDim, colDim] (top-right)
        doPlot: plot to new figure; default: true
        printResult: plot the result-path; default: true
> output:
  
    lines:  nx2 array, containing all lines of the maze, where a line segment (for example [0,0;1,0])
            is separated by a NaN-entry. This allows to plot the whole maze directly with 
            plot(lines(:,1),lines(:,2)) 
    board:  (2*rowDim) by 2*colDim boolean-array, where walls have a truth-value 1, free space 0
            can be inspected easyli with spy(board)
    hist:   the path of the maze-generation. Whenever e backtrack was performed, a NaN-value was insearted.
    result: the most direct path from the startpoint to the endpoint

For example, generate a 20x20 maze with associated result-path from top-left to bottom-right:

`maze(20,20,[1,20],[20,1])`
