%% EEC 284 Assignment 3 Problem 2
% TFO Signal Analysis
% Author: Atharva Sanjeev Harshe
% Instructions:
%   - Complete all "TODO" sections
%   - Do not modify function signatures
%   - Submit this file with all functions completed and working

clc; clear; clear all;

%% File Path and Macros
filename = 'tfo_dataset.csv';  % TODO: Replace with your actual file path
Fs = 8000;  % Sampling frequency in Hz
SSD = [ 1.5, 3, 4.5, 7, 10 ];   % Source-to-Detector Distances

%% Load Data from D4
T = readtable(filename);
D4 = [T.ch4Volts]';
%% Basic EDA

D4_raw = double(D4(:));   % raw ADC counts as column vector

adc_bits = 24;
adc_max = 2^(adc_bits-1) - 1;

% Normalize signed 24-bit ADC counts to approximately [-1, +1]
D4_norm = D4_raw / 2^(adc_bits-1);

% Remove DC offset for signal processing
D4_ac = D4_norm - mean(D4_norm);

fprintf('\n--- Basic EDA for D4: Signed 24-bit ADC Assumption ---\n');
fprintf('Raw min value  = %.0f counts\n', min(D4_raw));
fprintf('Raw max value  = %.0f counts\n', max(D4_raw));
fprintf('Raw mean value = %.2f counts\n', mean(D4_raw));
fprintf('Raw std value  = %.2f counts\n', std(D4_raw));

fprintf('\nNormalized signal:\n');
fprintf('Min  = %.6f\n', min(D4_norm));
fprintf('Max  = %.6f\n', max(D4_norm));
fprintf('Mean = %.6f\n', mean(D4_norm));
fprintf('Std  = %.6f\n', std(D4_norm));

fprintf('\nDataset info:\n');
fprintf('Samples  = %d\n', length(D4_raw));
fprintf('Duration = %.2f seconds\n', length(D4_raw)/Fs);

%% Estimate Carrier Frequencies from D4
[f1, f2] = estimate_carrier_frequencies(D4_ac, Fs);
fprintf('Estimated carrier frequencies: f1 = %.2f Hz, f2 = %.2f Hz\n', f1, f2);

%% Demodulate with I/Q Method
WL1_D4_demod = iq_demodulate(D4, f1, Fs);
WL2_D4_demod = iq_demodulate(D4, f2, Fs);

%% Down-Sample WL1 and WL2 by 100x for performance
WL1_D4_down=downsample(WL1_D4_demod',100)';
WL2_D4_down=downsample(WL2_D4_demod',100)';

%% Plot spectrogram for channel 4 wavelength λ2
plot_spectrogram(WL2_D4_down, Fs/100, 60, 0.5);





%% ----------------------------- Local Functions ----------------------------

function [f1, f2] = estimate_carrier_frequencies(signal, Fs)
    % TODO: Use FFT to find two dominant carrier frequencies
    % Inputs:
    %   signal - 1D signal from any detector
    %   Fs - sampling rate in Hz
    % Output:
    %   f1 - estimated carrier frequency 1
    %   f2 - estimated carrier frequency 2
 
  signal = double(signal(:));

    % Remove DC offset
    signal = signal - mean(signal);

    % Use FFT spectrum for carrier frequency estimation
    N = length(signal);

    % Apply Hann window to reduce spectral leakage
    window = hann(N);
    signal_win = signal .* window;

    % FFT
    X = fft(signal_win);

    % One-sided power spectrum
    P2 = abs(X/N).^2;
    Pxx = P2(1:floor(N/2)+1);
    Pxx(2:end-1) = 2*Pxx(2:end-1);

    % One-sided frequency axis
    f = Fs*(0:floor(N/2))/N;

    % Convert power to dB
    Pxx_dB = 10*log10(Pxx + eps);

    % Ignore DC and very low frequency content
    min_search_freq = 20;
    max_search_freq = Fs/2;

    search_idx = (f >= min_search_freq) & (f <= max_search_freq);

    f_search = f(search_idx);
    P_search = Pxx_dB(search_idx);

    % Smooth slightly to reduce tiny local peaks
    P_smooth = movmean(P_search, 5);

    % Minimum separation between the two carriers
    min_sep_hz = 10;

    [~, locs] = findpeaks(P_smooth, f_search, ...
        'SortStr', 'descend', ...
        'MinPeakDistance', min_sep_hz, ...
        'NPeaks', 20);
    carriers = sort(locs(1:2));

    f1 = carriers(1);
    f2 = carriers(2);

    % Plot result
    figure;
    plot(f_search, P_search, 'LineWidth', 1.0); hold on;
    plot(f_search, P_smooth, 'LineWidth', 1.4);

    xline(f1, '--r', ['f1 = ', num2str(f1, '%.2f'), ' Hz']);
    xline(f2, '--g', ['f2 = ', num2str(f2, '%.2f'), ' Hz']);

    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Power (dB)');
    title('Carrier Frequency Estimation using FFT');
    legend('FFT Spectrum', 'Smoothed FFT Spectrum', 'f1', 'f2');

    xlim([0 1500]);

end

function demod = iq_demodulate(signal, fc, Fs)
    % TODO: Perform I/Q demodulation of input signal
    % Inputs:
    %   signal - 1D signal to demodulate
    %   fc - carrier frequency to demodulate
    %   Fs - sampling rate
    % Output:
    %   demod - demodulated signal envelope via sqrt(I^2 + Q^2)

    signal = signal(:)';             % Force row vector
    N = length(signal);
    t = (0:N-1)/Fs;

    % Remove DC before demodulation
    signal = signal - mean(signal);

    % Create I and Q references
    ref_I = cos(2*pi*fc*t);
    ref_Q = -sin(2*pi*fc*t);

    % Mix down to baseband
    I_mixed = 2 * signal .* ref_I;
    Q_mixed = 2 * signal .* ref_Q;

    % Low-pass filter to keep tissue signal bandwidth
    cutoff = 15;   % Hz
    I = lowpass_filter(I_mixed, cutoff, Fs);
    Q = lowpass_filter(Q_mixed, cutoff, Fs);

    % Envelope
    demod = sqrt(I.^2 + Q.^2);

    % Remove slow DC offset from envelope
    demod = demod - mean(demod);

end

function filtered = lowpass_filter(data, cutoff, Fs)
    % TODO: Apply low-pass filtering for I/Q demodulation
    % Inputs:
    %   data   - 1D signal to demodulate
    %   cutoff - Cutoff frequency for low-pass in Hz (use 15Hz here)
    %   Fs     - Sampling rate in Hz
    % Output:
    %   filtered - Filtered version of input
 data = data(:)';

    filter_order = 4;
    Wn = cutoff / (Fs/2);

    [b, a] = butter(filter_order, Wn, 'low');

    % Zero-phase filtering
    filtered = filtfilt(b, a, data);

end

function plot_spectrogram(signal, Fs, window_sec, overlap)
    % TODO: Plot spectrogram of input 1D signal
    % Requirements:
    %   - Frequency on x-axis, time on y-axis
    %   - Spectrum type: 'power'
    %   - X-axis limit: [0, 5] Hz
    % Inputs:
    %   signal        - A 1D signal
    %   Fs          - Sampling frequency (e.g., 80 Hz after downsampling)
    %   window_sec  - Window size in seconds (e.g., 60)
    %   overlap     - Fractional overlap (e.g., 0.5)
  signal = signal(:);

    % Remove DC component for clearer low-frequency visualization
    signal = signal - mean(signal);

    % Window length in samples
    window_length = round(window_sec * Fs);

    % Overlap in samples
    noverlap = round(overlap * window_length);

    % NFFT
    nfft = max(8192, 2^nextpow2(window_length));

    % Hann window
    window = hann(window_length);

    % Spectrogram
    [~, F, Tspec, P] = spectrogram(signal, window, noverlap, nfft, Fs, 'power');

    % Convert power to dB
    P_dB = 10*log10(P + eps);

    % Plot with frequency on x-axis and time on y-axis
    figure;
    imagesc(F, Tspec, P_dB');
    axis xy;
    colorbar;

    xlabel('Frequency (Hz)');
    ylabel('Time (s)');
    title('Spectrogram of Detector 4, Wavelength \lambda_2');

    xlim([0 5]);  

end
%47