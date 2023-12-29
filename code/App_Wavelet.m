clc; clear; close all;
%% Load data
fs = 1000;
time = 0:1/fs:2;
signal = sin(2*pi*50*time) + 0.5*sin(2*pi*120*time) + 0.2*sin(2*pi*200*time);
noise = 0.5 * randn(size(time)); % Gaussian noise with standard deviation 0.5
data = signal + noise;
%% design wavelet
wname='db4';
nLevel=3;
Threshold_selection_Rule = 'rigrsure';  % 'heursure';'sqtwolog';'minimaxi'
Threshold_Type='s';                     % 'h'
display_fig = "on";                     % on or off

output= Wavelet(data, wname, nLevel,Threshold_selection_Rule,Threshold_Type, display_fig);
