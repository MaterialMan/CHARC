%% Japanese Vowels:
% - 9 speakers, 30 utterances with times series length 7-29
function [Train_jap_vowels,train_outputSequence,Test_jap_vowels,test_outputSequence] = readJapVowels()

load('Datasets/JapaneseVowels/Train_Jap_vowels.mat');
load('Datasets/JapaneseVowels/Test_Jap_vowels.mat');
load('Datasets/JapaneseVowels/blockNo.mat');

%load training set
fileID = fopen('train.txt');
formatSpec = '%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f';
block = 1;
while ~feof(fileID)
    train(block,:)= textscan(fileID,formatSpec,'HeaderLines', 1,'Delimiter','\t');
    block = block+1;
end
fclose(fileID);

%load test set
fileID = fopen('test.txt');
formatSpec = '%.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f';
block = 1;
while ~feof(fileID)
    test(block,:)= textscan(fileID,formatSpec,'HeaderLines', 1,'Delimiter','\t');
    block = block+1;
end
fclose(fileID);


% Create train Output data
for i = 1:270
    a = cell2mat(train(i,:));
    listTrain(i)=size(a,1);
end

endsep =0;
endlist =0;
for i = 1:9
    startlist = endlist + 1;
    endlist = startlist-1 + blockNo(1,i);
    speakerTrain(i)=sum(listTrain(startlist:endlist));
    
    start = endsep + 1;
    endsep = start-1 + speakerTrain(i);
    train_outputSequence(start:endsep,i) = 1;
end

% Create test Output data
for i = 1:370
    b = cell2mat(test(i,:));
    listTest(i)=size(b,1);
end

endsep =0;
endlist =0;
for i = 1:9
    startlist = endlist + 1;
    endlist = startlist-1 + blockNo(2,i);
    speakerTest(i)=sum(listTest(startlist:endlist));
    
    start = endsep + 1;
    endsep = start-1 + speakerTest(i);
    test_outputSequence(start:endsep,i) = 1;
end


%%

