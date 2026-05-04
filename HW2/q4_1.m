%%
% Part b: Gaussian noise addition
variance_values = [0.1 0.7 1 2];
figure;

for i = 1:length(variance_values)

    var_n = variance_values(i);
    noise = sqrt(var_n) * randn(size(t));
    s_noisy = s + noise;

    % Time domain
    subplot(length(variance_values),2,2*i-1);
    plot(t, s_noisy);
    xlim([0 0.05]);
    grid on;
    title(['Time (Var = ', num2str(var_n), ')']);

    % Spectrum
    subplot(length(variance_values),2,2*i);
    pspectrum(s_noisy, fs, 'power');
    xlim([0 200]);
    title(['Spectrum (Var = ', num2str(var_n), ')']);

end

sgtitle('Effect of Noise Variance on Signal');