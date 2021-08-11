


myFolder = '/Users/paulchenchen/other img files/Concrete Texture';

if ~isdir(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
    uiwait(warndlg(errorMessage));
    return;
end
filePattern = fullfile(myFolder, '*.jpg');
pngFiles = dir(filePattern);




imlist = {};
parfor k = 1:length(pngFiles)
    baseFileName = pngFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    imageArray = imread(fullFileName);
    imlist {1,k} = imGradFeature(imageArray);
end

base =[];
for x = 1:6 %adding in X
    for y = 1:8 %adding in Y
        r = round ((20-1).*rand() + 1);
        x_loc = (x-1)*3864 +1;
        y_loc = (x-1)*5152 +1;
        base(y_loc: y_loc +3864, x_loc:x+5152, :,:) = imlist{1,r}(:,:,:,:);
    end
end 

base = imcrop(base,[1 1 29335 29335]);




Lf(LY:LY+h,LX:LX+w,:,:) = A(GY:GY+h,GX:GX+w,:,:);

param = buildModPoissonParam( size(base) );
Y = modPoisson( base, param, 1E-8 );
figure,imshow(Y);
imwrite(uint8(Y),'base.png');



