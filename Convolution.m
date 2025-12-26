clc;
clear;

% Filter parameters
fs = 48000;         % Sampling frequency in Hz
filtOrder = 8;      % Filter order
fl = 30;            % Low Frequency Input
fh = 500;           % High Frequency Input
Al = 1;             % Amplitude of Low Frequency Input
Ah = 1;             % Amplitude of High Frequency Input
T = 1;              % Signal Duration in Seconds

% Input Signal
t = 0:1/fs:T-1/fs;    % Time vector for 1 second
x_l = Al * sin(2 * pi * fl * t);
x_h = Ah * sin(2 * pi * fh * t);
x_t = x_l + x_h;

% Designing Low Frequency Filter
lFreq = 30;        % Lower cutoff frequency in Hz
hFreq = 500;       % Upper cutoff frequency in Hz

% Design the Butterworth bandpass filter using designfilt
bandpassFilter = ddesignfilt('bandpassiir', ...
                'FilterOrder', 8, ...
                'HalfPowerFrequency1', app.tubLF, ...
                'HalfPowerFrequency2', app.tubHF, ...
                'SampleRate', app.fs);

% Get the filter coefficients (b, a) from the filter object
[b, a] = tf(bandpassFilter);

% Magnitude Response and Signal Plot
y_t = filter(b, a, x_t);        % Filtered signal

% Compute the FFT of the Filtered Signal
n = length(x_t);                     % Number of samples
X_fft = fft(x_t);                  % FFT of the original signal
Y_fft = fft(y_t);                  % FFT of the filtered signal
f = (0:n-1) * (fs / n);            % Frequency vector
X_mag = abs(X_fft) / n;      % Magnitude of the original signal
Y_mag = abs(Y_fft) / n;      % Magnitude of the filtered signal

% Focus on positive frequencies (up to Nyquist frequency)
X_mag_pos = X_mag(1:n/2);
Y_mag_pos = Y_mag(1:n/2);
f_pos = f(1:n/2);

% Pinpoint the peaks at 1000 Hz and 4000 Hz
[~, idx_150] = min(abs(f_pos - 150));  % Index closest to 1000 Hz
[~, idx_2000] = min(abs(f_pos - 2000));  % Index closest to 4000 Hz

% Get the magnitudes at those frequencies
in_150 = X_mag_pos(idx_150);
in_2000 = X_mag_pos(idx_2000);
mag_250 = Y_mag_pos(idx_150);
mag_3500 = Y_mag_pos(idx_2000);

% Plot the FFT (Frequency Domain)
figure;
subplot(2,1,1);
plot(f_pos, X_mag_pos, 'LineWidth', 1.5, 'DisplayName', 'Input'); % Plot original signal
hold on;
plot(f_pos(idx_150), in_150, 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 4, 'DisplayName', 'Peak at 150 Hz');
plot(f_pos(idx_2000), in_2000, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4, 'DisplayName', 'Peak at 2000 Hz');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend;
title('Original Signal');
grid on;

subplot(2,1,2);
plot(f_pos, Y_mag_pos, 'LineWidth', 1.5, 'DisplayName', 'Output'); % Plot filtered signal
hold on;
plot(f_pos(idx_150), mag_250, 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 4, 'DisplayName', 'Peak at 150 Hz');
plot(f_pos(idx_2000), mag_3500, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4, 'DisplayName', 'Peak at 2000 Hz');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend;
title('Filtered Signal under Tuba Filter');
grid on;



% Designing High Frequency Filter
lFreq = 1000;          % Lower cutoff frequency in Hz
hFreq = 4000;       % Upper cutoff frequency in Hz

% Design the Butterworth bandpass filter using designfilt
bandpassFilter = designfilt('bandpassiir', 'FilterOrder', filtOrder, ...
                            'HalfPowerFrequency1', lFreq, 'HalfPowerFrequency2', hFreq, 'SampleRate', fs);

% Get the filter coefficients (b, a) from the filter object
[b, a] = tf(bandpassFilter);

% Magnitude Response and Signal Plot
y_t = filter(b, a, x_t);        % Filtered signal

% Compute the FFT of the Filtered Signal
n = length(x_t);                   % Number of samples
X_fft = fft(x_t);                  % FFT of the original signal
Y_fft = fft(y_t);                  % FFT of the filtered signal
f = (0:n-1) * (fs / n);            % Frequency vector
X_mag = abs(X_fft) / n;      % Magnitude of the original signal
Y_mag = abs(Y_fft) / n;      % Magnitude of the filtered signal

% Focus on positive frequencies (up to Nyquist frequency)
X_mag_pos = X_mag(1:n/2);
Y_mag_pos = Y_mag(1:n/2);
f_pos = f(1:n/2);

% Pinpoint the peaks at 1000 Hz and 4000 Hz
[~, idx_150] = min(abs(f_pos - 150));  % Index closest to 1000 Hz
[~, idx_2000] = min(abs(f_pos - 2000));  % Index closest to 6000 Hz

% Get the magnitudes at those frequencies
in_150 = X_mag_pos(idx_150);
in_2000 = X_mag_pos(idx_2000);
mag_250 = Y_mag_pos(idx_150);
mag_3500 = Y_mag_pos(idx_2000);

% Plot the FFT (Frequency Domain)
figure;
subplot(2,1,1);
plot(f_pos, X_mag_pos, 'LineWidth', 1.5, 'DisplayName', 'Input'); % Plot original signal
hold on;
plot(f_pos(idx_150), in_150, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'DisplayName', 'Peak at 150 Hz');
plot(f_pos(idx_2000), in_2000, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4, 'DisplayName', 'Peak at 2000 Hz');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend;
title('Original Signal');
grid on;

subplot(2,1,2);
plot(f_pos, Y_mag_pos, 'LineWidth', 1.5, 'DisplayName', 'Output'); % Plot filtered signal
hold on;
plot(f_pos(idx_150), mag_250, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'DisplayName', 'Peak at 150 Hz');
plot(f_pos(idx_2000), mag_3500, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4, 'DisplayName', 'Peak at 2000 Hz');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend;
title('Filtered Signal under Piccolo Filter');
grid on;