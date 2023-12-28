clc; clear; close all;
%% Load data
fs = 1000;  
t = 0:1/fs:2; 
abr_signal = sin(2*pi*50*t) + 0.5*sin(2*pi*120*t) + 0.2*sin(2*pi*200*t);
noise = 0.5 * randn(size(t)); % Gaussian noise with standard deviation 0.5
data = abr_signal + noise;
%% Parameters
A = 1;          % State transition matrix
H = 1;          % Measurement matrix
Q = 0.01;       % Process noise covariance
R = 0.1;        % Measurement noise covariance
beta = 0.01;    % Adaptation rate for R; A higher beta makes the adaptation faster, but it should be carefully tuned to prevent instability.
W = 0.005;      % State noise covariance; A higher W allows for more variability in the state prediction.
alpha = 0.01;   % A higher value of alpha means faster adaptation, while a lower value results in a slower adaptation.
x_hat = zeros(size(data));   % Estimated state
P = ones(size(data));        % Covariance matrix
K = zeros(size(data));       % Kalman gain

estimation_error = zeros(size(data));
state_variance = zeros(size(data));
innovation = zeros(size(data));

for k = 2:length(data)
    % ------------------------ Prediction step ---------------------------------
    x_hat_minus = A * x_hat(k-1);
    P_minus = A * P(k-1) * A' + Q + W;
    % -------------------------- Update step -----------------------------------
    K(k) = P_minus * H' / (H * P_minus * H' + R);   % Calculate Kalman gain
    innovation(k) = data(k) - H * x_hat_minus;      % Calculate innovation
    x_hat(k) = x_hat_minus + K(k) * innovation(k);
    P(k) = (1 - K(k) * H) * P_minus;                % updated estimate error covariance
    % ------------------------ Adaptive update ---------------------------------
    P(k) = P(k) + alpha * innovation(k)^2; 
    P(k) = max(P(k), eps);
    R = R + beta * (innovation(k)^2 - R);           % Adaptive update for R

    estimation_error(k) = data(k) - H * x_hat_minus;% Calculate additional metrics
    state_variance(k) = P(k);
end

% Calculate overall performance metrics
mse = mean(estimation_error.^2);
rmse = sqrt(mse);
disp(['Mean Squared Error (MSE): ' num2str(mse)]);
disp(['Root Mean Squared Error (RMSE): ' num2str(rmse)]);
%% --------------------------------- Plot results ---------------------------------
figure;
subplot(1,1,1);    % Plot Original Data and Filtered Signal
plot(t, data); hold on;
plot(t, x_hat);
title(['MSE:' num2str(mse),'; RMSE:' num2str(rmse)]);
legend('Original Data', 'Filtered Signal');
xlabel('Time (s)');
ylabel('Amplitude');

figure;
subplot(4,1,1);    % Plot Adaptive Covariance
plot(t, P);
title('Adaptive Covariance');
xlabel('Time (s)');
ylabel('Covariance');
subplot(4,1,2);    % Plot Estimation Error
plot(t, estimation_error);
title('Estimation Error');
xlabel('Time (s)');
ylabel('Error');
subplot(4,1,3);    % Plot State Variance
plot(t, state_variance);
title('State Variance');
xlabel('Time (s)');
ylabel('Variance');
subplot(4,1,4);    % Plot Innovation
plot(t, innovation); hold on;
plot(t, R * ones(size(t)));
title('Innovation and Estimated R');
xlabel('Time (s)');
ylabel('Innovation / R Estimate');
legend('Innovation', 'Estimated R');