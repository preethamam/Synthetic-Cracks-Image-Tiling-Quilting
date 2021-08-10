%% Start parameters
%--------------------------------------------------------------------------
clear; close all; clc;
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Start = tic;

%% Inputs
%--------------------------------------------------------------------------
%source='Original_Set_02_2017_05_04_13_31_35_779_19.png';
%'mask/with_rotations/exp5_rand.png'
target='photoshop/c.png';
mask = 'exp5_rand.png';
result='result.jpg';

sigma = 3;
GaussFiltSize = 5;
num_iter = 4;

%%
%source = imread(source);            % SOURCE IMAGE
target = imread(target);
mask_bw = imresize(imread(mask),0.5);
mask_bw = mask_bw(1:14667,1:14667);
mask = imcomplement(imread(mask));        % DESTINATION IMAGE

Img = imgaussfilt(double(mask_bw), sigma,'FilterSize', GaussFiltSize);

Igray_1 = mask;
for i = 1:num_iter
    myfilter = fspecial('gaussian',[15 15], 1.25);
    myfilteredimage = imfilter(Igray_1, myfilter, 'replicate');
    Igray_1 = myfilteredimage;
end

IoverLay = uint8(double(target) .* imcomplement(Img));
J = imbinarize(Img);


figure;
ax1 = subplot(1,5,1); imshow(mask)
ax2 = subplot(1,5,2); imshow(Img)
ax3 = subplot(1,5,3); imshow(Igray_1)
ax4 = subplot(1,5,4); imshow(J)
ax5 = subplot(1,5,5); imshow(IoverLay)

linkaxes([ax1 ax2 ax3 ax4 ax5],'xy')
imwrite(IoverLay,result);
%%
%{
% full mask
halphablend = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port'); 

% mask = ones(size(I2));
% J1 = step(halphablend, I1, I2, mask); 
J1 = step(halphablend, source, target, mask); 

% upper left corner of the mask is set to 0s
% mask(1:end/2,1:end/2) = 0;
% J2 = step(halphablend, I1, I2, mask); 
J2 = step(halphablend, source, target, mask); 

% plot
figure;
ax1 = subplot (1,3,1); imshow(source);
ax2 = subplot (1,3,2); imshow(J1);
ax3 = subplot (1,3,3); imshow(J2);
linkaxes([ax1 ax2 ax3],'xy')
%}

%% End parameters
%--------------------------------------------------------------------------
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
statusFclose = fclose('all');

if(statusFclose == 0)
    disp('All files are closed.')
end
Runtime = toc(Start);
disp(Runtime);
