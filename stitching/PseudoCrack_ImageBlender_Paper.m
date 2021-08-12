%//%************************************************************************%
%//%*                              Ph.D                                    *%
%//%*                       Project RoboCRACK	             			   *%
%//%*                                                                      *%
%//%*             Author(s): Preetham Aghalaya Manjunatha                  *%
%//%*             USC Email: aghalaya@usc.edu                              *%
%//%*             Submission Date: 04/21/2017                              *%
%//%************************************************************************%
%//%*             Viterbi School of Engineering,                           *%
%//%*             Sonny Astani Dept. of Civil Engineering,                 *%
%//%*             University of Southern california,                       *%
%//%*             Los Angeles, California.                                 *%
%//%************************************************************************%

clc; close all; clear;
clcwaitbarz = findall(0,'type','figure','tag','TMWWaitbar');
delete(clcwaitbarz);
Start = tic;

% parpool(16);

%% Inputs
%--------------------------------------------------------------------------
showPlot = 0;

%--------------------------------------------------------------------------
totalSynCracks = 1;
createSynCracks = 1;

% Synthetic cracks width and length input
%--------------------------------------------------------------------------
% Output image size range
minRadius = 1;
maxRadius = 5;

%--------------------------------------------------------------------------
% Image filtering parameters
%--------------------------------------------------------------------------
sigma = 5;
GaussFiltSize = [25 25];

%--------------------------------------------------------------------------
% Elastic deformation
%--------------------------------------------------------------------------
% Show figure points
showfig_points = 0;
geotrans_type = {'affine', 'projective', 'polynomial', 'piecewise_linear', 'local_weighted_mean'};
totNumberCracksElasticDef = 1;
imageFolder = '/Users/paulchenchen/image-processing/try';
%
%--------------------------------------------------------------------------
% Folder and image sets
%--------------------------------------------------------------------------
% Non-crack image to be overlayed
%{
if ismac

elseif isunix
    imageFolder = '/media/preethamam/BigData/Project MegaCRACK-RoboCRACK/Real World Data/External Dataset/SDNET2018/P/UP';
elseif ispc
    imageFolder = 'U:\Project MegaCRACK-RoboCRACK\Real World Data\Hybrid Paper\Synthetic Crack Profile Analysis\non-crack';
else
    disp('Platform not supported')
end

%}
% Synthetic cracks images save folder
if ismac
  synCrackGTFolder = '/Users/paulchenchen/image-processing/try';    

elseif isunix
    synCrackGTFolder = '/Users/paulchenchen/image-processing/try';    
    overlayCrackFolder =  '/Users/paulchenchen/image-processing/try';
elseif ispc
    synCrackGTFolder =  '/Users/paulchenchen/image-processing/try';
else
    disp('Platform not supported')
end

% Read Image sets
imgSet    = imageSet(imageFolder, 'recursive');
%imgSet = zeros(1000,1000,'logical');
imgSubSet = datasample(imgSet.ImageLocation, totalSynCracks,'Replace',false);
% imgSetSynCrack = imageSet(synCrackFolder, 'recursive');

% MATFILENAME = 'ZZZ_MFAT_GaussainKernelSizeVsCrackThickness_SyntheticCracks_PhysicalProps.mat';
% load(MATFILENAME);
% imgSubSet = datasample({Output.fileNameRecord}, totalSynCracks, 'Replace', false);

L = length(imgSubSet);

% %Before the loop, we need to construct the object. 
%WaitMessage = waitbarParfor(L, 'Waitbar', true);

for i = 1:L
    
    %Separnd a message to the object. 
    %WaitMessage.Send;
    
    % clear imSize
    % Read image
    % Extract the file path, name and extension
    [pathstr,imagename,ext] = fileparts(char(imgSubSet(i)));
    
    Ioriginal = imread(fullfile(imageFolder,[imagename '.jpg']));
    imSizee = size(Ioriginal);
    imSize = [imSizee(1) imSizee(2)];

    % Radii and width of the seams
    radiusSE = randi([minRadius, maxRadius]); %ok<PFOUS>
    OutputStruct(i).radiusSE = radiusSE;
    
    SE = strel('disk', radiusSE);
    OutputStruct(i).width_actual_record = size(SE.Neighborhood,1) - 1; %radiusSE * 2 + 2;
    
    width_actual = size(SE.Neighborhood,1) - 1;
    
    if (rand(1) > 0.5)
        Im = randn(imSize);
    else
        Im = rand(imSize);
    end

    energy = funct_energyGrey(Im);
    

    if (rand(1) > 0.5)
        [optSeamMask2, seamEnergy2] = funct_findOptSeam(energy);
        seam = imcomplement(optSeamMask2);
%         seam = filter_stage_I (seam);
    else
        [optSeamMask2, seamEnergy2] = funct_findOptSeam2(energy);
        seam = imcomplement(optSeamMask2);
    end
       
    % Find the centroid of that binary region
    measurements = regionprops(seam, 'Centroid');
    [rows, columns] = size(seam);
    rowsToShift = ceil(rows/2- measurements.Centroid(2));
    columnsToShift = ceil(columns/2 - measurements.Centroid(1));

    % Call circshift to move region to the center.
    shiftedSeam = circshift(seam, [rowsToShift columnsToShift]);    
    
    % Lengths of the seam
%     [row,col] = find(shiftedSeam);
%     arclen(i,:) = arclength(col, row,'s');
        
    OutputStruct(i).length_actual_record = numel(find(shiftedSeam));
    
    % Dilate the seam
    dilateSeam = imdilate(shiftedSeam,SE);
%     rotSeam = imrotate(dilateSeam, randi(45));
%     rotSeam = imresize(rotSeam, imSize);
    
%     img_elastic = elastic_def_multiplicator(dilateSeam,geotrans_type,totNumberCracksElasticDef,showfig_points);
    
    % Area of the seams
    OutputStruct(i).area_actual_record = numel(find(dilateSeam ~= 0));

    % Profiling Image 
%     Img = imgaussfilt(double(rotSeam), sigma,'FilterSize', GaussFiltSize);
    Img = dilateSeam;
    Img_comp = imcomplement(Img);
    GaussFiltSize = width_actual^1.6;
    GaussFiltSize = GaussFiltSize-mod(GaussFiltSize,2)+1;
    
    ImgSmooth = imgaussfilt(double(Img_comp), sigma,'FilterSize', GaussFiltSize);
    ImgSmooth_comp = imcomplement(ImgSmooth);
    BW = imbinarize(ImgSmooth_comp);
    
    
    Igray = rgb2gray(Ioriginal);
    IoverLay = uint8(double(Igray) .* Img_comp);
    IoverLaySmooth = uint8(double(Ioriginal) .* ImgSmooth);
    
    
%     figure; 
%     subplot(1,5,1); imshow(Img);
%     subplot(1,5,2); imshow(Img_comp);
%     subplot(1,5,3); imshow(ImgSmooth);
%     subplot(1,5,4); imshow(IoverLay);
%     subplot(1,5,5); imshow(IoverLaySmooth);
    
    %% Write the images
    
    % Base filename 
    outputBaseFileName = sprintf('%s.png', imagename);
    outputBaseFileNameGT = sprintf('%s.bmp', imagename);
    
    % Image write
    %imwrite(IoverLaySmooth, fullfile(overlayCrackFolder,outputBaseFileName), 'png');
    imwrite(BW, fullfile(synCrackGTFolder,outputBaseFileNameGT), 'bmp');

end

%Destroy the object.
%WaitMessage.Destroy 

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