function [BW] = single_crack_generator(w,h,radiusSE)

    %maximum size of the crack

    imSize = [h w];
    sigma = 5;

    % Radii and width of the seams
    
    i=1;
    SE = strel('disk', radiusSE);
    OutputStruct(i).width_actual_record = size(SE.Neighborhood,1) - 1; %radiusSE * 2 + 2;

    width_actual = size(SE.Neighborhood,1) - 1;

    if (rand(1) > 0.5)
        Im = randn(imSize);
    else
        Im = rand(imSize);
    end

    % returns energy of all pixels
    energy = abs(imfilter(Im, [-1,0,1], 'replicate')) + abs(imfilter(Im, [-1;0;1], 'replicate'));    

    if (rand(1) > 0.5)
        % finds optimal seam using shortest distance
        % mask with 0 mean a pixel is in the seam

        % find M for vertical seams
        % for vertical - use I`
        M = padarray(energy, [0 1], realmax('double')); % to avoid handling border elements

        sz = size(M);
        for i = 2 : sz(1)
            for j = 2 : (sz(2) - 1)
                neighbors = [M(i - 1, j - 1) M(i - 1, j) M(i - 1, j + 1)];
                M(i, j) = M(i, j) + min(neighbors);
            end
        end

        % find the min element in the last raw
        [val, indJ] = min(M(sz(1), :));
        seamEnergy = val;

        optSeamMask = false(size(energy));

        %go backward and save (i, j)
        for i = sz(1) : -1 : 2
            %optSeam(i) = indJ - 1;
            optSeamMask(i, indJ - 1) = 1; % -1 because of padding on 1 element from left
            neighbors = [M(i - 1, indJ - 1) M(i - 1, indJ) M(i - 1, indJ + 1)];
            [val, indIncr] = min(neighbors);

            seamEnergy = seamEnergy + val;

            indJ = indJ + (indIncr - 2); % (x - 2): [1,2]->[-1,1]]
        end

        optSeamMask(1, indJ - 1) = 1; % -1 because of padding on 1 element from left
        optSeamMask = ~optSeamMask;

        seam = imcomplement(optSeamMask);


    else
        % finds optimal seam using longest distance
        % returns mask with 0 mean a pixel is in the seam

        % find M for vertical seams
        % for vertical - use I`
        M = 1 ./ padarray(energy, [0 1], realmax('double')); % to avoid handling border elements

        sz = size(M);
        for i = 2 : sz(1)
            for j = 2 : (sz(2) - 1)
                neighbors = [M(i - 1, j - 1) M(i - 1, j) M(i - 1, j + 1)];
                M(i, j) = M(i, j) + max(neighbors);
            end
        end

        % find the min element in the last raw
        [val, indJ] = max(M(sz(1), :));
        seamEnergy = val;

        optSeamMask = false(size(energy));

        %go backward and save (i, j)
        for i = sz(1) : -1 : 2
            %optSeam(i) = indJ - 1;
            optSeamMask(i, indJ - 1) = 1; % -1 because of padding on 1 element from left
            neighbors = [M(i - 1, indJ - 1) M(i - 1, indJ) M(i - 1, indJ + 1)];
            [val, indIncr] = max(neighbors);

            seamEnergy = seamEnergy + val;

            indJ = indJ + (indIncr - 2); % (x - 2): [1,2]->[-1,1]]
        end

        optSeamMask(1, indJ - 1) = 1; % -1 because of padding on 1 element from left
        optSeamMask = ~optSeamMask;
        seam = imcomplement(optSeamMask);
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

    % Profiling Image 
    Img = dilateSeam;
    Img_comp = imcomplement(Img);
    GaussFiltSize = width_actual^1.6;
    GaussFiltSize = GaussFiltSize-mod(GaussFiltSize,2)+1;

    ImgSmooth = imgaussfilt(double(Img_comp), sigma,'FilterSize', GaussFiltSize);
    ImgSmooth_comp = imcomplement(ImgSmooth);
    BW = imbinarize(ImgSmooth_comp);
    %figure,imshow(BW);
    
end

