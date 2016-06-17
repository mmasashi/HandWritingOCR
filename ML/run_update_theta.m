%% Initialization
clear ; close all; clc
ml_dir_path = genpath(fileparts(mfilename('fullpathext')));
addpath(ml_dir_path);

input_layer_size  = 400;  % 20x20 Input Images of Digits
num_labels = 10;          % 10 labels, from 0 to 9

arg_list = argv();
data_path = arg_list{1};
all_theta_path = arg_list{2};

fprintf('Loading Data ...\n')
data = csvread(data_path);
m = size(data, 1);
n = size(data, 2) - 1;
X = data(:, 1:n);
y = data(:, n+1);

lambda = 0.1;
[all_theta] = oneVsAll(X, y, num_labels, lambda);

pred = predictOneVsAll(all_theta, X);

csvwrite(all_theta_path, all_theta);
