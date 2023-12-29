clc; clear; close all;
%% ---------------------------- Load data -------------------------------------
fs = 500;  
t = 0:1/fs:2; 
abr_signal = sin(2*pi*50*t) + sin(2*pi*120*t) + 0.5*sin(2*pi*200*t);
noise = 0.5 * randn(size(t)); % Gaussian noise with standard deviation 0.5
data = abr_signal + noise;
labels = [ones(500,1); 2*ones(501,1)];
num_sample = length(data);
%% ---------------------------- Morlet wavelet --------------------------------
center_frequency = 5; 
sampling_frequency = 100; 
time = -1:1/sampling_frequency:1;
sigma = 6 / (2 * pi * center_frequency);
morlet_Wavelet = exp(2i * pi * center_frequency * time) .* exp(-time.^2 / (2 * sigma^2));  % Morlet wavelet
%% ---------- Perform wavelet transformation using Morlet wavelet --------------
x_wavelet = real(conv(data, morlet_Wavelet, 'same')); % Transform the input data using Morlet wavelet
if size(x_wavelet,1)<size(x_wavelet,2);x_wavelet = x_wavelet';end
%% ------------- Split the data into training and testing sets ------------------
trainRatio = 0.7;
valRatio = 0.15;
testRatio = 0.15;
trainInd = 1:round(trainRatio * num_sample);
valInd = round(trainRatio * num_sample) + 1 : round((trainRatio + valRatio) * num_sample);
testInd = round((trainRatio + valRatio) * num_sample) + 1 : num_sample;

ind = randi([1 length(x_wavelet)],1,length(x_wavelet));
trainData = x_wavelet(trainInd, :);
labels = full(ind2vec(labels'))';
trainLabels = labels(trainInd, :);

valData = x_wavelet(valInd, :);
valLabels = labels(valInd, :);

testData = x_wavelet(testInd, :);
testLabels = labels(testInd, :);
% x_wavelet = x_wavelet(:,ind);
% labels(labels(ind));
%% -------------- Define the Wavelet Neural Network architecture ----------------
hidden_layerSize = [10, 10]; 
net = feedforwardnet(hidden_layerSize);
%% ------------------------- Train the Wavelet Neural Network -------------------
net.divideFcn = 'divideind';
net.divideParam.trainInd = trainInd;
net.divideParam.valInd = valInd;
net.divideParam.testInd = testInd;

net = train(net, trainData', trainLabels');
%% -------------------------- Evaluate the trained network ----------------------
y_pred =  vec2ind(net(testData'));
%% ---------------------------- Plot results ---------------------------------
confusionchart(vec2ind(testLabels'), y_pred);
title('Confusion Matrix');
figure;
subplot(211)
plot(time, real(morlet_Wavelet))
title("Morlet Wavelet")
subplot(212)
plot(real(x_wavelet))
title("raw data+morlet Wavelet")
xlim([0, length(x_wavelet)])

figure;
plot(labels(testInd),'s', 'LineWidth', 1);
hold on;
plot(y_pred, 'o', 'LineWidth', 1);
xlabel('Sample Index');
legend('True', 'Predict');

accuracy = sum(y_pred-vec2ind(testLabels')==0)/length(y_pred);
display(accuracy)
view(net)