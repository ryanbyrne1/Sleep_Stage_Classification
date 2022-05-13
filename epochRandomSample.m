function [Training_Epochs, Training_Stages, Testing_Epochs, Testing_Stages] = epochRandomSample(epochs,sleepStages)
%Ryan Byrne
%takes in all epochs and splits them between testing and training sets
%2/3 for training 1/3 for testing


%Get number of subjects
numSubjects= numel(epochs);

%Set stores for training and testing sets
Training_Epochs = cell(1, numSubjects);
Training_Stages = cell(1, numSubjects);
Testing_Epochs = cell(1, numSubjects);
Testing_Stages = cell(1, numSubjects);

%Iterate through subjects
for i=1:numSubjects

    %Get subjects epochs and sleep stages
    Subject_Epoch = epochs{i};
    Subject_Stages = sleepStages{i};
    
    %number of epochs
    numEpochs = numel(Subject_Epoch);
    
    %Set training and testing sets for subject
    Subject_Training_Epochs = cell(numEpochs , 1);
    Subject_Training_Stages = strings(numEpochs, 1);
    Subject_Testing_Epochs = cell(numEpochs , 1);
    Subject_Testing_Stages = strings(numEpochs, 1);
    
    %Iterate through epochs and set in either training or testing sets
    TrainInd = 1;
    TestInd = 1;
    for k=1:numEpochs
        %Get current epoch and sleep stage
        Epoch_Sample = Subject_Epoch{k};
        SleepStageSample = Subject_Stages(k);
        
        %Randomly pick a value 1-3
        Epoch_Sample_Group = randi([1, 3], 1);

        %if value is 2 or 3 add to training set
        if (Epoch_Sample_Group >= 2)
            Subject_Training_Epochs{TrainInd} = Epoch_Sample;
            Subject_Training_Stages(TrainInd) = SleepStageSample;
            TrainInd = TrainInd + 1;
        %if value is 1 add to testing set
        else
            Subject_Testing_Epochs{TestInd} = Epoch_Sample;
            Subject_Testing_Stages(TestInd) = SleepStageSample;
            TestInd = TestInd + 1;
        end
    end

    %Remove empty cells to be left within the training and testing cell
    %arrays
    Subject_Training_Epochs = Subject_Training_Epochs(~cellfun('isempty', Subject_Training_Epochs));
    Subject_Training_Stages = Subject_Training_Stages(1:numel(Subject_Training_Epochs));
    Subject_Testing_Epochs = Subject_Testing_Epochs(~cellfun('isempty', Subject_Testing_Epochs));
    Subject_Testing_Stages = Subject_Testing_Stages(1:numel(Subject_Testing_Epochs));

    %Add subjects training and testing epochs to overall variable
    Training_Epochs{i} = Subject_Training_Epochs;
    Training_Stages{i} = Subject_Training_Stages;
    Testing_Epochs{i} = Subject_Testing_Epochs;
    Testing_Stages{i} = Subject_Testing_Stages;
end

end