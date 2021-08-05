lena = double(imread('exp1.png'));
girl = double(imread('girl.png'));
lena = imresize(lena,0.1);

Lf = imGradFeature(lena);
Gf = imGradFeature(girl);

w = 57;
h = 16;
LX = 123;
LY = 125;
GX = 89;
GY = 101;

%Lf(LY:LY+h,LX:LX+w,:,:) = Gf(GY:GY+h,GX:GX+w,:,:);

X = Lf(:,:,:,1);
Lf = repmat(Lf,10,10);

param = buildModPoissonParam( size(Lf) );
Y = modPoisson( Lf, param, 1E-8 );
figure,imshow(Y);
imwrite(uint8(X),'X.png');
imwrite(uint8(Y),'Y.png');

