function [Boxlist,plist] = cracklist_generator(versions,cracknums)
    %radiusSE = randi([minRadius, maxRadius]); %ok<PFOUS>


    %versions = 5;
    start = randi([1,versions]);
    %single_crack_generator(w,h,1);

    plist = {};
    Boxlist = {};
    %connecting pixels that are really close to fill up some small gaps
    SE = strel('disk',2);

    %imageArray = imclose(imageArray,se);
    %cracknum = 1;
    %for testing
    for cracknum = 1:cracknums
        start = randi([2,versions]);
    %generate a crack 
    %3 options could happen in the next timestopL:(no change) (extend) (thicker) 

        for i = start:versions 
            k = randi([1,3]);
            w = randi([300,1000]);
            h = randi([100,500]);
            if(i ==start)
                radiusSE = randi([1, 3]);
                C = single_crack_generator(w,h,radiusSE);
                pixels = struct2cell(regionprops(C,'PixelList'));
                Box = struct2cell(regionprops(C,'BoundingBox'));

                plist{start,cracknum} = pixels{1,1};
                Boxlist{start,cracknum} = Box{1,1};
            elseif(k==1)
                %make thicker
                C = imdilate(C,SE);

                pixels = struct2cell(regionprops(C,'PixelList'));
                Box = struct2cell(regionprops(C,'BoundingBox'));

                plist{i,cracknum} = pixels{1,1};
                Boxlist{i,cracknum} = Box{1,1};
            elseif(k==2)
                Boxlist{i,cracknum} = Boxlist{i-1,cracknum};
                %grow
                r = randi([1,3]);
                w_ = randi([25,w]);
                h_ = randi([25,h]);
                if(r == 1|| r == 3) %add to top
                    add = single_crack_generator(w_,h_,randi([1, radiusSE]));
                    pixels = struct2cell(regionprops(add,'PixelList'));
                    %location on top to add
                    [y_loc,I]  = min(plist{i-1,cracknum}(:,2));
                    x_loc = plist{i-1,cracknum}(I,1);
                    %location of the new section to connect
                    [y_loc_new,I]  = max(pixels{1,1}(:,2));
                    x_loc_new = pixels{1,1}(I,1);
                    %shift the new section and add


                    pixels{1,1}(:,1) = pixels{1,1}(:,1) + ( x_loc - x_loc_new);
                    pixels{1,1}(:,2) = pixels{1,1}(:,2) + ( y_loc - y_loc_new);

                    plist{i,cracknum} = [plist{i-1,cracknum} ; pixels{1,1}];

                end
                if(r == 2|| r == 3) %add to bottom
                    add = single_crack_generator(w_,h_,randi([1, radiusSE]));
                    pixels = struct2cell(regionprops(add,'PixelList'));
                    %location on bottom to add
                    [y_loc,I]  = max(plist{i-1,cracknum}(:,2));
                    x_loc = plist{i-1,cracknum}(I,1);
                    %location of the new section to connect
                    [y_loc_new,I]  = min(pixels{1,1}(:,2));
                    x_loc_new = pixels{1,1}(I,1);

                    %shift the new section and add
                    pixels{1,1}(:,1) = pixels{1,1}(:,1) + ( x_loc - x_loc_new);
                    pixels{1,1}(:,2) = pixels{1,1}(:,2) + ( y_loc - y_loc_new);

                    plist{i,cracknum} = [plist{i-1,cracknum} ; pixels{1,1}];

                end

                x_shift = min(plist{i,cracknum}(:,1));
                y_shift = min(plist{i,cracknum}(:,2));
                %shift every cracks from previous timestep to align the crack
                for shift = start:i

                    plist{shift,cracknum}(:,1) = plist{shift,cracknum}(:,1) -x_shift+1;
                    plist{shift,cracknum}(:,2) = plist{shift,cracknum}(:,2) -y_shift+1;

                    Boxlist{shift,cracknum}(1) = Boxlist{shift,cracknum}(1) -x_shift+1;
                    Boxlist{shift,cracknum}(2) = Boxlist{shift,cracknum}(2) -y_shift+1;

                end 
                Boxlist{i,cracknum}(1) = 1;
                Boxlist{i,cracknum}(2) = 1;

            else 
                %no change
                plist{i,cracknum} = plist{i-1,cracknum};
                Boxlist{i,cracknum} = Boxlist{i-1,cracknum};
            end
            C= accumarray([plist{i,cracknum}(:,2) plist{i,cracknum}(:,1)],1);
        end
    end
end

