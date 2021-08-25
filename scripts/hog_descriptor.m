% 输入：
% patch：(m*m)矩阵，角点周围的一个固定区域。
% 
% 输出：
% hog_descriptors：(1*d)向量，HOG梯度直方图描述子。

function hog_descriptors = hog_descriptor(patch)

%定义x方向和y方向的sobel算子
sobel_x=[1 0 -1;2 0 -2;1 0 -1];
sobel_y=[1 2 1;0 0 0;-1 -2 -1];

%计算x方向和y方向的梯度
Gx=conv2(patch,sobel_x,'same');
Gy=conv2(patch,sobel_y,'same');

%计算梯度幅值和梯度角度
G=(Gx.^2+Gy.^2).^0.5;
theta=atan2d(Gy,Gx);
theta(theta<0)=theta(theta<0)+360;

%设置直方图bin的数量，这里将45度为一个bin，将360度分为8个bin
n_bin=8;

%根据梯度方向分类
sort=sorter(theta,n_bin);

%将patch分块，分为(patch_size/4)个2*2的cell
[H,W]=size(patch);
patch_size=H*W;
cell_num=(patch_size/4)^0.5;
cell_size=ones(1,cell_num)*2;
B_sort=mat2cell(sort,cell_size,cell_size);
B=mat2cell(patch,cell_size,cell_size);
[H_B,W_B]=size(B);
B_G=mat2cell(G,cell_size,cell_size);
B_theta=mat2cell(theta,cell_size,cell_size);

temp_B_bin=zeros(4,n_bin);
count=1;

%计算patch梯度直方图
for m=1:H_B
    for n=1:W_B
        temp_B_G=B_G{m,n};
        temp_B_theta=B_theta{m,n};
        temp_B_sort=B_sort{m,n};
        [H_C,W_C]=size(temp_B_G);
        temp_C_bin=zeros(1,n_bin+1);
        
        %计算cell梯度直方图
        for i=1:H_C
            for j=1:W_C
                temp_theta=temp_B_theta(i,j);%梯度方向
                temp_magnitude=temp_B_G(i,j);%梯度幅值
                temp_sort=temp_B_sort(i,j);%梯度角度类别
                
                contri1_theta=temp_theta-(temp_sort-1)*(360/n_bin);%对于第i个bin的贡献
                contri2_theta=(360/n_bin)*2-contri1_theta;%对于第i+1个bin的贡献
                
                contri1_weiht=contri1_theta/(contri1_theta+contri2_theta);%第i个bin获得的幅值权值
                contri2_weiht=contri2_theta/(contri1_theta+contri2_theta);%第i+1个bin获得的幅值权值
                
                temp_C_bin(temp_sort)=temp_C_bin(temp_sort)+temp_magnitude*contri1_weiht;%第i个bin获得的幅值
                temp_C_bin(temp_sort+1)=temp_C_bin(temp_sort+1)+temp_magnitude*contri2_weiht;%第i+1个bin获得的幅值
            end
        end
      
        %对于大于315度的角度，其i+1个bin所获的的幅值应分配给0度的bin
        temp_C_bin(1)=temp_C_bin(1)+temp_C_bin(n_bin+1);
        temp_C_bin=temp_C_bin(1:n_bin);
        temp_B_bin(count,:)=temp_C_bin;
        count=count+1;
    end
end

hog_descriptors=temp_B_bin(:);

end

%角度分类器，根据梯度方向决定这个点属于哪两个bin
function out=sorter(theta,n_bin)
[H,W]=size(theta);
list_bin=linspace(0,360,n_bin+1);
out=zeros(H,W);
for i=1:H
    for j=1:W
        for k=1:n_bin
            if theta(i,j)<=list_bin(k+1)
                out(i,j)=k;
                break;
            end
        end
    end
end
end
