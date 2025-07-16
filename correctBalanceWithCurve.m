function corrected_img = correctBalanceWithCurve(img, curve_coeffs)
% 使用白点色温曲线对图像进行自动白平衡校正。
%
% 输入:
%   img - 待校正的原始图像 (RGB, double类型, 范围 [0, 1])
%   curve_coeffs - 校准得到的白点曲线多项式系数
%
% 输出:
%   corrected_img - 白平衡校正后的图像

    %% 1. 估计当前场景的光源色度
    % 这里我们使用一个简单但常用的 "Gray World" (灰度世界) 假设的变种。
    % 我们计算图像中所有像素的平均 R, G, B 值来估计光源颜色。
    % 其他方法如 "White Patch" (完美反射体) 或 "Gray Edge" 也可以使用。
    
    illuminant_estimate = squeeze(mean(mean(img, 1), 2))'; % 得到 [R_avg, G_avg, B_avg]
    
    % 转换到 rg 色度空间
    est_r = illuminant_estimate(1) / illuminant_estimate(2);
    est_b = illuminant_estimate(3) / illuminant_estimate(2);
    
    %% 2. 在白点曲线上找到距离估计点最近的点
    % 我们需要找到曲线上的点 (b_curve, r_curve) 
    % 使得 (b_curve - est_b)^2 + (r_curve - est_r)^2 最小
    % 其中 r_curve = polyval(curve_coeffs, b_curve)
    
    % 定义距离的平方的函数
    dist_sq_func = @(b) (b - est_b).^2 + (polyval(curve_coeffs, b) - est_r).^2;
    
    % 使用 fminbnd 寻找最小化距离的 b 值
    % 设置一个合理的搜索范围，例如 [0.5, 2.0]
    b_on_curve = fminbnd(dist_sq_func, 0.5, 2.0);
    r_on_curve = polyval(curve_coeffs, b_on_curve);
    
    % 这个在曲线上的点 (r_on_curve, b_on_curve) 就是我们认为的场景真实光源色度
    target_illuminant_rg = [r_on_curve, b_on_curve];
    
    %% 3. 计算色彩增益
    % 我们的目标是将我们找到的光源 (r_on_curve, 1, b_on_curve) 映射到中性色 (1, 1, 1)
    % 增益 = 目标值 / 当前值
    gain_R = 1 / target_illuminant_rg(1);
    gain_G = 1 / 1; % G通道作为基准，增益为1
    gain_B = 1 / target_illuminant_rg(2);
    
    gains = [gain_R, gain_G, gain_B];
    
    % 可选：对增益进行归一化，防止校正后图像整体变亮或变暗
    gains = gains / norm(gains); % 或者 gains = gains / gains(2)
    
    %% 4. 应用增益到整个图像
    corrected_img = img;
    corrected_img(:,:,1) = corrected_img(:,:,1) * gains(1);
    corrected_img(:,:,2) = corrected_img(:,:,2) * gains(2);
    corrected_img(:,:,3) = corrected_img(:,:,3) * gains(3);
    
    %% 5. 裁剪像素值到 [0, 1] 范围
    corrected_img(corrected_img > 1) = 1;
    corrected_img(corrected_img < 0) = 0;

end