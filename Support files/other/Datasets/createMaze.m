
function [lines,board,hist,result] = createMaze(rowDim,colDim,start,stop,doPlot,printResult)
% MAZE  generates a random maze
% input:
%   optional:
%         rowDim: default: 14 
%         colDim: default: 14
%         start:  startfield of the resultpath;  default: [1,1]
%         stop:   targetfield of the resultpath; default: [rowDim,colDim]
%         doPlot: plot to new figure; default: true
%         printResult: plot the result-path; default: true
% output: lines:  nx2 array, containing all lines of the maze, where a line segment (for example [0,0;1,0])
%                 is separated by a NaN-entry. This allows to plot the whole maze directly with
%                 plot(lines(:,1),lines(:,2))
%         board:  (2*rowDim) by 2*colDim boolean-array, where walls have a truth-value 1, free space 0
%                 can be inspected easyli with spy(board)
%         hist:   the path of the maze-generation. Whenever e backtrack was performed, a NaN-value was insearted.
%         result: the most direct path from the startpoint to the endpoint
% written by Balthasar Hofer
% lebalz@outlook.com
% 01/03/2017
  
  % standard values
  if nargin<2
    rowDim = 14;
    colDim = 14;
  end
  if nargin < 4
    start = [1,1];
    stop = [rowDim,colDim];
  end
  if nargin<5
    doPlot = true;
  end
  if nargin<6
    printResult = true;
  end

  isUsed = false(rowDim,colDim);        %is field already visited/used?
  board = true(2*rowDim+1,2*colDim+1);  %
  pos = [1,1];                    %current lookup pos
  isUsed(pos(1),pos(2))=true;    
  hist = zeros(0,2);              %visit-history
  histPos = 0;                    %backtrack position
  stackCntr = 0;                  %matlab restricts the number of recursive
                                  %calls to a platform-dependent size. To
                                  %prevent from overflows, keep track of
                                  %stack-deepness

  NEIGHBOURS = [...               %relative indexes for neighbour lookup
    0 , 1;...
    1 , 0;...
    0 ,-1;...
    -1, 0];

  % create random maze
  finished = next_iteration();
  while ~finished
    stackCntr = 0;
    finished=next_iteration();
  end
  
  % traverse history and set neighbour-fields
  h = hist;
  indx = 1:size(hist,1);
  
  %replace nan with current field --> no connected fields here
  h(indx(isnan(h(:,1))),:) = h(indx(isnan(h(:,1)))-1,:);

  %connected fields relative to curr pos
  conFieldInd = diff([h(:,1),h(:,2)]);
  conFieldInd = [conFieldInd;0,0];
  c = 1;
  
  % set walls on board
  for p = hist'
    if ~isnan(p(1))
      board(2*p(1),2*p(2)) = false;
      board(2*p(1)+conFieldInd(c,1),2*p(2)+conFieldInd(c,2)) = false;
    end
    c = c + 1;
  end

  % drawing lines
  lines = [];
  for j = 1:2:2*rowDim
    for k = 1:2:2*colDim
      if board(j,k)
        if sum(board(j,k:k+2))==3
          lines = [lines;j/2,k/2; j/2,k/2+1;NaN(1,2)];
        end
        if sum(board(j:j+2,k))==3
          lines = [lines;j/2,k/2; j/2+1,k/2;NaN(1,2)];
        end
      end
    end
  end
  
  % add boarder
  lines = [lines;...
    rowDim+0.5,0.5;...
    rowDim+0.5,colDim+0.5;...
    NaN,NaN;...
    rowDim+0.5,colDim+0.5;...
    0.5,colDim+0.5;...
    NaN,NaN;];
  lines = lines - 0.5;
  hist = hist - 0.5;
  
  % scale to 1
  lines = [lines(:,1)./rowDim,lines(:,2)./colDim];
  hist = [hist(:,1)./rowDim,hist(:,2)./colDim];
  result = get_result_path(start,stop);
  
  if doPlot
    fh = figure('Name',sprintf('Random Maze %d by %d', rowDim,colDim),'Toolbar','none','Menubar','none');
    pos = get(fh,'Position');
    xscale = rowDim/colDim;
    set(fh,'Position',[pos(1),pos(2)-pos(3)+pos(4),xscale*pos(3),pos(3)]),
    plot(rowDim*lines(:,1),colDim*lines(:,2));    
    if printResult
      hold on
      set(gca,'XTick',[],'YTick',[],'Position',[0.015,0.015,0.97,0.97],'YLim',[0,colDim],'XLim',[0,rowDim]);
      plot(rowDim*result(:,1),colDim*result(:,2),'r');
      plot(rowDim*result(end,1),colDim*result(end,2),'og','MarkerFaceColor','g');
      plot(rowDim*result(1,1),colDim*result(1,2),'or','MarkerFaceColor','r');
      hold off
    end
  end
  
  function finished = next_iteration()
    stackCntr = stackCntr + 1;
    if stackCntr == 200
      finished = false;
      return;
    end
    ind = 1:4;
    poss = NEIGHBOURS + repmat(pos,4,1);
    poss(ind(poss(:,1)<1|poss(:,1)>rowDim),:)=NaN;
    poss(ind(poss(:,2)<1|poss(:,2)>colDim),:)=NaN;
    isfree = false(1,4);
    for i = 1:4
      if ~isnan(poss(i,1))
        isfree(i) = ~isUsed(poss(i,1),poss(i,2));
      end
    end
    if sum(isfree)==0
      if histPos > 1
        if histPos == size(hist,1)
          hist = [hist;pos];
          hist = [hist;NaN(1,2)];
        end
        histPos = histPos - 1;
        pos = hist(histPos,:);
      else
        finished = true;
        return;
      end
    else
      hist = [hist;pos];
      histPos = size(hist,1);
      next = randi([1,4]);
      while ~isfree(next)
        next = randi([1,4]);
      end
      pos = poss(next,:);
      isUsed(pos(1),pos(2))=true;
    end
    finished = next_iteration();
  end

  function resPath = get_result_path(startPoint,endPoint)
    if nargin < 2
      startPoint = [1,1];
      endPoint = [rowDim,colDim];
    end
    startPoint = startPoint - [0.5,0.5];
    endPoint = endPoint - [0.5,0.5];
    startPoint = startPoint./[rowDim,colDim];
    endPoint = endPoint./[rowDim,colDim];
    hist_p = get_flattend_path(hist);
    startInd = find((startPoint(1,1)==hist_p(:,1)) & (startPoint(1,2)==hist_p(:,2)),1,'last');
    endInd = find((endPoint(1,1)==hist_p(:,1)) & (endPoint(1,2)==hist_p(:,2)),1,'first');
    
    flag = startInd > endInd;
    if flag
      t = startInd;
      startInd = endInd;
      endInd = t;
    end
    resPath = hist_p(startInd:endInd,:);
    if flag
      resPath=flipud(resPath);
    end
    i = 1;
    toDelInds = false(size(resPath,1),1);
    while i <= size(resPath,1)
      idPoints = (resPath(i,1)==resPath(1:i,1)) & (resPath(i,2)==resPath(1:i,2));
      if sum(idPoints)>1
        toDel = find(idPoints);
        toDelInds(toDel(end-1)+1:toDel(end)) = true;
        i = toDel(end);
      end
      i = i + 1;
    end
    resPath(toDelInds,:) = [];
  end

  function flatPath = get_flattend_path(path)
    ind = 1:size(path,1);
    nan_ind = ind(isnan(path(:,1)));
    flatPath = path(1:nan_ind(1)-1,:);
    for i = 1:size(nan_ind,2)-1
      next_val = path(nan_ind(i)+1,:);
      if ~isnan(next_val(1))
        id_p = (next_val(1)==flatPath(:,1)) & (next_val(2)==flatPath(:,2));
        ip = find(id_p);
        flatPath = [flatPath(1:ip-1,:);...
          path(nan_ind(i)+1:nan_ind(i+1)-1,:);...
          flipud(path(nan_ind(i)+1:nan_ind(i+1)-1,:));...
          flatPath(ip:end,:)];
      end
    end
  end
end