function avgRGB = extractGrayPatchValues(imagePath, patchRects)
% 从给定的图像中，根据指定的矩形区域提取所有灰色块的平均RGB值。
%
% 输入:
%   imagePath - 图像文件的路径。
%   patchRects - 一个 cell 数组，每个元素是一个 [x, y, width, height] 格式的矩形，
%                代表一个灰色块的位置。
%
% 输出:
%   avgRGB - 一个 [R, G, B] 向量，代表所有灰色块的平均颜色。

    % 读取图像并转换为 double 类型以便计算
    img = im2double(imread(imagePath));
    
    % 初始化用于存储所有灰色像素的变量
    allGrayPixels = [];
    
    % 遍历所有指定的灰色块区域
    for i = 1:length(patchRects)
        rect = patchRects{i};
        % 裁剪出当前的灰色块图像
        patch = imcrop(img, rect);
        
        % 将 3D 图像块重塑为像素列表 (N x 3)
        [h, w, ~] = size(patch);
        pixelList = reshape(patch, h * w, 3);
        
        % 将当前块的像素附加到总列表中
        allGrayPixels = [allGrayPixels; pixelList];
    end
    
    % 计算所有灰色像素的平均 RGB 值
    avgRGB = mean(allGrayPixels, 1);
end