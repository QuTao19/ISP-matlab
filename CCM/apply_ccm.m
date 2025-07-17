function img_ccm = apply_ccm(img, ccm)
% APPLY_CCM 应用色彩校正矩阵
%
%   img_ccm = APPLY_CCM(img, ccm) 对输入图像 img 应用色彩校正矩阵 ccm。
%   img: 输入图像，uint16 类型，3 通道
%   ccm: 3x3 的色彩校正矩阵
%
%   返回应用色彩校正后的 uint16 图像。

    % 确保输入是 double 类型以进行精确计算
    img_double = double(img);
    
    % 获取图像尺寸
    [rows, cols, ~] = size(img_double);
    
    % 将图像重塑为像素列表 [R, G, B]
    pixels = reshape(img_double, [], 3);
    
    % 应用 CCM 矩阵
    % 注意：(ccm * pixels')' 等效于 pixels * ccm'
    corrected_pixels = pixels * ccm';
    
    % 将像素值限制在 uint16 的有效范围内 [0, 65535]
    corrected_pixels(corrected_pixels < 0) = 0;
    corrected_pixels(corrected_pixels > 65535) = 65535;
    
    % 将像素列表重塑回图像尺寸
    img_ccm_double = reshape(corrected_pixels, rows, cols, 3);
    
    % 将结果转换回 uint16 类型
    img_ccm = uint16(img_ccm_double);
end