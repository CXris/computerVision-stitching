function [t_img1,t_img2]=img_trans(img1,img2,affine_matrix)

T=affine_matrix;
Tr=[T(1,1),T(1,2),0;T(2,1),T(2,2),0;0 0 1];
Tx=T(1,3);
Ty=T(2,3);

Tr=affine2d(Tr);
followOutput = affineOutputView(size(img2),Tr,'BoundsStyle','FollowOutput');
t_img1=img1;
t_img2=imwarp(img2,Tr,'OutputView',followOutput);

if Tx>0
    methodx='post';
else
    methodx='pre';
end

if Ty>0
    methody='post';
else
    methody='pre';
end

t_img2=padarray(t_img2,abs(floor(Tx)),0,methodx);
t_img2=padarray(rot90(t_img2),abs(floor(Ty)),0,methody);
t_img2=rot90(t_img2);
t_img2=rot90(t_img2);
t_img2=rot90(t_img2);

t_img1=padarray(t_img1,abs(size(t_img2,1)-size(t_img1,1)),0,'post');
t_img1=padarray(rot90(t_img1),abs(size(t_img2,2)-size(t_img1,2)),0,'pre');
t_img1=rot90(t_img1);
t_img1=rot90(t_img1);
t_img1=rot90(t_img1);

end
