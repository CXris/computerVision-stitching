% 输入：
% x、y、u、v：角点坐标集(x,y)，角点坐标集(u,v)。
%
% 输出：
% H：拟合的仿射变换矩阵H。
%
% 注意：
% (x,y)应输入img2中匹配点的坐标，(u,v)应输入img1中匹配点的坐标，否则拟合出来的是img1变换成img2的变换矩阵。

%根据论文构造的计算矩阵
function H=fit_affine_matrix(x,y,u,v)

L=length(x);
A=[];b=[];

% 根据最小二乘法公式构造三个矩阵
for i=1:L
    tempA=[x(i) y(i) 0 0 1 0;0 0 x(i) y(i) 0 1];
    A=[A;tempA];% 构造矩阵A
    tempb=[u(i);v(i)];
    b=[b;tempb];% 构造矩阵b
end

H=((A'*A)^-1)*A'*b;% 计算矩阵H

% 有时候由于噪声影响，会使得最后一列不是精确的[0, 0, 1]，此时我们可以手动将它置为[0, 0, 1]
Tr=[H(1) H(2) H(5);H(3) H(4) H(6);0 0 1];
H=Tr;
end

%根据PPT构造的计算矩阵 计算结果都是相同的
% function H=fit_affine_matrix(x,y,u,v)
% L=length(x);
%
% A=[];
% B=[];
% for i=1:L
%     tempA=[x(i) y(i) 1 0 0 0;0 0 0 x(i) y(i) 1];
%     A=[A;tempA];
%     tempb=[u(i);v(i)];
%     B=[B;tempb];
% end
% H=((A'*A)^-1)*A'*B;
%
% Tr=[0 0 0;0 0 0;0 0 1];
% Tr(1,1:3)=H(1:3);
% Tr(2,1:3)=H(4:6);
%
% H=Tr;
% end