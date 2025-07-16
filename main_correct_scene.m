% =========================================================================
% main_correct_scene.m - 使用已建立的白点曲线对新场景进行白平衡
% =========================================================================
clear; clc; close all;

%% 1. 加载校准数据
if ~exist('calibration_data.mat', 'file')
    error('错误: 未找到校准文件 calibration_data.mat。请先运行 main_calibrate.m。');
end
fprintf('加载校准数据...\n');
load('calibration_data.mat', 'p_coeffs');

%% 2. 加载待校正的图像
% TODO: 将此路径替换为您想要校正的图像的路径
scene_image_path = 'correct/A_source_image.jpg';
original_img = im2double(imread(scene_image_path));

%% 3. 执行白平衡校正
fprintf('开始进行白平衡校正...\n');
corrected_img = correctBalanceWithCurve(original_img, p_coeffs);
fprintf('校正完成。\n');

%% 4. 显示结果
figure;
subplot(1, 2, 1);
imshow(original_img);
title('原始图像');

subplot(1, 2, 2);
imshow(corrected_img);
title('白平衡校正后图像');