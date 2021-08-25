% 输入：
% image：需要检测角点的(H*W*3)图像。
% window_size：检测窗口的大小。
% k：角点响应方程参数。
% border：我们对图像边界上的角点并不感兴趣，忽略边界的角点。
% 
% 输出：
% corners：检测出的角点结果。（H*W）的0/1值图像，认为是角点处的值置为1，不是的置为0。

function corners=harris_corners(image,window_size,k,border)

%将RGB图像转化为灰度图
if length(size(image))==3
    image = rgb2gray(double(image)/255);
end

%初始化角点检测结果矩阵
[H,W]=size(image);
E=zeros(H,W);

%定义x方向和y方向的sobel算子
sobelx=[-1 0 1;-2 0 2;-1 0 1];
sobely=[-1 -2 -1;0 0 0;1 2 1];

%计算图像x方向和y方向的梯度值
Gx=conv2(image,sobelx,'same');
Gy=conv2(image,sobely,'same');

%计算角点响应函数中的A、B、C（梯度乘积结果），并对得到的结果做一次高斯平滑增加抗噪能力。
% window=ones(window_size,window_size);                    %选项1: 没有权重
window=fspecial('gaussian',[window_size,window_size],1);   %选项2: Gaussian平滑
A=conv2(Gx.*Gx,window,'same');
B=conv2(Gx.*Gy,window,'same');
C=conv2(Gy.*Gy,window,'same');

%根据角点响应函数计算每个像素点的角点响应值
for i=1:H
    for j=1:W
        M=[A(i,j),B(i,j);B(i,j),C(i,j)];
        E(i,j)=det(M)-k*(trace(M)^2);
    end
end

%找出图像的最大响应值Emax，将阈值设为0.01*Emax
Emax=max(E(:));
t=Emax*0.01;
E=padarray(E,[1 1],'both');

%使用阈值过滤角点
for i=2:H+1
    for j=2:W+1
        if E(i,j)<t
            E(i,j)=0;
        end
    end
end

%非极大值抑制
for i=2:H+1
    for j=2:W+1
        if E(i,j)~=0
            neighbors=get_neighbors(E,i,j);
            if E(i,j)<max(neighbors(:))
                E(i,j)=0;
            end
        end
    end
end

%剔除边界上的无效角点
corners=E(2:H+1,2:W+1);
corners(1:border,:)=0;
corners(:,1:border)=0;
corners(H-border+1:H,:)=0;
corners(:,W-border+1:W)=0;

corners(corners~=0)=1;
end

%输入坐标x,y，返回该点相邻的坐标点，包括(x,y)
function neighbors=get_neighbors(m,x,y)
neighbors =[m(x-1,y-1),m(x-1,y),m(x-1,y+1),m(x,y-1),m(x,y+1),m(x+1,y-1),m(x+1,y),m(x+1,y+1)];
end

