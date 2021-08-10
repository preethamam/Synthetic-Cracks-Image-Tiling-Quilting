function [Box_All,plist] = Sortcracks(myFolder,threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %myFolder = '/Users/paulchenchen/image-processing/stitching/processed/part1';

    if ~isdir(myFolder)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
        uiwait(warndlg(errorMessage));
        return;
    end
    filePattern = fullfile(myFolder, '*.png');
    pngFiles = dir(filePattern);

    %connect small base on input arg 
    se = strel('disk',threshold);
    Box_All = {};
    plist = {};
    for k = 1:length(pngFiles)
        baseFileName = pngFiles(6-k).name;
        fullFileName = fullfile(myFolder, baseFileName);
        fprintf(1, 'Now reading %s\n', fullFileName);
        imageArray = imread(fullFileName);

        %connecting pixels that are really close to fill up some small gaps
        imageArray = imclose(imageArray,se);

        %convert struct into cellarray
        pixels = struct2cell(regionprops(imageArray,'PixelList'));
        Box = struct2cell(regionprops(imageArray,'BoundingBox'));
        if(k==1)
           %[newx,newy] = size(Box);

            plist(6-k,:) = pixels;
            Box_All(6-k,:) = Box;

        else

            % matching new input cracks(previous version) to the already
            % registered cracks

            [~,y] = size(Box_All);

            z = 1;
            for M = 1:y
                [~,newy] = size(Box);
                crack = Box_All{5,M};

                for z = 1:newy
                    x_ = Box{z}(1);y_ = Box{z}(2); w = Box{z}(3); h = Box{z}(4);
                    %determining if they are the same cracks
                    if((x_ > crack(1) || abs(x_ - crack(1)) < 50 )&&(y_  > crack(2)||abs(y_ - crack(2) )<50)   &&(x_+w < crack(1)+crack(3) || abs(x_+w - (crack(1)+crack(3)))<50)&&(y_+h < crack(2)+crack(4) || abs(y_+h - (crack(2)+crack(4)))<50))
                        %get rid of some small pieces of random cracks(this is due to some human error)
                        if ( w > 10 || h > 10)

                            plist(6-k,M) = pixels(1,z);
                            Box_All(6-k,M) = Box(1,z);

                            %replace previous added if they have less pixels
                            [p_num_new, ~] = size(pixels{1,z});
                            %compare pixels
                            for index = (7-k):5

                                [p_num,~] = size(plist{index,M});

                                if(p_num<p_num_new)
                                    %replace
                                    %plist(index,M) = pixels(1,z);
                                    %Box_All(index,M) = Box(1,z);

                                    %enlarge the previous ones 

                                    SE = strel('rectangle',[4 4]);
                                    BW2 = imdilate(accumarray([plist{index,M}(:,2) plist{index,M}(:,1)],1),SE);

                                    plist(index,M) = struct2cell(regionprops(BW2,'PixelList'));
                                    Box_All(index,M) = struct2cell(regionprops(BW2,'BoundingBox'));
                                    [zzz,~] = size(plist{index,M});
                                    disp('enlarge' + string(index) + string(M) + ' new: ' +string(p_num_new) + ' current:' + string(p_num) + ' becoming: ' +string(zzz));
                                    [p_num_new, ~] = size(plist{index,M});

                                else
                                    % [add here] replacing when changes is
                                     % less than 2% in the future
                                     disp('ended');
                                    break;
                                end

                            end
                            break;
                        end
                    end
                end 
            end 
        end
    end
end

