function Filt_Signal = preprocessSig(time_series_EEG)
%Ryan Byrne
%apply bandpass filter to EEG signal 
%of 0.5-35 to signal to filter it

%set bandpass
xpass = [0.5 35];

%set sampling frequency
fs = 100;

%apply band pass filter
Filt_Signal = bandpass(time_series_EEG,xpass, fs);

end