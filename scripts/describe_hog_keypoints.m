function [M,out]=describe_hog_keypoints(image,keypoints,patch_size)

if length(size(image))==3
    image = rgb2gray(double(image)/255);
end

[x,y]=find(keypoints==1);
M=zeros(length(x),2);
M(:,1)=x;
M(:,2)=y;

ps=floor(patch_size^0.5);
out=zeros(length(x),128);

for i=1:length(M)
    tempx=M(i,1);
    tempy=M(i,2);
    patch1=image(tempx-ps:tempx-1,tempy-ps:tempy-1);
    patch2=image(tempx+1:tempx+ps,tempy-ps:tempy-1);
    patch3=image(tempx-ps:tempx-1,tempy+1:tempy+ps);
    patch4=image(tempx+1:tempx+ps,tempy+1:tempy+ps);
    patch=[patch1,patch2;patch3,patch4];
    hogpatch=hog_descriptor(patch);
    v=simple_descriptor(hogpatch);
    out(i,:)=v;
end