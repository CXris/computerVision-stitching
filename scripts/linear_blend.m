% 输入：
% img1：(H*W*3)经过仿射变换过后的图1。
% img2：(H*W*3)经过仿射变换过后的图2。
% 
% 输出：
% temp_mask：img1和img2的重合区域。
% linear_blended_img：(H*W*3)重合区域比重相同融合结果。
% equally_weighted_blended_img：(H*W*3)重合区域线性融合结果。


function [temp_mask,linear_blended_img,equally_weighted_blended_img]=linear_blend(img1,img2)

%初始化
linear_blended_img1=double(img1);
linear_blended_img2=double(img2);
equally_weighted_blended_img1=double(img1);
equally_weighted_blended_img2=double(img2);

%确定融合区域
temp_mask1 = (linear_blended_img2(:,:,1)>0 |linear_blended_img2(:,:,2)>0 | linear_blended_img2(:,:,3)>0);%变换图像掩膜
temp_mask2 = (linear_blended_img1(:,:,1)>0 | linear_blended_img1(:,:,2)>0 | linear_blended_img1(:,:,3)>0);%非变换图像掩膜
temp_mask = and(temp_mask1,temp_mask2);%重叠区掩膜

%确定融合区域的左边界和右边界
[row,col] = find(temp_mask==1);
left = min(col);right = max(col);%获得重叠区左右范围
% up=min(row);down=max(row);

%创建比重相同融合mask
equally_weighted_mask = ones(size(temp_mask));
equally_weighted_mask(:,left:right) = repmat(linspace(0.5,0.5,right-left+1),size(equally_weighted_mask,1),1);%复制平铺矩阵
%计算每张图的重合区域像素值
equally_weighted_blended_img1(:,:,:) = equally_weighted_blended_img1(:,:,:).*equally_weighted_mask;
equally_weighted_blended_img2(:,:,:) = equally_weighted_blended_img2(:,:,:).*equally_weighted_mask;

linear_blend_mask = ones(size(temp_mask));
%创建线性融合mask1
linear_blend_mask(:,left:right) = repmat(linspace(1,0,right-left+1),size(linear_blend_mask,1),1);
% mask(up:down,:) = repmat(linspace(0,1,down-up+1)',1,size(mask,2));%复制平铺矩阵
%计算每张图的重合区域像素值
linear_blended_img1(:,:,:) = linear_blended_img1(:,:,:).*linear_blend_mask;
%创建线性融合mask2
linear_blend_mask(:,left:right) = repmat(linspace(0,1,right-left+1),size(linear_blend_mask,1),1);%复制平铺矩阵
% mask(up:down,:) = repmat(linspace(1,0,down-up+1)',1,size(mask,2));%复制平铺矩阵
%计算每张图的重合区域像素值
linear_blended_img2(:,:,:) = linear_blended_img2(:,:,:).*linear_blend_mask;

%输出结果
linear_blended_img(:,:,:) = linear_blended_img2(:,:,:) + linear_blended_img1(:,:,:);
linear_blended_img=uint8(linear_blended_img);

equally_weighted_blended_img(:,:,:)=equally_weighted_blended_img1(:,:,:) + equally_weighted_blended_img2(:,:,:);
equally_weighted_blended_img=uint8(equally_weighted_blended_img);
end