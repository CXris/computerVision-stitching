% 输入：
% image：(H*W*3)图像，用于提取patch中的像素值，生成描述向量。
% corners：(H*W)图像，Harris角点检测函数harris_corners( )检测出的角点图。
% patch_size：patch的大小（patch_size*patch_size）。
% 
% 输出：
% keypoints：(m*2)矩阵，行数为角点索引，即第i行存储的内容(x,y)就是第i个角点在原图中的x坐标和y坐标。
% descriptors：m*(patch_size*patch_size)矩阵，行数为角点索引，即第i行存储的(1*(patch_size*patch_size))数列就是第i个角点的描述子。

function [keypoints,descriptors]=describe_keypoints(image,corners,patch_size)

%将RGB图像转化为灰度图
if length(size(image))==3
    image = rgb2gray(double(image)/255);
end

%得出角点图corners中角点在原图中的坐标
[x,y]=find(corners==1);
keypoints=zeros(length(x),2);
keypoints(:,1)=x;
keypoints(:,2)=y;

%初始化描述向量矩阵
ps=floor(patch_size*0.5);
descriptors=zeros(length(x),(ps*2)^2);

%计算每个角点的特征向量
for i=1:length(keypoints)
    tempx=keypoints(i,1);%角点x坐标
    tempy=keypoints(i,2);%角点y坐标
    patch1=image(tempx-ps:tempx-1,tempy-ps:tempy-1);
    patch2=image(tempx+1:tempx+ps,tempy-ps:tempy-1);
    patch3=image(tempx-ps:tempx-1,tempy+1:tempy+ps);
    patch4=image(tempx+1:tempx+ps,tempy+1:tempy+ps);
    patch=[patch1,patch2;patch3,patch4];%取角点周围16*16个像素作为patch
    v=simple_descriptor(patch);%展开patch，并标准正态化增加光照稳定性
    descriptors(i,:)=v;
end