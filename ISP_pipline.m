clear;
clc;
close all; % 关闭所有之前的图像窗口

%% 1. 设置环境和参数
% -------------------------------------------------------------------------
% 将子模块文件夹添加到 MATLAB 路径
addpath('BLC/');
addpath('Demosaic/');
addpath('AWB/');

% 图像基本信息
width = 6000;
height = 4000;
bayer_pattern = 'gbrg'; % 根据您的 sensor 设置

% 输入文件路径 (选择一张原始图像进行处理)
% input_filepath = 'pic/rkisp_sc2210_CWF_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195932676.raw';
input_filepath = 'pic/IMG_9516_cropped_6000x4000.raw';

fprintf('ISP Pipline 开始...\n');
fprintf('输入文件: %s\n', input_filepath);

%% 2. 加载数据
% -------------------------------------------------------------------------
% 加载 AWB 校准数据
fprintf('加载校准数据...\n');
load('calibration_data.mat', 'p_coeffs');

% 读取原始 RAW 图像
fid = fopen(input_filepath, 'r');
if fid == -1
    error('无法打开文件: %s', input_filepath);
end
% 原始数据是 12-bit，存储在 uint16 中
raw_image_vector = fread(fid, [width, height], 'uint16=>uint16');
fclose(fid);

% 将图像旋转和翻转以匹配正确的方向
bayer_raw = rot90(raw_image_vector, 3);
bayer_raw = flip(bayer_raw, 2);

fprintf('成功加载原始 RAW 图像。\n');

%% 3. ISP 处理流程
% -------------------------------------------------------------------------
% --- 步骤 1: BLC (黑电平校正) ---
% BLC 参数
black_level = 0; 
bayer_blc = double(bayer_raw) - black_level;
bayer_blc(bayer_blc < 0) = 0;
fprintf('BLC 完成。\n');

% --- 步骤 2: Demosaic (去马赛克) ---
% 调用您的去马赛克函数
img_demosaiced = Demosaic_my(bayer_blc, bayer_pattern);
fprintf('Demosaic 完成。\n');

% --- 步骤 3: AWB (自动白平衡) ---
% 调用您的白平衡校正函数
img_awb = correctBalanceWithCurve(img_demosaiced, p_coeffs);
fprintf('步骤 3: AWB 完成。\n');

fprintf('ISP Pipline 处理完成！\n');

%% 4. 显示结果
% -------------------------------------------------------------------------
figure;
% 显示原始去马赛克后的图像 (应用了BLC但未应用AWB)
subplot(1, 2, 1);
imshow(img_demosaiced, []);
title('处理前 (Demosaic only)');

% 显示经过完整 ISP 流程处理后的图像
subplot(1, 2, 2);
imshow(img_awb, []);
title('处理后 (BLC + Demosaic + AWB)');