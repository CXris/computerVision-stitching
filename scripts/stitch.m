% 输入：
% img1：(H*W*3)的图1。
% img2：(H*W*3)的图2。
% 
% 输出：
% out：img1和img2线性融合的拼接结果。

function out=stitch(img1,img2)

k=0.04;
border=20;
corners_img1 = harris_corners(img1,3,k,border);
corners_img2 = harris_corners(img2,3,k,border);

[x1,y1]=find(corners_img1==1);
[x2,y2]=find(corners_img2==1);

patch_size=16;
[keypoints1,descriptors1]=describe_hog_keypoints(img1,corners_img1,patch_size);
[keypoints2,descriptors2]=describe_hog_keypoints(img2,corners_img2,patch_size);

k=0.7;
[matched_points,~] = match_descriptors(descriptors1,descriptors2,k);

iterations=500;
thres=0.01;
num_inliers=10;

[matches,~]=ransac(keypoints1,keypoints2,matched_points,iterations,thres,num_inliers);

count=length(matches);
x_img1=zeros(1,count);y_img1=zeros(1,count);
x_img2=zeros(1,count);y_img2=zeros(1,count);

for i=1:count
    p1=matches(i,1);p2=matches(i,2);
    x_img1(i)=x1(p1);y_img1(i)=y1(p1);
    x_img2(i)=x2(p2);y_img2(i)=y2(p2);
end

T=fit_affine_matrix(x_img2,y_img2,x_img1,y_img1);

[t_img1,t_img2]=img_trans(img1,img2,T);

[h1,~]=size(t_img1);
[h2,~]=size(t_img2);

h=max(h1,h2);
t_img1=padarray(t_img1,[abs(h-h1) 0],0,'post');
t_img2=padarray(t_img2,[abs(h-h2) 0],0,'post');

[~,linear_blendedimg,~]=linear_blend(t_img1,t_img2);

out=linear_blendedimg;
