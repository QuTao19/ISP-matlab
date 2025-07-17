clear;
clc;
close all; % 关闭所有之前的图像窗口

%% 1. 设置环境和参数
% -------------------------------------------------------------------------
% 将子模块文件夹添加到 MATLAB 路径
addpath('BLC/');
addpath('Demosaic/');
addpath('AWB/');
addpath("CCM/");
addpath('Gamma/');

% 图像基本信息
width = 1920;
height = 1080;
bayer_pattern = 'bggr'; % 根据您的 sensor 设置

% 输入文件路径 (选择一张原始图像进行处理)
% input_filepath = 'pic/rkisp_sc2210_CWF_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195932676.raw';
input_filepath = 'pic/rkisp_sc2210_CWF_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195932676.raw';

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
fprintf('AWB 完成。\n');

% --- 步骤 5: Gamma 校正 ---
gamma_value = 2.2; % 常用的 Gamma 值
img_gamma = apply_gamma(img_awb, gamma_value);
fprintf('Gamma 校正完成。\n');

% --- 步骤 4: CCM (色彩校正矩阵) ---
% 注意: 这个 CCM 矩阵是一个示例，您需要根据您的相机传感器进行校准
ccm = [ 1.769, -0.696, -0.07;
       -0.416,  1.875,  -0.458;
        0.006, -0.767,  1.761];
img_ccm = apply_ccm(img_gamma, ccm);
fprintf('CCM 完成。\n');

imwrite(img_ccm,"pic\sc2210.tif","tif");

% % --- 步骤 5: Gamma 校正 ---
% gamma_value = 2.2; % 常用的 Gamma 值
% img_gamma = apply_gamma(img_ccm, gamma_value);
% fprintf('Gamma 校正完成。\n');

%% 4. 显示结果
% -------------------------------------------------------------------------
figure;
% 原始图像
subplot(2, 2, 1);
imshow(img_demosaiced, []);
title('Demosaic');

% 显示原始去马赛克后的图像(应用了BLC但未应用AWB)
subplot(2, 2, 2);
imshow(img_awb, []);
title('AWB');

% 显示经过 AWB 处理后的图像
subplot(2, 2, 3);
imshow(img_ccm, []);
title('CCM');

% 显示经过完整ISP流程处理后的图像
subplot(2, 2, 4);
imshow(img_gamma, []);
title('Gamma');

% figure;
% imshow(img_gamma, []);
% title('处理后');