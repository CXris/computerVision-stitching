% 输入：
% descriptors1：m*d描述子矩阵。
% descriptors2：n*d描述子矩阵。
% k：比例阈值。
% 
% 输出：
% count：匹配上的角点对数。
% matched_points：(count*2)矩阵，保存匹配上的角点的坐标。

function [matched_points,count]=match_descriptors(descriptors1,descriptors2,k)

%初始化欧氏距离矩阵
[count1,~]=size(descriptors1);
[count2,~]=size(descriptors2);
matched_points=zeros(count1,2);
dist=zeros(count1,count2);

%计算欧式距离矩阵
for i=1:count1
    for j=1:count2
        temp1=descriptors1(i,:);%取角点1的描述子
        temp2=descriptors2(j,:);%取角点2的描述子
        dist(i,j)=sqrt(sum((temp1-temp2).^2));%计算这两个描述子的欧氏距离
    end
end

%判断角点是否匹配
for i=1:count1
    [dist_min,ind]=sort(dist(i,:));%对于img1中的角点i，找出img2中与它欧氏距离最小的两个角点j1和j2
    dist_min1=dist_min(1);%记(i,j1)的欧氏距离为dist_min1
    dist_min2=dist_min(2);%记(i,j2)的欧氏距离为dist_min2
    
    q=dist_min1/dist_min2;%计算dist_min1/dist_min2
    
    if q<=k%根据阈值k判断(i,j1)是否是一对被接受匹配的角点
        matched_points(i,1)=i;
        matched_points(i,2)=ind(1);
    end
end

matched_points(all(matched_points==0,2),:)=[];
count=size(matched_points,1);

end