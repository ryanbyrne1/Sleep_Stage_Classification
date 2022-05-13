function Forest = Build_Classification_Tree(Epochs, SleepStageClass, NumTrees, Wavelet)
%By Ryan Byrne
%Build random forest classification model

%Number of subjects
numFiles = numel(Epochs);

%Find total number of epochs between all subjects
total_epochs = 0;
for i = 1:numFiles
    numEF = numel(Epochs{i});
    total_epochs = total_epochs + numEF;
end

%Create a feature array
Entropy = zeros(total_epochs, 7);

%Sleep stages from hypnogram used as label input
SleepStage = strings(total_epochs, 1);
ind = 1;
fs = 100;

%Iterate through subjects
for k = 1:numFiles
    
    %Selected all epochs and stages from subject
    Subject_Epoch = Epochs{k};
    Subject_Stages = SleepStageClass{k};

    %number of epochs for subject
    numEF = numel(Epochs{k});
    
    %Establish cwt filter banks to get cwt coefficents within frequency
    %band
    fbkc =  cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[0.5 1.5]);
    fbd = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[1 4]);
    fbt = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[4 8]);
    fba = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[8 12]);
    fbss = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[11 15]);
    fbb1 = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[13 22]);
    fbb2 = cwtfilterbank('SignalLength',numel(Subject_Epoch{1}),'wavelet', Wavelet,'SamplingFrequency',100, 'FrequencyLimits',[22 30]);
    
    %Iterate through epochs and calculate the shannons entropy for each
    %frequency band
    for i=1:numEF
        for j = 1:8
            if (j == 1)
                [ct,f] = wt(fbkc,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 2)
                [ct,f] = wt(fbd,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 3)
                [ct,f] = wt(fbt,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 4)
                [ct,f] = wt(fba,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 5)
                [ct,f] = wt(fbss,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 6)
                [ct,f] = wt(fbb1,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            elseif (j == 7)
                [ct,f] = wt(fbb2,Subject_Epoch{i}) ;
                Entropy(ind, j) = wentropy(abs(ct), 'shannon');
                %Entropy(ind, j) = eeg_Ent(ct);
            else
                SleepStage(ind) = Subject_Stages(i);
            end
        end
        ind = ind + 1;
    end
end

%List of features
features = {'K-complex', 'Delta', 'Theta', 'Alpha', 'Sleep spindles', 'Beta1', 'Beta2'};

%variable for storing each tree of forest
Forest = cell(1, NumTrees);

%Create 100 trees for forest
for j = 1:NumTrees

    %bootstrap epochs
    [btStrpEpochs, btSleepStage] = Epoch_Bootstrp(Entropy, SleepStage);

    %choose 4 features for each tree
    random_Feat_Ind = sort(randperm(numel(features), 4));

    %index the 4 features chosen for each tree
    Selected_Features = btStrpEpochs(:, random_Feat_Ind);

    %Selected the names of features selected
    HeaderCut = features(random_Feat_Ind);

    %convert to table
    Feature_Table = array2table(Selected_Features, 'VariableNames',HeaderCut);
    
    %Fit a tree to data
    Forest{j} = fitctree(Feature_Table,btSleepStage);
end

end