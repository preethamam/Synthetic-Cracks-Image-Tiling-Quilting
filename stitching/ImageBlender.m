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
target='concrete_10x10.png';
target = imread(target);
target = target(1:11733,1:11733,:);
for k = 1:5
    mask = 'exp'+string(k)+'_rand.png';
    result='exp'+ string(k) + '_10x10.png';

    sigma = 3;
    GaussFiltSize = 5;
    num_iter = 4;

    %%
    %source = imread(source);            % SOURCE IMAGE
    mask_bw = imread(mask);
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
end
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

