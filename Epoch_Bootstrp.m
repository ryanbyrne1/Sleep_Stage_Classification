function [btStrpEpochs, btSleepStage] = Epoch_Bootstrp(Epochs, SleepStage)
%By Ryan Byrne
%Bootstrapping function to random sample epochs to get random sampling cell
%array
%Size of array of epochs
[r,c] = size(Epochs);

%variables for storing bootstrapped epochs
btStrpEpochs = zeros([r,c]);
btSleepStage = strings(size(SleepStage));

%randomly choose an epoch and corresponding sleep stage to add to
%bootstrapped variable
for i = 1:r
    epoch = randi(r, 1);
    btStrpEpochs(i,:) = Epochs(epoch, :);
    btSleepStage(i) = SleepStage(epoch);
end
end