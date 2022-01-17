function [] = showcracks(cracklist)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    k = 1;
    se = strel('disk',5);
    figure();
    
    [version, number] = size (cracklist);
    for i = 1:version
        for j = 1:number
            c = zeros(max(cracklist{version,j}(:,2)),max(cracklist{version,j}(:,1)),'logical');
    
            if(size(cracklist{i,j}) > 0)
                crack = imclose(accumarray([cracklist{i,j}(:,2) cracklist{i,j}(:,1)],1),se);
                [h w] = size (crack);
                c(1:h,1:w) = xor(crack(:,:),c(1:h,1:w)); 
            end
            subplot(version,number,k);
            imshow(c);
            k = k+1;
        end
    end 
end