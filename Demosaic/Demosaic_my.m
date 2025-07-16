function [RGB_image] = Demosaic_my(bayerArray, pattern)
% Demosaic: 使用双线性插值对拜尔阵列进行去马赛克
%
% 输入:
%   bayerArray - 一个 height x width 的矩阵，包含原始的拜尔数据
%   pattern    - 拜尔格式, 'rggb' 或 'bggr'
%
% 输出:
%   RGB_image  - 一个 height x width x 3 的 RGB 图像，数据类型与输入一致

    [height, width] = size(bayerArray);
    input_class = class(bayerArray);

    % 使用 double 类型进行计算以保证精度，并使用 'replicate' 方式填充边界
    bayer_padded = padarray(double(bayerArray), [1 1], 'replicate');

    % 初始化输出的 RGB 图像
    RGB_image_padded = double(zeros(height + 2, width + 2, 3));

    % 根据模式选择插值方法
    if strcmpi(pattern, 'rggb')
        % RGGB 插值逻辑
        for ver = 2:height+1
            for hor = 2:width+1
                is_odd_row = (mod(ver-1, 2) == 1);
                is_odd_col = (mod(hor-1, 2) == 1);

                if (is_odd_row && is_odd_col) % 位置 (奇, 奇) -> R 像素
                    RGB_image_padded(ver,hor,1) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                elseif (~is_odd_row && ~is_odd_col) % 位置 (偶, 偶) -> B 像素
                    RGB_image_padded(ver,hor,3) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                elseif (is_odd_row && ~is_odd_col) % 位置 (奇, 偶) -> G 像素 (在 R 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                else % 位置 (偶, 奇) -> G 像素 (在 B 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                end
            end
        end
    elseif strcmpi(pattern, 'bggr')
        % BGGR 插值逻辑
        for ver = 2:height+1
            for hor = 2:width+1
                is_odd_row = (mod(ver-1, 2) == 1);
                is_odd_col = (mod(hor-1, 2) == 1);

                if (is_odd_row && is_odd_col) % 位置 (奇, 奇) -> B 像素
                    RGB_image_padded(ver,hor,3) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                elseif (~is_odd_row && ~is_odd_col) % 位置 (偶, 偶) -> R 像素
                    RGB_image_padded(ver,hor,1) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                elseif (is_odd_row && ~is_odd_col) % 位置 (奇, 偶) -> G 像素 (在 B 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                else % 位置 (偶, 奇) -> G 像素 (在 R 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                end
            end
        end
    elseif strcmpi(pattern, 'gbrg') % 新增 GBRG 逻辑
        % G B
        % R G
        for ver = 2:height+1
            for hor = 2:width+1
                is_odd_row = (mod(ver-1, 2) == 1);
                is_odd_col = (mod(hor-1, 2) == 1);

                if (is_odd_row && is_odd_col) % 位置 (奇, 奇) -> G 像素 (在 B 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                elseif (~is_odd_row && ~is_odd_col) % 位置 (偶, 偶) -> G 像素 (在 R 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                elseif (is_odd_row && ~is_odd_col) % 位置 (奇, 偶) -> B 像素
                    RGB_image_padded(ver,hor,3) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                else % 位置 (偶, 奇) -> R 像素
                    RGB_image_padded(ver,hor,1) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                end
            end
        end
    elseif strcmpi(pattern, 'grbg') % 新增 GRBG 逻辑
        % G R
        % B G
        for ver = 2:height+1
            for hor = 2:width+1
                is_odd_row = (mod(ver-1, 2) == 1);
                is_odd_col = (mod(hor-1, 2) == 1);

                if (is_odd_row && is_odd_col) % 位置 (奇, 奇) -> G 像素 (在 R 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                elseif (~is_odd_row && ~is_odd_col) % 位置 (偶, 偶) -> G 像素 (在 B 行)
                    RGB_image_padded(ver,hor,2) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor)) / 2;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 2;
                elseif (is_odd_row && ~is_odd_col) % 位置 (奇, 偶) -> R 像素
                    RGB_image_padded(ver,hor,1) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,3) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                else % 位置 (偶, 奇) -> B 像素
                    RGB_image_padded(ver,hor,3) = bayer_padded(ver,hor);
                    RGB_image_padded(ver,hor,2) = (bayer_padded(ver-1,hor) + bayer_padded(ver+1,hor) + bayer_padded(ver,hor-1) + bayer_padded(ver,hor+1)) / 4;
                    RGB_image_padded(ver,hor,1) = (bayer_padded(ver-1,hor-1) + bayer_padded(ver-1,hor+1) + bayer_padded(ver+1,hor-1) + bayer_padded(ver+1,hor+1)) / 4;
                end
            end
        end
    else
        error('Unsupported Bayer pattern. Use ''rggb'' or ''bggr''.');
    end

    % 裁剪图像，去除边界
    RGB_image_cropped = RGB_image_padded(2:height+1, 2:width+1, :);

    % 转换回原始数据类型
    RGB_image_unscaled = cast(RGB_image_cropped, input_class);

    % 如果输出是 double 类型，则归一化到 [0, 1] 范围用于显示
    min_val = min(RGB_image_unscaled(:));
    max_val = max(RGB_image_unscaled(:));
    if (max_val - min_val) > 0
        RGB_image = (RGB_image_unscaled - min_val) / (max_val - min_val);
    else
        RGB_image = zeros(size(RGB_image_unscaled)); % 如果图像是常量，则返回黑图
    end

    RGB_image = im2uint16(RGB_image);
end
