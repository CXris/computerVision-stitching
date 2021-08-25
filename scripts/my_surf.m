% 输入：
% img1：(H*W*3)的图1。
% img2：(H*W*3)的图2。
% 
% 输出：
% out：img1和img2线性融合的拼接结果。

function out=my_surf(img1,img2)

% 角点检测
gray_img1=rgb2gray(img1);
gray_img2=rgb2gray(img2);
imageSize=size(gray_img1);

p1=detectSURFFeatures(gray_img1);
p2=detectSURFFeatures(gray_img2);

% 生成描述子
[img1Features, p1] = extractFeatures(gray_img1, p1);
[img2Features, p2] = extractFeatures(gray_img2, p2);

% 匹配角点
boxPairs = matchFeatures(img1Features, img2Features);
matchedimg1Points = p1(boxPairs(:, 1));
matchedimg2Points = p2(boxPairs(:, 2));

% RANSAC
[tform, inlierimg2Points, inlierimg1Points] = estimateGeometricTransform(matchedimg2Points, matchedimg1Points, 'projective');%射影变换，tfrom映射点对1内点到点对2内点
% 该函数使用随机样本一致性（RANSAC）算法的变体MSAC算法实现，去除误匹配点
% The returned geometric transformation matrix maps the inliers in matchedPoints1
% to the inliers in matchedPoints2.返回的几何映射矩阵映射第一参数内点到第二参数内点

showMatchedFeatures(img1, img2, inlierimg1Points,inlierimg2Points, 'montage');
title('SURF描述符 RANSAC方法 匹配结果')

% 拼接
[xlim, ylim] = outputLimits(tform, [1 imageSize(2)], [1 imageSize(1)]);
% 找到输出空间限制的最大最小值
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% 全景图的宽高
width  = round(xMax - xMin);
height = round(yMax - yMin);

% 创建2D空间参考对象定义全景图尺寸
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width ], xLimits, yLimits);

% 变换图片到全景图
gray_img1 = imwarp(img1,projective2d(eye(3)), 'OutputView', panoramaView);
gray_img2 = imwarp(img2, tform, 'OutputView', panoramaView);

[~,out,~]=linear_blend(gray_img1,gray_img2);