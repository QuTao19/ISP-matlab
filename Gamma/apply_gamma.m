function img_gamma = apply_gamma(img, gamma)
% APPLY_GAMMA 应用伽马校正
%
%   img_gamma = APPLY_GAMMA(img, gamma) 对输入图像 img 应用伽马校正。
%   img: 输入图像，uint16 类型，3 通道
%   gamma: 伽马值
%
%   返回应用伽马校正后的 uint16 图像。

    % 将 uint16 图像转换为 double 类型并归一化到 [0, 1] 范围
    img_normalized = double(img) / 65535.0;
    
    % 应用伽马校正
    img_gamma_corrected = img_normalized .^ (1/gamma);
    
    % 将范围转换回 [0, 65535] 并转换为 uint16
    img_gamma = uint16(img_gamma_corrected * 65535.0);
end
