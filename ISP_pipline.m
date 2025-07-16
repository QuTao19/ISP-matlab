clear;
clc;
%% 图像的基本信息：
% 1080行，1920列，像素深度12bit.

width = 1920;
height = 1080;
filepath = 'D:\project\Matlab Code\ISP\pictures_sources\CCM_AWB\';
filename_A = 'rkisp_sc2210_A_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195859760.raw';
filename_TL84 = 'rkisp_sc2210_TL84_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195921565.raw';
filename_CWF = 'rkisp_sc2210_CWF_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195932676.raw';
filename_D50 = 'rkisp_sc2210_D50_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_195950965.raw';
filename_D65 = 'rkisp_sc2210_D65_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_200001828.raw';
filename_D75 = 'rkisp_sc2210_D75_1920_1080_12bpp_1.0x_0.010s_normal_normL_single_20011284.raw';

fileA = strcat(filepath,filename_A);
fidA = fopen(fileA,'r');
image = fread(fidA,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidA);
bayer_image_A = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_A = flip(bayer_image_A,2);%对图像进行水平翻转

fileTL84 = strcat(filepath,filename_TL84);
fidTL84 = fopen(fileTL84,'r');
image = fread(fidTL84,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidTL84);
bayer_image_TL84 = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_TL84 = flip(bayer_image_TL84,2);%对图像进行水平翻转

fileCWF = strcat(filepath,filename_CWF);
fidCWF = fopen(fileCWF,'r');
image = fread(fidCWF,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidCWF);
bayer_image_CWF = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_CWF = flip(bayer_image_CWF,2);%对图像进行水平翻转

fileD50 = strcat(filepath,filename_D50);
fidD50 = fopen(fileD50,'r');
image = fread(fidD50,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidD50);
bayer_image_D50 = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_D50 = flip(bayer_image_D50,2);%对图像进行水平翻转

fileD65 = strcat(filepath,filename_D65);
fidD65 = fopen(fileD65,'r');
image = fread(fidD65,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidD65);
bayer_image_D65 = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_D65 = flip(bayer_image_D65,2);%对图像进行水平翻转

fileD75 = strcat(filepath,filename_D75);
fidD75 = fopen(fileD75,'r');
image = fread(fidD75,[width,height],'uint16');%将文件读取到矩阵[width,height]中，以uint16读取
fclose(fidD75);
bayer_image_D75 = rot90(image,3);%将图像逆时针旋转3*90°
bayer_image_D75 = flip(bayer_image_D75,2);%对图像进行水平翻转


%% Demosaic interpolation
% Sensor SC2210 ---- BGGR Array
Nor_image_A = DemosaicBGGR(bayer_image_A, width, height);
% 3. 交换红色通道 (第1层) 和蓝色通道 (第3层)
subplot(231),imshow(Nor_image_A); title("A");
imwrite(Nor_image_A,'path/A_source_image.jpg','jpg');

Nor_image_TL84 = DemosaicBGGR(bayer_image_TL84, width, height);
subplot(232),imshow(Nor_image_TL84); title("TL84");
imwrite(Nor_image_TL84,'path/TL84_source_image.jpg','jpg');

Nor_image_CWF = DemosaicBGGR(bayer_image_CWF, width, height);
subplot(233),imshow(Nor_image_CWF); title("CWF");
imwrite(Nor_image_CWF,'path/CWF_source_image.jpg','jpg');

Nor_image_D50 = DemosaicBGGR(bayer_image_D50, width, height);
subplot(234),imshow(Nor_image_D50); title("D50");
imwrite(Nor_image_D50,'path/D50_source_image.jpg','jpg');

Nor_image_D65 = DemosaicBGGR(bayer_image_D65, width, height);
subplot(235),imshow(Nor_image_D65); title("D65");
imwrite(Nor_image_D65,'path/D65_source_image.jpg','jpg');

Nor_image_D75 = DemosaicBGGR(bayer_image_D75, width, height);
subplot(236),imshow(Nor_image_D75); title("D75");
imwrite(Nor_image_D75,'path/D75_source_image.jpg','jpg');

