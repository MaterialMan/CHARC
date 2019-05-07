function plotAEWeights(figure1,figure2,inputSequence,genotype,config)

%vis params
sample.VisualizationDimensions(1) = 28; %imageHeight
sample.VisualizationDimensions(2)= 28;
sample.visualizationDimensions(3)= 2;

set(0,'currentFigure',figure1)
switch(config.resType)
    case 'Graph'
        sample.EncoderWeights = full(genotype.w_in.*genotype.inputScaling)'; % N by U
     case 'BZ'
          sample.EncoderWeights = full(genotype.w_in.*genotype.inputScaling)'; % N by U
    case 'DNA'
         sample.EncoderWeights = full(genotype.w_in.*genotype.inputScaling)'; % N by U
   case 'ELM'
         sample.EncoderWeights = full(genotype.connectWeights{1,1}); % N by U
  
    otherwise
        sample.EncoderWeights = full(genotype.esnMinor.inputWeights(:,2:end).*genotype.esnMinor.inputScaling)'; % N by U
end

plotWeights(sample);

[~,~,outputSequence] = testReservoir(genotype,config);

set(0,'currentFigure',figure2)
subplot(3,2,1)
imagesc(reshape(inputSequence(1,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))
title('Input Data')
subplot(3,2,2)
imagesc(reshape(outputSequence(1,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))
title('Output Data')

subplot(3,2,3)
imagesc(reshape(inputSequence(100,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))
subplot(3,2,4)
imagesc(reshape(outputSequence(100,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))

subplot(3,2,5)
imagesc(reshape(inputSequence(50,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))
subplot(3,2,6)
imagesc(reshape(outputSequence(50,:),sample.VisualizationDimensions(1),sample.VisualizationDimensions(2)))
drawnow


function h = plotWeights(this)
% plotWeights   Plot a visualization of the weights for the encoder of an autoencoder

firstLayerWeights = this.EncoderWeights';
numWeightVectors = size(firstLayerWeights, 1);
imageHeight = this.VisualizationDimensions(1);
imageWidth = this.VisualizationDimensions(2);
numImageChannels = iGetNumberOfImageChannels(this.VisualizationDimensions);
maxValue = max(firstLayerWeights(:));

[numVerticalImages, numHorizontalImages] = iCalculateGalleryDimensions( ...
    imageHeight, imageWidth, numWeightVectors);
galleryHeight = (imageHeight+1)*numVerticalImages - 1;
galleryWidth = (imageWidth+1)*numHorizontalImages - 1;

if(numImageChannels == 3)
    imageToShow = repmat(maxValue, galleryHeight, galleryWidth, 3);
else
    imageToShow = repmat(maxValue, galleryHeight, galleryWidth);
end

[y, x] = ind2sub([numVerticalImages numHorizontalImages], 1:numWeightVectors);
for i = 1:numWeightVectors
    startY = (y(i)-1)*(imageHeight+1)+1;
    endY = startY + imageHeight - 1;
    startX = (x(i)-1)*(imageWidth+1)+1;
    endX = startX + imageWidth - 1;
    if(numImageChannels == 3)
        imageToShow(startY:endY , startX:endX, :) = reshape(firstLayerWeights(i,:)', imageHeight, imageWidth, 3);
    else
        imageToShow(startY:endY , startX:endX) = reshape(firstLayerWeights(i,:)', imageHeight, imageWidth);
    end
end

if(numImageChannels == 3)
    for i = 1:3
        weightImageChannel = imageToShow(:,:,i);
        imageToShow(:,:,i) = imageToShow(:,:,i) - min(weightImageChannel(:));
        imageToShow(:,:,i) = imageToShow(:,:,i)./max(weightImageChannel(:));
    end
else
    imageToShow = imageToShow - min(imageToShow(:));
    imageToShow = imageToShow./max(imageToShow(:));
end

h = imshow(imageToShow,'InitialMagnification','fit');

end

function numImageChannels = iGetNumberOfImageChannels(visualizationDimensions)
if(numel(visualizationDimensions) == 3)
    numImageChannels = visualizationDimensions(3);
else
    numImageChannels = 1;
end
end

function [numVerticalImages, numHorizontalImages] = iCalculateGalleryDimensions(...
    imageHeight, imageWidth, numberOfWeightVectors)
numVerticalImages = ceil(sqrt(numberOfWeightVectors*(imageWidth+1)/(imageHeight+1)));
numHorizontalImages = ceil(numberOfWeightVectors/numVerticalImages);
end

end
