function avgRGB = extractGrayPatchValues(imagePath, patchRects, width, height)
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
%     img = im2double(imread(imagePath));
    fid = fopen(imagePath,"r");
    if fid == -1
        error('无法打开文件: %s', imagePath);
    end
    % 读取原始数据为一维向量
    img_vector = fread(fid, width * height * 3, 'uint16=>uint16');
    fclose(fid);
    
    % 检查是否读取了足够的数据
    if numel(img_vector) ~= width * height * 3
        error('文件大小与预期的图像尺寸不匹配。');
    end
    
    % 将一维向量重塑为三维图像矩阵
    % MATLAB 按列读取和写入，因此数据在内存中是按通道连续存储的 (RRR...GGG...BBB...)
    % 我们先将其重塑为 (height, width, 3)
    img = reshape(img_vector, [height, width, 3]);
    
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
    avgRGB = mean(double(allGrayPixels), 1);
end