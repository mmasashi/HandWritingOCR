clear ; close all; clc
ml_dir_path = genpath(fileparts(mfilename('fullpathext')));
addpath(ml_dir_path);

arg_list = argv();
data_path = arg_list{1};
if size(arg_list, 1) > 1
  all_theta_path = arg_list{2};
  else
  all_theta_path = strcat(ml_dir_path, "/ocr_theta.csv");
end

all_theta = csvread(all_theta_path);
data = csvread(data_path);

m = size(data, 1);
n = size(data, 2) - 1;
X = data(:, 1:n);
y = data(:, n+1);
pred = predictOneVsAll(all_theta, X);
printf("%d\n", pred(1,1));
