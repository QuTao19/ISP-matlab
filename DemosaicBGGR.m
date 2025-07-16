function [imw_image] = DemosaicBGGR(bayerArray, width, height)
% DemosaicBGGR: 使用双线性插值对 BGGR 拜尔阵列进行去马赛克
%
% 输入:
%   bayerArray - 一个 height x width 的矩阵，包含原始的拜尔数据
%   width      - 图像宽度
%   height     - 图像高度
%
% 输出:
%   imw_image  - 一个 height x width x 3 的 uint8 RGB 图像

    % 创建一个更大的矩阵以处理边界，避免在循环中进行边界检查
    % 使用 double 类型进行计算以保证精度
    bayer_padded = double(zeros(height + 2, width + 2));
    bayer_padded(2:height+1, 2:width+1) = bayerArray;

    % 补全矩阵边界空白信息（镜像法）
    bayer_padded(1,:) = bayer_padded(3,:);
    bayer_padded(height+2,:) = bayer_padded(height,:);
    bayer_padded(:,1) = bayer_padded(:,3);
    bayer_padded(:,width+2) = bayer_padded(:,width);

    % 初始化输出的 RGB 图像
    RGB_image = double(zeros(height + 2, width + 2, 3));

    % 遍历每个像素进行插值
    for ver = 2:height+1
        for hor = 2:width+1
            % 判断当前像素位置 (奇数行/偶数行, 奇数列/偶数列)
            is_odd_row = (1 == mod(ver-1, 2));
            is_odd_col = (1 == mod(hor-1, 2));

            if (is_odd_row && is_odd_col) % 位置 (奇, 奇) -> B 像素
                % B通道为原始值
                RGB_image(ver,hor,3) = bayer_padded(ver,hor);
                % G通道为上下左右4个G像素的均值
                RGB_image(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                % R通道为对角线4个R像素的均值
                RGB_image(ver,hor,1) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;

            elseif (~is_odd_row && ~is_odd_col) % 位置 (偶, 偶) -> R 像素
                % R通道为原始值
                RGB_image(ver,hor,1) = bayer_padded(ver,hor);
                % G通道为上下左右4个G像素的均值
                RGB_image(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                % B通道为对角线4个B像素的均值
                RGB_image(ver,hor,3) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;

            elseif (is_odd_row && ~is_odd_col) % 位置 (奇, 偶) -> G 像素 (在 B 行)
                % G通道为原始值
                RGB_image(ver,hor,2) = bayer_padded(ver,hor);
                % B通道为左右2个B像素的均值
                RGB_image(ver,hor,3) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                % R通道为上下2个R像素的均值
                RGB_image(ver,hor,1) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;

            else % 位置 (偶, 奇) -> G 像素 (在 R 行)
                % G通道为原始值
                RGB_image(ver,hor,2) = bayer_padded(ver,hor);
                % B通道为上下2个B像素的均值
                RGB_image(ver,hor,3) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                % R通道为左右2个R像素的均值
                RGB_image(ver,hor,1) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
            end
        end
    end

    % 裁剪图像，去除边界
    RGB_image_cropped = RGB_image(2:height+1, 2:width+1, :);

    % 归一化到 [0, 1] 区间 (可选，但对于显示很关键)
    % 检查图像是否为空或常量
    min_val = min(RGB_image_cropped(:));
    max_val = max(RGB_image_cropped(:));
    if (max_val - min_val) > 0
        Nor_image = (RGB_image_cropped - min_val) / (max_val - min_val);
    else
        Nor_image = zeros(size(RGB_image_cropped)); % 或者处理为全黑/全白
    end
    
    % 转换为 uint8 类型 ([0, 255])
    imw_image = im2uint8(Nor_image);
end