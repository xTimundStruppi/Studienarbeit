% this file contains HRV variables mapping
% it matches a given measurement variable with a description, measuring
% unit, etc.

function setup = setupHRVvariables()
    
    if isfile('setup.mat')
        delete("setup.mat")
    end

    result = struct( ...
            'index', ["RMSSD", "SI", "LF_HF_power", "DFA_alpha1"], ...
            'short', ["RMSSD", "Stress index", "LF/HF Power FFT", "DFA alpha1"], ...
            'description', ["RMS of successive RR interval differences", ...
                "Square root of Baevsky's stress index", ...
                "Absolute LF/HF power FFT", "DFA, short term fluctuations slope"], ...
            'unit', ["seconds", "index", "square milliseconds", "index"], ...
            'type', ["Statistics", "Statistics", "Frequency", "NonLinear"] ...
        );
          
    save('setup.mat','result');
    disp('setup file created')

    setup = load('setup.mat');
    disp('setup file loaded')
end