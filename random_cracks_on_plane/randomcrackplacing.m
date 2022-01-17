function [result] = randomcrackplacing(plocation,w,h,num_cracks_add,savedname)
    %can return a cell array containing the randomized cracks in different
    %versions or save directly 
    if(nargin < 4)
        error('not enough inputs-- (pixelloctions{},w,h,numcracks to add, name to save)');
    
    end
    if(nargout == 0 && nargin ==4)
        
        error('Please assign a variable for return results and/or include savename');

    end 
    %%
    %placing random cracks with random rotations
    %numbers of cracks 
    %area within blank to put cracks so it doesnt exceed the image
    %boarders of the cracks
    x_max = w-750; 
    x_min = 750;
    y_max = h-750;
    y_min = 750;

    %declaring base area
    blank = zeros(w,h,'logical'); %25x25ft
    %blank = zeros(10000,10000,'logical');

    assigned = [0,0,0,0,0,0]; %[x y crack degree xshift yshift]

    %fill up some gaps due to imperfect rotation roundings
    se = strel('disk',5);
    L = 1;
    [num_versions,num_cracks] = size(plocation);
    final = blank;
    for i = 1:num_cracks_add
        %get a random crack 1:num_cracks
        crack = round ((num_cracks-1)*rand()+1);
        times = 0;
        while L~=0
            %looping until finds a place to put crack
            %random x & y inside blank
            x = round ((x_max-x_min)*rand()+x_min);
            y = round ((y_max-y_min)*rand()+y_min);
            
            %random angle
            theta = round (359*rand());
            %CREATE THE MATRIX
            R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
            %rotate the datapoints
            rotp = plocation{num_versions,crack} * R';


            x_shift = abs(min(rotp(:,1)))+50;
            y_shift = abs(min(rotp(:,2)))+50;

            rotp(:,2) = round (rotp(:,2) + y_shift + 1);
            rotp(:,1) = round (rotp(:,1) + x_shift + 1);

            rot_test = imclose(accumarray([rotp(:,2) rotp(:,1)],1),se);
            %width and height of the bounding box of the crack
            w = max(rotp(:,1));
            h = max(rotp(:,2));


            current_area = imcrop(final,[x y w h]); %data of that current area
            if (intersect(current_area,rot_test)==0 & ((y-1+h < y_max) && (x-1+w <x_max)))

                %replace if no intersect
                final(y:y-1+h, x:x-1+w) = xor(rot_test(:,:),blank(y:y-1+h, x:x-1+w));
                assigned(i,1:6) = [x,y,crack,theta,x_shift,y_shift];
                break;
            end
            times = times +1;
            if (times >400) %change the times if you would like to wait longer for more cracks
                num_cracks_add = i-1;
                disp('Can only add ' + string(num_cracks_add) +' of cracks(modify variable [times] if you wish to wait longer for more cracks)');
                L = 0; %terminate this whileloop  
            end 
        end
        if(L ==0)
            break;
        end
    end
    figure,imshow(final);
    if nargin == 5
        imwrite (final, savedname + string(num_versions)+ '.png');
        disp( savedname + string(num_versions)+'png' + ' saved');   
    end
    if(nargout ~= 0)
        result{1, num_versions} = final;
    end 
    
    %generate the cracks for other exps
    for exp = 1:(num_versions-1)
        temp = blank;
        for num_cracks = 1:num_cracks_add
            x_shift = assigned(num_cracks,5);
            y_shift = assigned(num_cracks,6);
            theta = assigned(num_cracks,4);
            crack = assigned(num_cracks,3);
            x = assigned(num_cracks,1);
            y = assigned(num_cracks,2);
            if(size(plocation{num_versions-exp,crack}) > 0)
                %CREATE THE rotation MATRIX
                R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
                %rotate the datapoints
                rotp = plocation{num_versions-exp,crack} * R';
                rotp(:,2) = round (rotp(:,2) + y_shift + 1);
                rotp(:,1) = round (rotp(:,1) + x_shift + 1);
                %disp('placing crack' + string(crack) + ' ' +string(num_versions-exp));
                rot_test = imclose(accumarray([rotp(:,2) rotp(:,1)],1),se);
                %width and height of the bounding box of the crack
                w = max(rotp(:,1));
                h = max(rotp(:,2));

                %to_add = accumarray([plocation{exp,crack}(:,2) plocation{exp,crack}(:,1)],1);
                temp(y:y-1+h, x:x-1+w) = xor(rot_test(:,:),blank(y:y-1+h, x:x-1+w));
            end
        end
        figure,imshow(temp);
        if nargin == 5
            imwrite (temp, savedname + string(num_versions-exp) + '.png');
            disp(savedname + string(num_versions-exp) + '.png saved');

        end
        if(nargout ~= 0)
            result{1, exp} = temp;
        end 
    end

end

