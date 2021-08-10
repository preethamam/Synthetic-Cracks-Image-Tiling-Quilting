base = double(imread('empty_texture/texturefilled.png'));
c1 = double(imread('by_group/exp5_1.png'));
c2 = double(imread('by_group/exp5_2.png'));
c3 = double(imread('by_group/exp5_3.png'));

%resize to be able to run the program
%base = imcrop(base, [1 1 2934 2934]); % 25x25 ft
base = imresize(base, 0.1);
c1 = imresize(c1,0.1);
c2 = imresize(c2,0.1);
c3 = imresize(c3,0.1);

Lf = imGradFeature(base);
A = imGradFeature(c1);
B = imGradFeature(c2);
C = imGradFeature(c3);


w1 = 100;
h2 = 300;
LX = 100;
LY = 100;
GX = 1;
GY = 1;

Lf(LY:LY+h,LX:LX+w,:,:) = A(GY:GY+h,GX:GX+w,:,:);

X = Lf(:,:,:,1);
param = buildModPoissonParam( size(Lf) );
Y = modPoisson( Lf, param, 1E-8 );
figure,imshow(Y);
%imwrite(uint8(X),'X.png');
imwrite(uint8(Y),'testblend.png');
