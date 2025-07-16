% =========================================================================
% calculate_black_level_from_binary_raw.m
% 从二进制 .raw 文件计算黑电平值
% =========================================================================
clear; clc; close all;

%% 1. 配置参数 (TODO: 这是您必须修改的部分)

% --- 输入文件路径 ---
filePaths = {
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_220732752.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_2.0x_0.010s_normal_normL_single_220847242.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_4.0x_0.010s_normal_normL_single_220859379.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_8.0x_0.010s_normal_normL_single_220911365.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_16.0x_0.010s_normal_normL_single_220921988.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_32.0x_0.010s_normal_normL_single_220931525.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_64.0x_0.010s_normal_normL_single_220942999.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_128.0x_0.010s_normal_normL_single_220957420.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_256.0x_0.010s_normal_normL_single_221010325.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_512.0x_0.010s_normal_normL_single_221024725.raw', ...
    'BLC_pic/rkisp_sc2210_Unknow_1920_1080_12bpp_1024.0x_0.010s_normal_normL_single_221038436.raw', ...
};

% --- RAW 文件元数据 ---
% !! 以下参数至关重要，必须根据您的数据进行正确设置 !!
imageWidth   = 1920;       % 图像的像素宽度
imageHeight  = 1080;       % 图像的像素高度
dataType     = 'uint16';   % 每个像素的数据类型 ('uint8', 'uint16', 'single', etc.)
endianness   = 'l';        % 字节序: 'l' 代表小端序 (Little-Endian, 最常用)
                           %           'b' 代表大端序 (Big-Endian)

% --- 传感器拜耳阵列模式 ---
% 'rggb', 'bggr', 'gbrg', 'grbg'
bayerPattern = 'rggb';

%% 2. 逐一处理黑场图像并计算各通道均值

numFiles = length(filePaths);
if numFiles == 0
    error('错误: 请在 filePaths 中至少提供一个文件路径。');
end

per_file_black_levels = zeros(numFiles, 3);
fprintf('开始处理二进制 .raw 黑场文件...\n');

for i = 1:numFiles
    filePath = filePaths{i};
    fprintf('  正在读取文件: %s\n', filePath);
    
    % --- 使用底层 I/O 函数读取二进制 .raw 文件 ---
    fileID = fopen(filePath, 'r');
    if fileID == -1
        error('无法打开文件: %s。请检查路径是否正确。', filePath);
    end
    
    % 将二进制数据读入一个一维向量中
    % '=>double' 的意思是读取时按指定类型(dataType)，存入内存时转换为double类型
    raw_vector = fread(fileID, inf, [dataType '=>double'], endianness);
    
    fclose(fileID);
    
    % --- 验证文件大小是否与预设尺寸匹配 ---
    expected_pixels = imageWidth * imageHeight;
    actual_pixels = numel(raw_vector);
    
    if actual_pixels ~= expected_pixels
        error(['文件 "%s" 的像素数量 (%d) 与预设尺寸 (%d x %d = %d) 不匹配。\n' ...
               '请仔细检查 imageWidth, imageHeight 和 dataType 设置是否正确。'], ...
               filePath, actual_pixels, imageWidth, imageHeight, expected_pixels);
    end
    
    % --- 将一维向量重塑为二维图像矩阵 ---
    % MATLAB 是列主序存储，所以先按(宽,高)重塑，再转置，得到(高,宽)的矩阵
    raw_image = reshape(raw_vector, imageWidth, imageHeight)';
    
    % ----- 从这里开始，后续逻辑与之前的代码完全相同 -----
    
    % 获取图像尺寸
    [height, width] = size(raw_image);
    
    % 创建R, G, B通道的掩码
    mask_R = false(height, width);
    mask_G = false(height, width);
    mask_B = false(height, width);
    
    switch lower(bayerPattern)
        case 'rggb'
            mask_R(1:2:end, 1:2:end) = true;
            mask_G(1:2:end, 2:2:end) = true;
            mask_G(2:2:end, 1:2:end) = true;
            mask_B(2:2:end, 2:2:end) = true;
        case 'bggr'
            % ... (其他模式的逻辑与之前代码相同) ...
            mask_B(1:2:end, 1:2:end) = true;
            mask_G(1:2:end, 2:2:end) = true;
            mask_G(2:2:end, 1:2:end) = true;
            mask_R(2:2:end, 2:2:end) = true;
        otherwise
            error('不支持的拜耳模式: %s', bayerPattern);
    end
    
    % 分别计算R, G, B通道像素的平均值
    bl_R = mean(raw_image(mask_R));
    bl_G = mean(raw_image(mask_G));
    bl_B = mean(raw_image(mask_B));
    
    per_file_black_levels(i, :) = [bl_R, bl_G, bl_B];
end

%% 3. 计算最终的平均黑电平值并显示结果
% (这部分代码与之前完全相同，无需修改)
final_black_level = mean(per_file_black_levels, 1);

fprintf('\n------------------ 计算结果 ------------------\n');
fprintf('处理了 %d 个黑场文件。\n\n', numFiles);

disp('每个文件计算出的黑电平值 [R, G, B]:');
disp(per_file_black_levels);

fprintf('\n最终平均黑电平值 (Final Black Level):\n');
fprintf('  R 通道: %.4f\n', final_black_level(1));
fprintf('  G 通道: %.4f\n', final_black_level(2));
fprintf('  B 通道: %.4f\n', final_black_level(3));
fprintf('----------------------------------------------\n');