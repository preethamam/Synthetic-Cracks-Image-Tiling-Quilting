im = double(imread('exp1.png'));
im = imresize(im,0.1);

Lf = imGradFeature(im);


X = Lf(:,:,:,1);
Lf = repmat(Lf,3,3);

param = buildModPoissonParam( size(Lf) );
Y = modPoisson( Lf, param, 1E-2 );
%figure,imshow(Y);
imwrite(uint8(Y),'surface.png');
