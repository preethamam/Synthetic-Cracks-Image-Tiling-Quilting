function [oriheight, oriwidth, bytesppix, f_orig, IMconverted] ...
                        = imconversion2gray (ImageID, gpuarray, resizeImage, ...
                        maxImageResizePixels, resizeImageSize, resizeImageSizeScale, contrast_type)
    % Load image file
    if (strcmp(gpuarray, 'yes'))
        f_orig = gpuArray(imread(ImageID));
    else
        f_orig = imread(ImageID);
    end
        

    [oriheight, oriwidth, bytesppix] = size (f_orig);
        
    if(strcmp(resizeImage,'yes') && (max(oriheight, oriwidth) > maxImageResizePixels) && ...
            ~isempty(resizeImageSize))
        f_orig = imresize(f_orig,resizeImageSize);
        [oriheight, oriwidth, bytesppix] = size (f_orig);

    elseif (strcmp(resizeImage,'yes') && isempty(resizeImageSize))
        f_orig = imresize(f_orig,resizeImageSizeScale);
        [oriheight, oriwidth, bytesppix] = size (f_orig);

    end 
    
    % Check for grayscale or color
    switch bytesppix
        case 1
            IMconverted = double(f_orig);      
        case 3
            
%            if (strcmp(image_sharpen ,'yes'))
%                    
%            end

           % Color 2 grayscale
           if (strcmp(contrast_type ,'adaphist'))
               IMconverted = double(adapthisteq(rgb2gray(f_orig)));    
           elseif (strcmp(contrast_type ,'image_adjust'))
               IMconverted = double(imadjust(rgb2gray(f_orig)));
           elseif (strcmp(contrast_type ,'hist_equi'))
               IMconverted = double(histeq(rgb2gray(f_orig)));
           else
               IMconverted = double(rgb2gray(f_orig));
           end    

        otherwise
            error (['Invalid image type. Please check your image channel' ...
                    '(maximum bytes per pixel.']);
    end
end
