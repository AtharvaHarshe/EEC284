close all;

rng(2);   % For repeatable random signals

%% Create three different noise-only signals
noise_var = 1;

n1 = sqrt(noise_var) * randn(size(t));
n2 = sqrt(noise_var) * randn(size(t));
n3 = sqrt(noise_var) * randn(size(t));

%% 
%  1. Power spectrum of each noise signal

X1 = fft(n1);
X2 = fft(n2);
X3 = fft(n3);

P2_1 = abs(X1/N).^2;
P2_2 = abs(X2/N).^2;
P2_3 = abs(X3/N).^2;

P1_1 = P2_1(1:N/2+1);
P1_2 = P2_2(1:N/2+1);
P1_3 = P2_3(1:N/2+1);

P1_1(2:end-1) = 2*P1_1(2:end-1);
P1_2(2:end-1) = 2*P1_2(2:end-1);
P1_3(2:end-1) = 2*P1_3(2:end-1);

f = fs*(0:N/2)/N;

P1_1_dB = 10*log10(P1_1 + eps);
P1_2_dB = 10*log10(P1_2 + eps);
P1_3_dB = 10*log10(P1_3 + eps);

%% 
%  2. Welch PSD estimate using pwelch


window_length = 1024;
window = hamming(window_length);
overlap = window_length/2;
nfft = 2048;

[PSD1, f_welch] = pwelch(n1, window, overlap, nfft, fs);
[PSD2, ~]       = pwelch(n2, window, overlap, nfft, fs);
[PSD3, ~]       = pwelch(n3, window, overlap, nfft, fs);

PSD1_dB = 10*log10(PSD1 + eps);
PSD2_dB = 10*log10(PSD2 + eps);
PSD3_dB = 10*log10(PSD3 + eps);

%%
%  Figure 1: Power spectrum and Welch PSD


figure;

subplot(1,2,1);
plot(f, P1_1_dB, 'LineWidth', 1.0); hold on;
plot(f, P1_2_dB, 'LineWidth', 1.0);
plot(f, P1_3_dB, 'LineWidth', 1.0);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Power Spectrum of Three Noise Signals');
legend('Noise Signal 1', 'Noise Signal 2', 'Noise Signal 3');
xlim([0 fs/2]);
ylim([-90 0]);

subplot(1,2,2);
plot(f_welch, PSD1_dB, 'LineWidth', 1.2); hold on;
plot(f_welch, PSD2_dB, 'LineWidth', 1.2);
plot(f_welch, PSD3_dB, 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');
title('Welch PSD Estimate');
legend('Noise Signal 1', 'Noise Signal 2', 'Noise Signal 3');
xlim([0 fs/2]);
ylim([-90 0]);

sgtitle('Part C: Direct Power Spectrum vs Welch PSD');

%% 
%  Figure 2: Change Welch window length and overlap


window_length_2 = 256;
window_2 = hamming(window_length_2);
overlap_2 = window_length_2/2;
nfft_2 = 1024;

[PSD1_short, f_short] = pwelch(n1, window_2, overlap_2, nfft_2, fs);


figure;

subplot(1,2,1);
plot(f_welch, PSD1_dB, 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');
title('Welch PSD: Window Length = 1024');
xlim([0 fs/2]);
ylim([-90 0]);

subplot(1,2,2);
plot(f_short, 10*log10(PSD1_short + eps), 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD (dB/Hz)');
title('Welch PSD: Window Length = 256');
xlim([0 fs/2]);
ylim([-90 0]);

sgtitle('Effect of Welch Window Length on PSD Estimate');