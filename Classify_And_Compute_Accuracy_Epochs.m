function [ClassifiedSleepStage,accuracy] = Classify_And_Compute_Accuracy_Epochs(epochs,sleepStages, Forest, fs, Wavelet)
%Ryan Byrne
%Function takes in testing set and classifies the epochs and calculates the
%performance of the model

%Number of full night recordings
numSubjects= numel(epochs);

%Get the total number of epochs between all files
total_epochs = 0;
for i = 1:numSubjects
    numEF = numel(epochs{i});
    total_epochs = total_epochs + numEF;
end

%Create variable for storing classified stages 
ClassifiedSleepStage = strings(1, total_epochs);

%Create variable for storing hypnogram stages for comparison
Hynpo_SleepStage = strings(1, total_epochs);

ind = 1;
%For each file classify test epoch
for i=1:numSubjects

    %Index subjects epochs and hypnogram classes
    Subject_Epoch = epochs{i};
    Subject_Stages = sleepStages{i};
    numEF = numel(epochs{i});
    
    %For each epoch classify using model and index hypogram sleepstage
    for j=1:numEF
        %Run function to classify epoch
        ClassifiedSleepStage(ind) = Classify_Epoch(Forest,Subject_Epoch{j}, fs, Wavelet);
        Hynpo_SleepStage(ind) = Subject_Stages{j};
        ind = ind + 1;
    end
end

%Find total number of each stage
cellSleepStage = cellstr(Hynpo_SleepStage);
uniqueStages={'W', '1', '2', '3', 'R'};
Tot_counts=cellfun(@(x) sum(ismember(cellSleepStage,x)),uniqueStages,'un',0);

%Store correct guesses between stages and total of all stages
correct_Tot = 0;
correct_W = 0;
correct_1 = 0;
correct_2 = 0;
correct_3 = 0;
correct_R = 0;

%Iterate through classified stages and increase correctly identified count
%for each sleep stage and total
for n = 1:total_epochs
    if (ClassifiedSleepStage(n) == Hynpo_SleepStage(n))
        correct_Tot = correct_Tot + 1;
        if (ClassifiedSleepStage(n) == 'W')
            correct_W = correct_W + 1;
        elseif (ClassifiedSleepStage(n) == '1')
            correct_1 = correct_1 + 1;
        elseif (ClassifiedSleepStage(n) == '2')
            correct_2 = correct_2 + 1;
        elseif (ClassifiedSleepStage(n) == '3')
            correct_3 = correct_3   + 1;
        elseif (ClassifiedSleepStage(n) == 'R')
            correct_R = correct_R + 1;
        end
    end
end

% Compute accuracy for total and for each stage
totalaccuracy = correct_Tot/total_epochs;
total_W = correct_W/Tot_counts{1};
total_1 = correct_1/Tot_counts{2};
total_2 = correct_2/Tot_counts{3};
total_3 = correct_3/Tot_counts{4};
total_R = correct_R/Tot_counts{5};

%Return accuracies
accuracy = [totalaccuracy, total_W, total_1, total_2, total_3, total_R];

end