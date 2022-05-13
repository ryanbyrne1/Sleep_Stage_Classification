function [Epochs, SleepStages] = Cut_Signal_Into_Epochs_FLobe(edf_files,hypno_files)
% Ryan Byrne
% Function for cutting the epoch into signals using the Frontal Lobe

%Number of files chosen
numFiles = numel(edf_files);

%Store epochs and sleepstages
Epochs = cell(1, numFiles);
SleepStages = cell(1, numFiles);

for k = 1:numFiles

    %Read edf file
    psg_time_table = edfread(edf_files{k}) ; 

    %Convert from time table to table
    data = timetable2table(psg_time_table) ; 
    
    %Selection frontal EEG channel
    frontal_EEG = data.EEGFpz_Cz ; 

    %Number of samples in frontal EEG channel
    num_samples = numel(frontal_EEG) * numel(frontal_EEG{1});

    %Opening hyponograms and storing annotations
    info_hypno = edfinfo(hypno_files{k}) ; 
    hypnogram = info_hypno.Annotations  ;
    Onsets = time2num(hypnogram.Onset);
    Annotations = hypnogram.Annotations;
    
    t_start = Onsets(1) ; % start based on sleep stage onset from hypnogram.
    t_end = (num_samples/100); 
    
    %Store entire night recoding into variable
    time_series_EEG = [] ; 
    for j = 1:numel(frontal_EEG)
        time_series_EEG = vertcat(time_series_EEG, frontal_EEG{j}) ; 
    end
    
    %Filter signal using prepreoccesing function
    Filt_Signal = preprocessSig(time_series_EEG);
    
    %For store epochs and sleep stage in file
    F_Epoch = cell(num_samples/100, 1);
    F_Stage = strings(num_samples/100, 1);
    
    %Iterate through 30 second cuts of file
    ind = 1;
    while (t_start < t_end)

        %Begining and end of 30 second epoch
        sect_end = t_start + 30;
        Sigindex = (t_start*100 + 1): (t_start*100 + 1) + 30*100;
        timeIndex = find((Onsets-t_start <= 0) == 1, 1,'last');
        nextIndex = timeIndex + 1;

        if (nextIndex <= numel(Annotations))
            nextTime = Onsets(nextIndex);

            %Ensure that the cut is a 30 second epoch
            if (mod(abs(t_start -nextTime),30) == 0)
                
                %Store 30 second epoch
                F_Epoch{ind} = Filt_Signal(Sigindex);

                %Get sleep stage for 30 second epoch
                fTSleepStage = Annotations(timeIndex);

                %Reformate annotation to single character class
                if (strcmp(fTSleepStage, "Sleep stage W" ))
                    F_Stage(ind) = 'W';
                elseif (strcmp(fTSleepStage, "Sleep stage 1" ))
                    F_Stage(ind) = '1';
                elseif (strcmp(fTSleepStage, "Sleep stage 2" ))
                    F_Stage(ind) = '2';
                elseif (strcmp(fTSleepStage, "Sleep stage 3" ))
                    F_Stage(ind) = '3';
                elseif (strcmp(fTSleepStage, "Sleep stage 4" ))
                    F_Stage(ind) = '3';
                elseif (strcmp(fTSleepStage, "Sleep stage R" ))
                    F_Stage(ind) = 'R';
                end
                ind = ind + 1;
            end
        end
        t_start = sect_end;
    end

    %Store files epochs and sleep stages
    F_Epoch = F_Epoch(~cellfun('isempty', F_Epoch));
    F_Stage = F_Stage(1:numel(F_Epoch));
    Epochs{k} = F_Epoch;
    SleepStages{k} = F_Stage;
end

end