surface = double(imread('surface.png'));
rect = [587 587 587 587];
Icropped = imcrop(surface,rect);

temp = repmat(Icropped,10,10);
%temp = imresize(temp,0.1);
figure,imshow(temp);
imwrite(uint8(temp),'tiled.png');
