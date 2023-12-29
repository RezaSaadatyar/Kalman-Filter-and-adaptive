clc; clear; close all;
%% Load data
fs = 1000;  
t = 0:1/fs:2; 
abr_signal = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.2*sin(2*pi*200*t);
noise = 0.5 * randn(size(t)); % Gaussian noise with standard deviation 0.5
data = abr_signal + noise;

% Kalman filtering for Auditory Brainstem Response (ABR) extraction

%% Parameters
A = eye(2);  % State transition matrix
H = [1 0];   % Measurement matrix
Q = eye(2);  % Process noise covariance
R = 1;       % Measurement noise covariance (assuming Gaussian noise with std 0.5)
x_hat = zeros(2, 1);  % State estimate
P = eye(2);           % Covariance matrix
filtered_data = zeros(size(data));
state_estimate = zeros(2, length(data));
error = zeros(size(data));
covariance_matrix = zeros(2, 2, length(data));
kalman_gain = zeros(2, length(data));

for k = 1:length(data)    % Kalman filter loop
    %% ------------------------ Prediction step -----------------------------
    x_hat_minus = A * x_hat;
    P_minus = A * P * A' + Q;  % Prediction of error covariance
    %% ------------------------- Update step --------------------------------
    K = P_minus * H' / (H * P_minus * H' + R); % Calculate kalman filter
    x_hat = x_hat_minus + K * (data(k) - H * x_hat_minus); % Corrected state estimation
    P = (eye(2) - K * H) * P_minus;            % Update error covariance
    filtered_data(k) = x_hat(1);

    state_estimate(:, k) = x_hat;
    error(k) = data(k) - H * x_hat_minus;
    covariance_matrix(:, :, k) = P;
    kalman_gain(:, k) = K;
end
mse = mean((data - filtered_data).^2);
display(mse);
%% --------------------------------- Plot results ---------------------------------
figure;
subplot(1,1,1);    % Plot Original Data and Filtered Signal
plot(t, data); hold on;
plot(t, filtered_data);
title(['Kalman Filtering; MSE:' num2str(mse)]);
xlabel('Time');
ylabel('Amplitude');
legend('Data', 'Filtered Data');

figure;
subplot(3, 1, 1);
plot(t, error, 'm', 'LineWidth', 2);
title('Kalman Filter Error');
xlabel('Time (s)');
ylabel('Error');
grid on;

subplot(3, 1, 2);
plot(t, squeeze(covariance_matrix(1, 1, :)), 'c', 'LineWidth', 2); hold on;
plot(t, squeeze(covariance_matrix(2, 2, :)), 'k', 'LineWidth', 2);
title('Covariance Matrix Components');
xlabel('Time (s)');
ylabel('Covariance');
legend('P(1,1)', 'P(2,2)');
grid on;
subplot(3, 1, 3);
plot(t, kalman_gain(1, :), 'b', 'LineWidth', 2); hold on;
plot(t, kalman_gain(2, :), 'r', 'LineWidth', 2);
title('Kalman Gain Components');
xlabel('Time (s)');
ylabel('Kalman Gain');
legend('K(1)', 'K(2)');
grid on;
