classdef WithSamplesParser

    properties
        path
        data
        datetime
    end

    methods
        function obj = WithSamplesParser(path2file)
            obj.path = path2file;
            obj.data = load(path2file);

            datetimeStr = [obj.data.Res.CNT.CntGen.date ' ' obj.data.Res.CNT.CntGen.time];
            obj.datetime = datetime(datetimeStr,'InputFormat','dd.MM.yy HH.mm.ss');

            obj = obj.adjustFrequencyData();
        end

        function plotToAxes(obj, setup, UIAxes, selectedVar)
            idx = find(setup.result.short == selectedVar);
            
            index = setup.result.index(idx);
            description = setup.result.description(idx);
            unit = setup.result.unit(idx);
            type = setup.result.type(idx);
            
            % calculate the length of a single sample
            sampleLength = round((obj.data.Res.CNT.Length / 60) ...
                / length(obj.data.Res.HRV.(type).(index)));
            % create array of timestamps to match y-values
            timeArray = obj.datetime:minutes(sampleLength):obj.datetime ...
                + minutes(length(obj.data.Res.HRV.(type).(index)) * sampleLength);

            plot(UIAxes, timeArray(2:end), obj.data.Res.HRV.(type).(index));
            UIAxes.Title.String = selectedVar;
            UIAxes.Subtitle.String = description;
            UIAxes.YLabel.String = unit;
            UIAxes.XLabel.String = '';

            % configure x-Axis to start at y-Axis and tick every 3 minutes
            UIAxes.XLim = [timeArray(2) timeArray(end)];
            UIAxes.XTick = timeArray(2):minutes(sampleLength*2):timeArray(end);
        end

        function obj = adjustFrequencyData(obj)
            % adjust the frequency struct to match plotting scheme
            % warning! this deletes the other measurements if not copied
            % TODO: find better solution
            
            % safe the table contents
            nonlinearData = obj.data.Res.HRV.NonLinear;
            frequencyData = obj.data.Res.HRV.Frequency;
            statisticsData = obj.data.Res.HRV.Statistics;

            % create empty tables for our new, filtered data
            LFHFpower = double.empty(length(frequencyData), 0);
            DFAalpha1 = double.empty(length(nonlinearData), 0);
            RMSSD = double.empty(length(statisticsData), 0);
            StressIndex = double.empty(length(statisticsData), 0);
            
            for idx = 1:length(frequencyData)
                LFHFpower(idx) = frequencyData(idx).Welch.('LF_HF_power');
                DFAalpha1(idx) = nonlinearData(idx).DFA.('alpha1');
                RMSSD(idx) = statisticsData(idx).('RMSSD');
                StressIndex(idx) = statisticsData(idx).('SI');
            end

            obj.data.Res.HRV.Frequency = struct('LF_HF_power', LFHFpower);
            obj.data.Res.HRV.NonLinear = struct('DFA_alpha1', DFAalpha1);
            obj.data.Res.HRV.Statistics = struct('RMSSD', RMSSD, 'SI', StressIndex);

            % add new content to maintain completeness of data
            obj.data.Res.HRV.oldFrequency = frequencyData;
            obj.data.Res.HRV.oldNonLinear = nonlinearData;
            obj.data.Res.HRV.oldStatistics = statisticsData;
        end
    end
end