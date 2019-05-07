function plotActivity(figureHandle,task,esnMinor,esnMajor,config, video)

[trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,...
    testInputSequence,testOutputSequence,nForgetPoints,errType] = selectDataset_Rodan(task);


[test_error,testStates,testWeights] = assessESNonTask(esnMinor,esnMajor,...
    trainInputSequence,trainOutputSequence,valInputSequence,valOutputSequence,testInputSequence,testOutputSequence,...
    nForgetPoints,config.leakOn,errType,config.resType);

%toPlot = testStates(:,1:50)'*testWeights(1,1:50);
weights = (esnMinor.inputScaling.*esnMajor.connectWeights{1,1});
predict_out = testStates*testWeights';

set(0,'currentFigure',figureHandle)
for i = 1:500%size(testStates,1)
   
    subplot(2,2,1)
    toPlot = diag(testStates(i,1:50))*weights;
    
    G = graph(toPlot,'upper');   
    B = adjacency(G);
    nn = numnodes(G);
    [s,t] = findedge(G);
    A = sparse(s,t,G.Edges.Weight,nn,nn);
    A = A + A.' - diag(diag(A));
    
    imagesc(A)
    %imagesc(testStates(i,1:50)'*testWeights(1,1:50))
    colormap(bluewhitered)
    
    subplot(2,2,2)
    h = plot(1+i:500+i,testStates(1+i:i+500,1:50)); 
    xlim([1+i i+500])
    F(i) = getframe(gcf);
    
    subplot(2,2,3)
    imagesc(testStates(i,1:50)'*testWeights(1,1:50))    
    
    subplot(2,2,4)
    plot(1+i:500+i,[predict_out(1+i:500+i) testOutputSequence(nForgetPoints+1+i:nForgetPoints+500+i)])
    xlim([1+i i+500])
    ylim([min([min(predict_out) min(testOutputSequence)])...
        max([max(predict_out) max(testOutputSequence)])])
    
    F(i) = getframe(gcf);
    drawnow
    
end

if nargin > 5
    createVid(F)
end

end
        
function createVid(F)

  % create the video writer with 1 fps
  writerObj = VideoWriter('activity_video.avi');
  writerObj.FrameRate = 50;
  % set the seconds per image
  
  % open the video writer
  open(writerObj);
  % write the frames to the video
  writeVideo(writerObj, F);
  
  % close the writer object
  close(writerObj);

end