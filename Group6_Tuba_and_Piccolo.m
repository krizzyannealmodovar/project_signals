classdef Group6_Tuba_and_Piccolo < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure       matlab.ui.Figure
        Image12        matlab.ui.control.Image
        Image11        matlab.ui.control.Image
        Image13        matlab.ui.control.Image
        Image9         matlab.ui.control.Image
        Image10        matlab.ui.control.Image
        Image          matlab.ui.control.Image
        RecordButton   matlab.ui.control.Button
        Image8         matlab.ui.control.Image
        Image7         matlab.ui.control.Image
        Image6         matlab.ui.control.Image
        Image5         matlab.ui.control.Image
        Image4         matlab.ui.control.Image
        Image3         matlab.ui.control.Image
        Image2         matlab.ui.control.Image
        ResetButton    matlab.ui.control.Button
        PiccoloButton  matlab.ui.control.Button
        TubaButton     matlab.ui.control.Button
        PlayButton     matlab.ui.control.Button
        AnalyzeButton  matlab.ui.control.Button
        UIAxes_9       matlab.ui.control.UIAxes
        UIAxes_8       matlab.ui.control.UIAxes
        UIAxes_7       matlab.ui.control.UIAxes
        UIAxes_6       matlab.ui.control.UIAxes
        UIAxes         matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
         fs          % Sampling frequency
        bits        % Bit depth
        channels    % Mono / Stereo
        recordSig   % Recorded audio

        tubaSig     % Low-frequency filtered signal
        piccoloSig  % High-frequency filtered signal

        TubaFilter      % Tuba bandpass filter
        PiccoloFilter   % Piccolo bandpass filter

        tubLF      % Tuba LF
        tubHF       % Tuba HF
        piccLF
        piccHF
    end 

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RecordButton
        function RecordButtonPushed(app, event)
            cla(app.UIAxes_7);
        
            app.fs = 48000;
            app.bits = 16;
            app.channels = 1;
            duration = 8;
        
            % Recorder object 
            recObj = audiorecorder(app.fs, app.bits, app.channels);
        
            recordblocking(recObj, duration);
        
            % Get recorded samples
            x = getaudiodata(recObj, 'double');
        
            % Remove DC offset (CRITICAL for bass) 
            x = x - mean(x);
        
            % Store the signal only
            app.recordSig = x;
        
            % Plot
            plot(app.UIAxes_7, x, 'Color', [1 0 1], 'LineWidth', 0.3);
            title(app.UIAxes_7, 'Original Audio');
            xlabel(app.UIAxes_7, 'Time');
            ylabel(app.UIAxes_7, 'Amplitude');
            ylim(app.UIAxes_7, [-0.3 0.3]);  
            grid(app.UIAxes_7, 'on');
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
            if isempty(app.recordSig)
                return;
            end
            
            % Design Tuba filter
            app.tubLF = 30;      % Tuba lower cutoff
            app.tubHF = 500;     % Tuba upper cutoff
            
            app.TubaFilter = designfilt('bandpassiir', ...
                'FilterOrder', 8, ...
                'HalfPowerFrequency1', app.tubLF, ...
                'HalfPowerFrequency2', app.tubHF, ...
                'SampleRate', app.fs);

            % Design Piccolo filter
            app.piccLF = 3500;   % Piccolo lower cutoff
            app.piccHF = 6000;   % Piccolo upper cutoff
            
            app.PiccoloFilter = designfilt('bandpassiir', ...
                'FilterOrder', 8, ...
                'HalfPowerFrequency1', app.piccLF, ...
                'HalfPowerFrequency2', app.piccHF, ...
                'SampleRate', app.fs);

            % Apply zero-phase filtering
            app.tubaSig = filtfilt(app.TubaFilter, app.recordSig);
            app.piccoloSig = filtfilt(app.PiccoloFilter, app.recordSig);

            % Frequency Domain Tuba
            N = length(app.tubaSig);
            TubaFFT = abs(fft(app.tubaSig))/N;
            f = (0:floor(N/2))*(app.fs/N);
            TubaFFT = TubaFFT(1:floor(N/2)+1);

            plot(app.UIAxes, f, TubaFFT,'Color',[0 0.5 1], 'LineWidth',1.2);
            title(app.UIAxes,'Frequency Tuba');
            xlabel(app.UIAxes,'Frequency (Hz)');
            ylabel(app.UIAxes,'Magnitude');
            xlim(app.UIAxes, [0 1000]);
            grid(app.UIAxes,'on');
           
            % Time Domain Tuba
            cla(app.UIAxes_8);
            tuba_vis = app.tubaSig / max(abs(app.tubaSig));
            t = (0:length(app.tubaSig)-1)/app.fs;   % Time vector
            
            plot(app.UIAxes_8, t,tuba_vis, 'Color',[1 0.5 0], 'LineWidth',0.8);
            title(app.UIAxes_8,'Time Domain – Tuba');
            xlabel(app.UIAxes_8,'Time (s)');
            ylabel(app.UIAxes_8,'Amplitude'); 
            xlim(app.UIAxes_8, 'auto');  
            ylim(app.UIAxes_8, [-0.2 0.2]);  
            grid(app.UIAxes_8,'on');
            
            % Frequency Domain Piccolo
            N = length(app.piccoloSig);
            PiccoloFFT = abs(fft(app.piccoloSig))/N;
            f = (0:floor(N/2))*(app.fs/N);
            PiccoloFFT = PiccoloFFT(1:floor(N/2)+1);

            plot(app.UIAxes_6, f, PiccoloFFT, 'Color',[1 0.5 0], 'LineWidth',1.2);
            title(app.UIAxes_6,'Frequency Piccolo');
            xlabel(app.UIAxes_6,'Frequency');
            ylabel(app.UIAxes_6,'Magnitude');
            xlim(app.UIAxes_6, [500 10000]);
            grid(app.UIAxes_6,'on');

            % Time Domain Piccolo
            cla(app.UIAxes_9);
            t = (0:length(app.piccoloSig)-1)/app.fs;   % Time vector
            
            plot(app.UIAxes_9, t, app.piccoloSig, 'Color',[1 0.5 0], 'LineWidth',0.8);
            title(app.UIAxes_9,'Time Domain – Tuba');
            xlabel(app.UIAxes_9,'Time (s)');
            ylabel(app.UIAxes_9,'Amplitude');
            xlim(app.UIAxes_9, 'auto');   
            ylim(app.UIAxes_9, [-0.2 0.2]);  
            grid(app.UIAxes_8,'on');
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if isempty(app.recordSig)
                return;
            end
        
            x = app.recordSig;
        
            % Remove DC offset
            x = x - mean(x);
        
            % Loudness normalization (RMS-based) 
            targetRMS = 0.12;   % good listening level
            currentRMS = rms(x);
        
            if currentRMS > 0
                x = x * (targetRMS / currentRMS);
            end
        
            % Safety clip 
            peak = max(abs(x));
            if peak > 1
                x = x / peak;
            end
        
            sound(x, app.fs, app.bits);
        end

        % Button pushed function: TubaButton
        function TubaButtonPushed(app, event)
            if isempty(app.tubaSig)
                return;
            end
        
            tub = app.tubaSig;
        
            % Remove DC offset
            tub = tub - mean(tub);
       
            % Strong loudness boost (RMS-based)
            targetRMS = 0.18;           % HIGH on purpose (bass needs this)
            currentRMS = rms(tub);
        
            if currentRMS > 0
                tub = tub * (targetRMS / currentRMS);
            end
        
            % Harmonic enhancement (CRITICAL for bass)
            tub = tanh(1 * tub);       
            
            % Final safety normalization
            peak = max(abs(tub));
            if peak > 1
                tub = tub / peak;
            end
        
            % Play sound
            sound(tub, app.fs, app.bits);
        end

        % Button pushed function: PiccoloButton
        function PiccoloButtonPushed(app, event)
            % Apply gain
            gainFactor = 8;
            ampPicc = app.piccoloSig * gainFactor;
            
            % Normalize
            if max(abs(ampPicc)) > 0
                ampPicc = ampPicc / max(abs(ampPicc));
            end
            
            % Play the amplified Piccolo signal
            sound(ampPicc, app.fs, app.bits);
        end

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            cla(app.UIAxes_9);
            cla(app.UIAxes_8);
            cla(app.UIAxes_7);
            cla(app.UIAxes_6);
            cla(app.UIAxes); 
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9961 0.7882 0.8824];
            app.UIFigure.Position = [100 100 1180 687];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Frequency Tuba')
            xlabel(app.UIAxes, 'Frequency')
            ylabel(app.UIAxes, 'Magnitude')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = 'Comic Sans MS';
            app.UIAxes.FontWeight = 'bold';
            app.UIAxes.XColor = [1 0.1647 0.1647];
            app.UIAxes.YColor = [1 0.1647 0.1647];
            app.UIAxes.ZColor = [1 0.1647 0.1647];
            app.UIAxes.SubtitleFontWeight = 'bold';
            app.UIAxes.Position = [406 322 351 231];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.UIFigure);
            title(app.UIAxes_6, 'Frequency Piccolo')
            xlabel(app.UIAxes_6, 'Frequency')
            ylabel(app.UIAxes_6, 'Magnitude')
            zlabel(app.UIAxes_6, 'Z')
            app.UIAxes_6.FontName = 'Comic Sans MS';
            app.UIAxes_6.FontWeight = 'bold';
            app.UIAxes_6.XColor = [1 0.1647 0.1647];
            app.UIAxes_6.YColor = [1 0.1647 0.1647];
            app.UIAxes_6.ZColor = [1 0.1647 0.1647];
            app.UIAxes_6.SubtitleFontWeight = 'bold';
            app.UIAxes_6.Position = [783 323 351 231];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.UIFigure);
            title(app.UIAxes_7, 'Original Audio')
            xlabel(app.UIAxes_7, 'Time')
            ylabel(app.UIAxes_7, 'Amplitude')
            zlabel(app.UIAxes_7, 'Z')
            app.UIAxes_7.FontName = 'Comic Sans MS';
            app.UIAxes_7.FontWeight = 'bold';
            app.UIAxes_7.XColor = [1 0.1647 0.1647];
            app.UIAxes_7.YColor = [1 0.1647 0.1647];
            app.UIAxes_7.ZColor = [1 0.1647 0.1647];
            app.UIAxes_7.SubtitleFontWeight = 'bold';
            app.UIAxes_7.Position = [34 39 351 231];

            % Create UIAxes_8
            app.UIAxes_8 = uiaxes(app.UIFigure);
            title(app.UIAxes_8, 'Time Tuba')
            xlabel(app.UIAxes_8, 'Time')
            ylabel(app.UIAxes_8, 'Amplitude')
            zlabel(app.UIAxes_8, 'Z')
            app.UIAxes_8.FontName = 'Comic Sans MS';
            app.UIAxes_8.FontWeight = 'bold';
            app.UIAxes_8.XColor = [1 0.1647 0.1647];
            app.UIAxes_8.YColor = [1 0.1647 0.1647];
            app.UIAxes_8.ZColor = [1 0.1647 0.1647];
            app.UIAxes_8.SubtitleFontWeight = 'bold';
            app.UIAxes_8.Position = [407 39 351 231];

            % Create UIAxes_9
            app.UIAxes_9 = uiaxes(app.UIFigure);
            title(app.UIAxes_9, 'Time Piccolo')
            xlabel(app.UIAxes_9, 'Time')
            ylabel(app.UIAxes_9, 'Amplitude')
            zlabel(app.UIAxes_9, 'Z')
            app.UIAxes_9.FontName = 'Comic Sans MS';
            app.UIAxes_9.FontWeight = 'bold';
            app.UIAxes_9.XColor = [1 0.1647 0.1647];
            app.UIAxes_9.YColor = [1 0.1647 0.1647];
            app.UIAxes_9.ZColor = [1 0.1647 0.1647];
            app.UIAxes_9.SubtitleFontWeight = 'bold';
            app.UIAxes_9.Position = [782 39 351 231];

            % Create AnalyzeButton
            app.AnalyzeButton = uibutton(app.UIFigure, 'push');
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            app.AnalyzeButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.AnalyzeButton.FontName = 'Comic Sans MS';
            app.AnalyzeButton.FontSize = 25;
            app.AnalyzeButton.FontWeight = 'bold';
            app.AnalyzeButton.FontColor = [1 0.1647 0.1647];
            app.AnalyzeButton.Position = [112 516 253 40];
            app.AnalyzeButton.Text = 'Analyze';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.PlayButton.FontName = 'Comic Sans MS';
            app.PlayButton.FontSize = 25;
            app.PlayButton.FontWeight = 'bold';
            app.PlayButton.FontColor = [1 0.1647 0.1647];
            app.PlayButton.Position = [112 467 253 40];
            app.PlayButton.Text = 'Play';

            % Create TubaButton
            app.TubaButton = uibutton(app.UIFigure, 'push');
            app.TubaButton.ButtonPushedFcn = createCallbackFcn(app, @TubaButtonPushed, true);
            app.TubaButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.TubaButton.FontName = 'Comic Sans MS';
            app.TubaButton.FontSize = 25;
            app.TubaButton.FontWeight = 'bold';
            app.TubaButton.FontColor = [1 0.1647 0.1647];
            app.TubaButton.Position = [112 416 253 40];
            app.TubaButton.Text = 'Tuba';

            % Create PiccoloButton
            app.PiccoloButton = uibutton(app.UIFigure, 'push');
            app.PiccoloButton.ButtonPushedFcn = createCallbackFcn(app, @PiccoloButtonPushed, true);
            app.PiccoloButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.PiccoloButton.FontName = 'Comic Sans MS';
            app.PiccoloButton.FontSize = 25;
            app.PiccoloButton.FontWeight = 'bold';
            app.PiccoloButton.FontColor = [1 0.1647 0.1647];
            app.PiccoloButton.Position = [112 364 253 40];
            app.PiccoloButton.Text = 'Piccolo';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.ResetButton.FontName = 'Comic Sans MS';
            app.ResetButton.FontSize = 25;
            app.ResetButton.FontWeight = 'bold';
            app.ResetButton.FontColor = [1 0.1647 0.1647];
            app.ResetButton.Position = [112 313 253 40];
            app.ResetButton.Text = 'Reset';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [533 551 517 142];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'Text 4.png');

            % Create Image3
            app.Image3 = uiimage(app.UIFigure);
            app.Image3.Position = [48 467 51 40];
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'Graphics 1.png');

            % Create Image4
            app.Image4 = uiimage(app.UIFigure);
            app.Image4.Position = [48 516 51 40];
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'Graphics 2.png');

            % Create Image5
            app.Image5 = uiimage(app.UIFigure);
            app.Image5.Position = [43 416 63 40];
            app.Image5.ImageSource = fullfile(pathToMLAPP, 'Graphics 3.png');

            % Create Image6
            app.Image6 = uiimage(app.UIFigure);
            app.Image6.Position = [49 365 51 40];
            app.Image6.ImageSource = fullfile(pathToMLAPP, 'Graphics 4.png');

            % Create Image7
            app.Image7 = uiimage(app.UIFigure);
            app.Image7.Position = [36 560 76 48];
            app.Image7.ImageSource = fullfile(pathToMLAPP, 'Graphics 6.png');

            % Create Image8
            app.Image8 = uiimage(app.UIFigure);
            app.Image8.Position = [56 313 36 40];
            app.Image8.ImageSource = fullfile(pathToMLAPP, 'Graphics 5.png');

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.BackgroundColor = [0.9843 0.9686 0.8863];
            app.RecordButton.FontName = 'Comic Sans MS';
            app.RecordButton.FontSize = 25;
            app.RecordButton.FontWeight = 'bold';
            app.RecordButton.FontColor = [1 0.1647 0.1647];
            app.RecordButton.Position = [113 567 253 40];
            app.RecordButton.Text = 'Record';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [290 552 115 114];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'Graphics 7.png');

            % Create Image10
            app.Image10 = uiimage(app.UIFigure);
            app.Image10.Position = [828 522 300 44];
            app.Image10.ImageSource = fullfile(pathToMLAPP, 'Text 5.png');

            % Create Image9
            app.Image9 = uiimage(app.UIFigure);
            app.Image9.Position = [460 517 284 49];
            app.Image9.ImageSource = fullfile(pathToMLAPP, 'Text 1.png');

            % Create Image13
            app.Image13 = uiimage(app.UIFigure);
            app.Image13.Position = [852 218 257 86];
            app.Image13.ImageSource = fullfile(pathToMLAPP, 'Text 6.png');

            % Create Image11
            app.Image11 = uiimage(app.UIFigure);
            app.Image11.Position = [491 215 224 89];
            app.Image11.ImageSource = fullfile(pathToMLAPP, 'Text 2.png');

            % Create Image12
            app.Image12 = uiimage(app.UIFigure);
            app.Image12.Position = [88 209 278 100];
            app.Image12.ImageSource = fullfile(pathToMLAPP, 'Text 3.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Group6_Tuba_and_Piccolo

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end