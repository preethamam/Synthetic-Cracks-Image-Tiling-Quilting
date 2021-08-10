im = double(imread('exp5.png'));
im = imresize(im,0.1);

Lf = imGradFeature(im);


X = Lf(:,:,:,1);
Lf = repmat(Lf,3,3);

param = buildModPoissonParam( size(Lf) );
Y = modPoisson( Lf, param, 1E-2 );
%figure,imshow(Y);
%imwrite(uint8(Y),'surface.png');

rect = [587 587 587 587];
Icropped = imcrop(Y,rect);

temp = repmat(Icropped,10,10);
%temp = imresize(temp,0.1);
figure,imshow(temp);
imwrite(uint8(temp),'tiled_exp5_50x50.png');
