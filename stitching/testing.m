%{
c3 = (imread('processed/label5_1.png'));
imshow(c3);
%get rid of small gaps
se = strel('disk',10);

closeBW = imclose(c3,se);
closeBW = imresize(closeBW,0.1);

figure, imshow(closeBW);

stats = regionprops(closeBW,'PixelList');
Box = regionprops(closeBW,'BoundingBox');
boundingb = struct2cell(Box);
plist = struct2cell(stats);
i = 1;
imcrop(closeBW, [boundingb{i}(1) boundingb{i}(2) boundingb{i}(3) boundingb{i}(4)]);
%figure, imshow(closeBW);
%}
%%
%{
myFolder = '/Users/paulchenchen/image-processing/stitching/processed/part3';

if ~isdir(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
    uiwait(warndlg(errorMessage));
    return;
end
filePattern = fullfile(myFolder, '*.png');
pngFiles = dir(filePattern);
se = strel('disk',9);
Box_All = {};
plist = {};
for k = 1:length(pngFiles)
	baseFileName = pngFiles(6-k).name;
	fullFileName = fullfile(myFolder, baseFileName);
	fprintf(1, 'Now reading %s\n', fullFileName);
	imageArray = imread(fullFileName);

    %connecting pixels are are really close to fill up some small gaps
	imageArray = imclose(imageArray,se);
    
    %convert struct into cellarray
	pixels = struct2cell(regionprops(imageArray,'PixelList'));
	Box = struct2cell(regionprops(imageArray,'BoundingBox'));
    
       [newx,newy] = size(Box);

        plist(6-k,1:newy) = pixels;
        Box_All(6-k,1:newy) = Box;
        
        % compare if the cracks are the previous version of one's in exp5
        % or not
        
        [x,y] = size(Box_All);
        [newx,newy] = size(Box);
        z = 1;
        %{
        %(norm([x_ y_] - [Crack(1) Crack(2)]) < 100 || ( (x_ > Crack(1)) && (y_ > Crack(2)) )) && (norm([x_+w y_+h] - [Crack(1)+Crack(3) Crack(2)+Crack(4)]) < 100 || ( (x_+ w) < (Crack(1) + Crack(3)) && (y_+h)< (Crack(2) < Crack(4) )))
        for M = 1:y
            if(z>newy)
                return
            end
            %new input crack
            x_ = Box{z}(1);y_ = Box{z}(2);
            %crack from exp5 crack = [x y wid height]
            Crack = Box_All{5,M};
            
            if(norm([x_ y_] - [Crack(1) Crack(2)]) < 100 || ( (x_ - Crack(1)) < Crack(3) && (y_ - Crack(2)) < Crack(4) ) )
                plist(6-k,M) = pixels(1,z);
                Box_All(6-k,M) = Box(1,z);
                z=z+1;
            end
        end 
        %}
   
    
	figure,imshow(imageArray);  % Display image.
	drawnow; % Force display to update immediately.
end
%}
%% 
%{
%numbers of cracks 
num_cracks_add = 150;

%area within blank to put cracks
x_max = 8500; 
x_min = 500;
y_max = 8500;
y_min = 500;

%declaring blank
blank = zeros(10000,10000,'logical');

assigned = [0,0,0,0]; %[x y crack degree]

[~,num_cracks] = size(Box);
exp5 = blank;
for i = 1:num_cracks_add
    %get a random crack 1:num_cracks
    crack = round ((num_cracks-1)*rand()+1);
    while 1
        %looping until finds a place to put crack
        %random x & y inside blank
        x = round ((x_max-x_min)*rand()+x_min);
        y = round ((y_max-y_min)*rand()+y_min);
        %width and height of the bounding box of the crack
        w = Box{5,crack}(3);
        h = Box{5,crack}(4);
        
        to_add = accumarray([plocation{5,crack}(:,2) plocation{5,crack}(:,1)],1); %crack to add
        current_area = imcrop(exp5,[x y w h]); %data of that current area
        if (intersect(current_area,to_add)==0)
            
            %replace if no intersect
            exp5(y:y+h, x:x+w) = xor(to_add(:,:),exp5(y:y+h, x:x+w));
            assigned(i,1:3) = [x,y,crack];
            break;
        end
    end
end
figure,imshow(exp5);
imwrite (exp5, 'exp5_rand.png')


for exp = 1:4
    temp = blank;
    for num_cracks = 1:num_cracks_add
        crack = assigned(num_cracks,3);
        x = assigned(num_cracks,1);
        y = assigned(num_cracks,2);
        if(size(Box{exp,crack}) > 0)
            w = Box{exp,crack}(1) + Box{exp,crack}(3)-1;
            h = Box{exp,crack}(2) + Box{exp,crack}(4)-1;
            to_add = accumarray([plocation{exp,crack}(:,2) plocation{exp,crack}(:,1)],1);
            temp(y:y+h, x:x+w) = xor(to_add(:,:),temp(y:y+h, x:x+w)) ;
        end
    end
    figure,imshow(temp);
    imwrite (temp, 'exp' + string(exp) + '_rand.png');
end
%}
%%
%randomized crack without rotations
%{

%getting a randomized crack in certain area


%numbers of cracks 
num_cracks_add = 150;

%area within blank to put cracks
x_max = 8500; 
x_min = 500;
y_max = 8500;
y_min = 500;

%declaring blank
%blank = zeros(29335,29335,'logical');
blank = zeros(10000,10000,'logical');

assigned = [0,0,0,0]; %[x y crack degree]

[~,num_cracks] = size(Box);
exp5 = blank;
for i = 1:num_cracks_add
    %get a random crack 1:num_cracks
    crack = round ((num_cracks-1)*rand()+1);
    while 1
        %looping until finds a place to put crack
        %random x & y inside blank
        x = round ((x_max-x_min)*rand()+x_min);
        y = round ((y_max-y_min)*rand()+y_min);
        %width and height of the bounding box of the crack
        w = Box{5,crack}(3);
        h = Box{5,crack}(4);
        
        to_add = accumarray([plocation{5,crack}(:,2) plocation{5,crack}(:,1)],1); %crack to add
        current_area = imcrop(exp5,[x y w h]); %data of that current area
        if (intersect(current_area,to_add)==0)
            
            %replace if no intersect
            exp5(y:y+h, x:x+w) = xor(to_add(:,:),exp5(y:y+h, x:x+w));
            assigned(i,1:3) = [x,y,crack];
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
        crack = assigned(num_cracks,3);
        x = assigned(num_cracks,1);
        y = assigned(num_cracks,2);
        if(size(Box{exp,crack}) > 0)
            w = Box{exp,crack}(1) + Box{exp,crack}(3)-1;
            h = Box{exp,crack}(2) + Box{exp,crack}(4)-1;
            to_add = accumarray([plocation{exp,crack}(:,2) plocation{exp,crack}(:,1)],1);
            temp(y:y+h, x:x+w) = xor(to_add(:,:),temp(y:y+h, x:x+w)) ;
        end
    end
    figure,imshow(temp);
    %imwrite (temp, 'exp' + string(exp) + '_rand.png');
end
%}
%%
%{
blank = zeros(1000,1000,'logical');
theta=120; %TO ROTATE CLOCKWISE BY X DEGREES
R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; %CREATE THE MATRIX
rotp = plocation{5,1} * R';
to_add = accumarray([plocation{5,1}(:,2) plocation{5,1}(:,1)],1);
%rotate_box = []
%shifting due to rotation
x_shift = abs(min(rotp(:,1)))+50;
y_shift = abs(min(rotp(:,2)))+50;
rotp(:,2) = round (rotp(:,2) + y_shift + 1);
rotp(:,1) = round (rotp(:,1) + x_shift + 1);
se = strel('disk',5);

rot_test = accumarray([rotp(:,2) rotp(:,1)],1);
rot_test = imclose(rot_test,se);

x = 100;
y = 100;
%left = min()
blank(y:y-1+max(rotp(:,2)), x:x-1+max(rotp(:,1))) = xor(rot_test(:,:),blank(y:y-1+max(rotp(:,2)), x:x-1+max(rotp(:,1))));
figure,imshow(blank);

%add another one on top of that but at 200,200
theta=90; %TO ROTATE CLOCKWISE BY X DEGREES
R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; %CREATE THE MATRIX
rotp = plocation{1,1} * R';
to_add = accumarray([plocation{1,1}(:,2) plocation{1,1}(:,1)],1);
rotp(:,2) = round (rotp(:,2) + y_shift + 1);
rotp(:,1) = round (rotp(:,1) + x_shift + 1);

rot_test = accumarray([rotp(:,2) rotp(:,1)],1);
x = 100;
y = 200;
%left = min()
blank(y:y-1+max(rotp(:,2)), x:x-1+max(rotp(:,1))) = xor(rot_test(:,:),blank(y:y-1+max(rotp(:,2)), x:x-1+max(rotp(:,1))));
figure,imshow(blank);
%}

%%

%exp_0 background
[b1,p1] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part1',10);
[b2,p2] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part2',10);
[b3,p3] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part3',10);


%normalize the plocation base on the latest crack(exp5)
[BBox,pplocation] = normalizecracks([b1 b2 b3],[p1 p2 p3]);

A = p3{4,5}; %exp5_2
B = p3{5,5}; %exp4_2
exp4_2 = accumarray([A(:,2) A(:,1)],1);
exp5_2 = accumarray([B(:,2) B(:,1)],1);
figure; subplot(1,3,1); imshow(exp4_2);
subplot(1,3,2); imshow(exp5_2);  
subplot(1,3,3); imshow(BW2);  

%{
A = reference{5,7}; %exp5_2
B = reference{4,7}; %exp4_2

exp5_2 = accumarray([A(:,2) A(:,1)],1);
exp4_2 = accumarray([B(:,2) B(:,1)],1);

SE = strel('rectangle',[8 8]);
BW2 = imdilate(exp5_2,SE);
figure; subplot(1,3,1); imshow(exp4_2);
subplot(1,3,2); imshow(exp5_2);  
subplot(1,3,3); imshow(BW2);  

pixels = struct2cell(regionprops(BW2,'PixelList'));
Box = struct2cell(regionprops(BW2,'BoundingBox'));
%}