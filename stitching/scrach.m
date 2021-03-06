%numbers of cracks 
num_cracks_add = 170;

%area within blank to put cracks
x_max = 8500; 
x_min = 500;
y_max = 8500;
y_min = 500;

%declaring blank
%blank = zeros(29335,29335,'logical');
blank = zeros(10000,10000,'logical');

assigned = [0,0,0,0,0,0]; %[x y crack degree xshift yshift]

%fill up some gaps due to imperfect rotation roundings
se = strel('disk',5);

[~,num_cracks] = size(Box);
exp5 = blank;
for i = 1:num_cracks_add
    %get a random crack 1:num_cracks
    crack = round ((num_cracks-1)*rand()+1);
    times = 0;

    while 1
        %looping until finds a place to put crack
        %random x & y inside blank
        x = round ((x_max-x_min)*rand()+x_min);
        y = round ((y_max-y_min)*rand()+y_min);
        %random angle
        theta = round (359*rand());
        %CREATE THE MATRIX
        R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
        %rotate the datapoints
        rotp = plocation{5,crack} * R';

        
        x_shift = abs(min(rotp(:,1)))+50;
        y_shift = abs(min(rotp(:,2)))+50;
        
        rotp(:,2) = round (rotp(:,2) + y_shift + 1);
        rotp(:,1) = round (rotp(:,1) + x_shift + 1);

        rot_test = imclose(accumarray([rotp(:,2) rotp(:,1)],1),se);
        %width and height of the bounding box of the crack
        w = max(rotp(:,1));
        h = max(rotp(:,2));

        
        current_area = imcrop(exp5,[x y w h]); %data of that current area
        if (intersect(current_area,to_add)==0)
            
            %replace if no intersect
            exp5(y:y-1+h, x:x-1+w) = xor(rot_test(:,:),blank(y:y-1+h, x:x-1+w));
            assigned(i,1:6) = [x,y,crack,theta,x_shift,y_shift];
            break;
        end
        times = times +1;
        if (times >250)
            num_cracks_add = i-1;
            break;   
        end 
    end
end
figure,imshow(exp5);
%imwrite (exp5, 'exp5_rand.png')
%generate the cracks for other exps
for exp = 1:4
    temp = blank;
    for num_cracks = 1:num_cracks_add
        x_shift = assigned(num_cracks,5);
        y_shift = assigned(num_cracks,6);
        theta = assigned(num_cracks,4);
        crack = assigned(num_cracks,3);
        x = assigned(num_cracks,1);
        y = assigned(num_cracks,2);
        if(size(Box{exp,crack}) > 0)
            %CREATE THE rotation MATRIX
            R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; 
            %rotate the datapoints
            rotp = plocation{5,crack} * R';
            rotp(:,2) = round (rotp(:,2) + y_shift + 1);
            rotp(:,1) = round (rotp(:,1) + x_shift + 1);

            rot_test = imclose(accumarray([rotp(:,2) rotp(:,1)],1),se);
            %width and height of the bounding box of the crack
            w = max(rotp(:,1));
            h = max(rotp(:,2));
            
            to_add = accumarray([plocation{exp,crack}(:,2) plocation{exp,crack}(:,1)],1);
            temp(y:y-1+h, x:x-1+w) = xor(rot_test(:,:),blank(y:y-1+h, x:x-1+w));
        end
    end
    figure,imshow(temp);
    %imwrite (temp, 'exp' + string(exp) + '_rand.png');
end
