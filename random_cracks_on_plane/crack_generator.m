function [Boxlist,plist_s] = crack_generator(size_x_max,size_x_min,size_y_max, size_y_min, thickness_max, thickness_min, cracknums, mode, max_branches, min_branches)


    %versions = 5;
    %single_crack_generator(w,h,1);

    plist = {};
    plist_s = {};
    Boxlist = {};
    %connecting pixels that are really close to fill up some small gaps
    SE = strel('disk',2);

    %imageArray = imclose(imageArray,se);
    %cracknum = 1;
    %for testing
    for cracknum = 1:cracknums
        start = 1;
    %generate a crack 
    %3 options could happen in the next timestopL:(no change) (extend) (thicker) 
        if nargin == 10
            versions = randi([min_branches,max_branches]);
            z = 2;
            %disp(versions);
        else
            versions = 1;
                            z = 1;

        end
        for i = start:versions 

            w = randi([size_x_min,size_x_max]);
            h = randi([size_y_min,size_y_max]);
            if(i ==start)
                radiusSE = randi([thickness_min, thickness_max]);
                C = single_crack_generator(w,h,radiusSE);
                pixels = struct2cell(regionprops(C,'PixelList'));
                Box = struct2cell(regionprops(C,'BoundingBox'));

                plist{start,cracknum} = pixels{1,1};
                Boxlist{start,cracknum} = Box{1,1};
            end

            if (z == 2 && i ~=start)
            %add branches
                w_ = randi([50,w]);
                h_ = randi([50,h]);
                add = single_crack_generator(w_,h_,randi([1, radiusSE]));
                pixels = struct2cell(regionprops(add,'PixelList'));

                %random angle
                theta = round (150*rand());
                %CREATE THE MATRIX
                R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
                %rotate the datapoints
                rotp_add = pixels{1,1} * R';
    
    
                x_shift = abs(min(rotp_add(:,1)))+50;
                y_shift = abs(min(rotp_add(:,2)))+50;
    
                rotp_add(:,2) = round (rotp_add(:,2) + y_shift + 1);
                rotp_add(:,1) = round (rotp_add(:,1) + x_shift + 1);


                [k, h] = size(plist{i-1,cracknum}(:,2));
                r = randi([round(k*0.25),round(k*0.75)]);
                %location on bottom to add
                y_loc  = plist{i-1,cracknum}(r,2);
                x_loc = plist{i-1,cracknum}(r,1);
                %location of the new section to connect
                [y_loc_new,I]  = min(pixels{1,1}(:,2));
                x_loc_new = rotp_add(I,1);
                y_loc_new = rotp_add(I,2);
                rotp_add(:,1) = rotp_add(:,1) + ( x_loc - x_loc_new);
                rotp_add(:,2) = rotp_add(:,2) + ( y_loc - y_loc_new);
                
                plist{i,cracknum} = [plist{i-1,cracknum} ; rotp_add];




            end
            %C= accumarray([plist{i,cracknum}(:,2) plist{i,cracknum}(:,1)],1);
        end

        plist_s{1,cracknum} = plist {versions, cracknum}(:,:);

        x_shift = min(plist_s{1,cracknum}(:,1));
        y_shift = min(plist_s{1,cracknum}(:,2));
        plist_s{1,cracknum}(:,1) = plist_s{1,cracknum}(:,1) -x_shift+1;
        plist_s{1,cracknum}(:,2) = plist_s{1,cracknum}(:,2) -y_shift+1;


        x_max = max(plist_s{1,cracknum}(:,1));
        if x_max > size_x_max-1
            plist_s{1,cracknum}(:,1) = round (plist_s{1,cracknum}(:,1)/x_max *(size_x_max-2))+1;
        end 
        y_max = max(plist_s{1,cracknum}(:,2));
        if y_max > size_y_max-1
            plist_s{1,cracknum}(:,2) = round (plist_s{1,cracknum}(:,2)/y_max *(size_y_max-2))+1;
        end 
    end
    %plist = plist {versions, :};
    %Boxlist = Boxlist{versions, :};
end
