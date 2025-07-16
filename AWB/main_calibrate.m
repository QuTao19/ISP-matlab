% =========================================================================
% main_calibrate.m - 建立相机白点色温曲线
% =========================================================================
clear; clc; close all;
width = 1920;
height = 1080;
%% 1. 定义常量和参数

% TODO: 请根据您的文件存放位置修改这些路径
imagePaths = {
    'after_demosaic/A_source_image.raw', ...
    'after_demosaic/TL84_source_image.raw', ...
    'after_demosaic/CWF_source_image.raw', ...
    'after_demosaic/D50_source_image.raw', ...
    'after_demosaic/D65_source_image.raw', ...
    'after_demosaic/D75_source_image.raw'
};

illuminantNames = {'A', 'TL84', 'CWF', 'D50', 'D65', 'D75'};


% TODO: 这是非常重要的一步！
% 您需要使用 GIMP, Photoshop, 或者 MATLAB 的 imrect 工具来手动确定
% 每张图上6个灰色块的位置 [x, y, width, height]。
% 为了简化，这里假设所有图像的色卡位置都相同。如果不同，您需要为每张图定义一套。
% 灰色块通常是色卡最下面一行的6个。
grayPatchRects = {
    [355, 800, 100, 100], ... % 第1个灰色块 (白色)
    [535, 800, 100, 100], ... % 第2个灰色块
    [735, 800, 100, 100], ... % 第3个灰色块
    [935, 800, 100, 100], ... % 第4个灰色块
    [1135, 800, 100, 100], ... % 第5个灰色块
    [1335, 800, 100, 100]  ... % 第6个灰色块 (黑色)
};

%% 2. 从每张校准图像中提取白点 (平均灰色值)

fprintf('开始从校准图像中提取白点...\n');
numImages = length(imagePaths);
whitePoints = zeros(numImages, 3); % 用于存储 [R, G, B]

for i = 1:numImages
    fprintf('处理图像: %s\n', illuminantNames{i});
    whitePoints(i, :) = extractGrayPatchValues(imagePaths{i}, grayPatchRects, width, height);
end

% for i = 1:numImages
%     fprintf('处理图像: %s\n', illuminantNames{i});
%     
%     % ======================================================
%     % --- 新增的可视化代码开始 ---
%     % 为了调试，读取并显示当前图像，并在其上绘制定义的矩形框
%     
%     img_for_display = imread(imagePaths{i});
%     
%     figure; % 为每一张校准图创建一个新的图形窗口
%     imshow(img_for_display);
%     hold on;
%     
%     % 设置标题，方便辨认
%     title(['调试视图: ' illuminantNames{i} ' - 灰色块选区'], 'FontSize', 14);
%     
%     % 循环遍历所有灰色块的定义，并用红色虚线框画出来
%     for j = 1:length(grayPatchRects)
%         rectangle('Position', grayPatchRects{j}, ...
%                   'EdgeColor', 'r', ...      % 框的颜色为红色
%                   'LineWidth', 2, ...         % 线宽为2
%                   'LineStyle', '--');       % 线型为虚线
%     end
%     
%     hold off;
%     drawnow; % 强制MATLAB立即更新并显示图像窗口
%     
%     % --- 新增的可视化代码结束 ---
%     % ======================================================
% 
%     % 调用函数提取白点值的代码保持不变
%     whitePoints(i, :) = extractGrayPatchValues(imagePaths{i}, grayPatchRects);
% end

fprintf('白点提取完成。\n');
disp('提取到的各光源下的白点 (R, G, B):');
disp(whitePoints);

%% 3. 拟合白点色温曲线
% 白平衡通常在色度空间中进行操作，以消除亮度的影响。
% 我们使用以G通道为基准的 rg 色度空间: r = R/G, b = B/G

R = whitePoints(:, 1);
G = whitePoints(:, 2);
B = whitePoints(:, 3);

rg_chromaticity = [R./G, B./G];

% 使用 r = f(b) 的形式拟合一条二次多项式曲线
% 这是模拟普朗克轨迹在相机传感器上的表现
p_coeffs = polyfit(rg_chromaticity(:, 2), rg_chromaticity(:, 1), 2); % 2次多项式

fprintf('白点色温曲线拟合完成。\n');
fprintf('拟合出的二次多项式系数 (p2*b^2 + p1*b + p0): \n');
disp(p_coeffs);

%% 4. 可视化拟合结果

figure;
hold on;
grid on;
box on;

% 绘制原始的白点
plot(rg_chromaticity(:, 2), rg_chromaticity(:, 1), 'ro', 'MarkerFaceColor', 'r', 'DisplayName', '原始白点');
text(rg_chromaticity(:, 2)+0.01, rg_chromaticity(:, 1), illuminantNames);

% 绘制拟合的曲线
b_fit = linspace(min(rg_chromaticity(:,2))*0.9, max(rg_chromaticity(:,2))*1.1, 100);
r_fit = polyval(p_coeffs, b_fit);
plot(b_fit, r_fit, 'b-', 'LineWidth', 2, 'DisplayName', '拟合的白点曲线');

title('相机白点色温曲线 (在rg色度空间)');
xlabel('b chromaticity (B/G)');
ylabel('r chromaticity (R/G)');
legend('show');
axis equal;
hold off;

%% 5. 保存校准结果以备后用
fprintf('正在保存校准数据到 calibration_data.mat...\n');
save('calibration_data.mat', 'p_coeffs');
fprintf('校准完成！\n');