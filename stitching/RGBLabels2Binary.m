clc; close all; clear;

%%
path = '/Users/paulchenchen/image-processing/stitching/by_group/in_red';
file = 'red5_2.png';

ImageID_ground = fullfile(path,file);
name = 'label5_2.png';
%--------------------------------------------------------------------------
% GPU array
%--------------------------------------------------------------------------
% yes - creates GPU array (note: works for certain Matlab functions)
% no  - non GPU array
input.gpuarray                = 'no';

%--------------------------------------------------------------------------
% Colorspace segmentation options 
%--------------------------------------------------------------------------
% Type of colorspace to segment RGB ground-truths
% HSV (recommended) or RGB
input.colorspace = 'hsv';  %[hsv | rgb]

% RGB startindex
% n   - channel value (integer [0, 255])
input.RGBstartindex           = 235;

% GT label color
input.GTcolor_TYPE = 'color';   %[color | binary]


%--------------------------------------------------------------------------
% Image resize for too large images
%--------------------------------------------------------------------------
input.resizeImage = 'no'; % 'yes' | 'no'
input.maxImageResizePixels = 700;
input.resizeImageSize = [];
input.resizeImageSizeScale = 0.25;

%--------------------------------------------------------------------------
% Turn on/off adaptive histogram
%--------------------------------------------------------------------------
% adaphist - adaptive histogram
% image_adjust - imadjust
% hist_equi - histogram equalization
% none
input.contrast_type    = 'image_adjust';


[GT, ~, ~] = groundNnoisy_BWimage (input, ImageID_ground, ...
         input.gpuarray, input.resizeImage,...
         input.maxImageResizePixels, input.resizeImageSize, input.resizeImageSizeScale, ...
         input.contrast_type, input.RGBstartindex, ...
         [], input.colorspace); %#ok<*NASGU>
imshow(GT);
imwrite(GT,name);