clear all; close all;clc;
%% 
% Time creation
fs = 1000; T = 10;
N = T * fs;  t = 0:1/fs:T - 1/fs;

%%
%a
a1 = 1; f1 = 100; phi1 = 0;

a2 = 10; f2 = 75; phi2 = pi/2;

s1 = a1 *  sin(2*pi*f1*t + phi1);
s2 = a2 *  sin(2*pi*f2*t + phi2);

s = s1+s2;

figure;
subplot(311);
plot(t, s1, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain Signal of f = 100: First 50 ms');
xlim([0 0.05]);

subplot(312);
plot(t, s2, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain Signal of f = 75: First 50 ms');
xlim([0 0.05]);

subplot(313);
plot(t, s, 'LineWidth', 1.2);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain Signal: First 500 ms');
xlim([0 0.5]);
%%
%power spectrum
figure;
pspectrum(s, fs, 'power');
title('Power Spectrum (dB)');
xlim([0 200]);

