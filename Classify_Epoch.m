function SleepStage = Classify_Epoch(Forest,Epoch, fs, Wavelet)
%By Ryan Byrne
%Classifies a 30 second epoch using random forest classification

%First set sleep stage to be 'U' for undetermined
SleepStage = 'U';

%Create empty feature vector
Feature_Vector = zeros(1, 7);

%Establish cwt filter banks to get cwt coefficents within frequency band
fbkc =  cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[0.5 1.5]);
fbd = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[1 4]);
fbt = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[4 8]);
fba = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[8 12]);
fbss = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[11 15]);
fbb1 = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[13 22]);
fbb2 = cwtfilterbank('SignalLength',numel(Epoch),'wavelet', Wavelet,'SamplingFrequency',fs, 'FrequencyLimits',[22 30]);

%For each frequency band calculate shannon's entropy
for j = 1:7
    if (j == 1)
        [ct,f] = wt(fbkc,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 2)
        [ct,f] = wt(fbd,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 3)
        [ct,f] = wt(fbt,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 4)
        [ct,f] = wt(fba,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 5)
        [ct,f] = wt(fbss,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 6)
        [ct,f] = wt(fbb1,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    elseif (j == 7)
        [ct,f] = wt(fbb2,Epoch) ;
        Feature_Vector(j)  = wentropy(abs(ct), 'shannon');
        %Feature_Vector(j)  = eeg_Ent(ct);
    end
end

%Possible features
features = {'K-complex', 'Delta', 'Theta', 'Alpha', 'Sleep spindles', 'Beta1', 'Beta2'};

%Number of trees in forest
NumTrees = numel(Forest);

%Stores each trees prediction
Stages = strings(1, NumTrees);

%Iterate through trees
for i = 1:NumTrees

    %Chose a tree
    Tree = Forest{i};

    %Find features used in Tree
    Features = Tree.PredictorNames;

    %Find indexs of features used
    FeatInd = [find(strcmp(features, Features{1}) == 1), find(strcmp(features, Features{2}) == 1), find(strcmp(features, Features{3}) == 1), find(strcmp(features, Features{4}) == 1)];
    
    %Index selected features
    Selected_Features = Feature_Vector(FeatInd);

    %Get names of selected features
    HeaderCut = features(FeatInd);

    %Convert to table
    Feature_Table = array2table(Selected_Features, 'VariableNames',HeaderCut);

    %Predict class for given tree using feature table
    Stage = predict(Tree,Feature_Table);

    %Add predicted stage to cell array
    Stages(i) = Stage{1};
end

%Find the mode of the stages i.e. the most predicted stage
[s,~,j]=unique(Stages);
SleepStage = s{mode(j)};

end