%%
%retrieving and sort multiple cracks that are inside the same image 
%same cracks in different images need to be somewhat aligned for this to
%work.
%file names in the folder must be in [name]1.png, [name]2.png ... for 
%different timesteps of the crack, which [name]1.png is the oldest timestep 
%that has the smallest or least cracks. 
%image must only contrain logical data (0 or 1)
%Sortcracks(folderlocation, threshold of pixels to connect some mistakenly disconnected cracks)
%returning[boundingbox{}, pixellocations{}] are {timesteps x cracknum}

%[b1,p1] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part1',10);
%[b2,p2] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part2',10);
%[b3,p3] = Sortcracks('/Users/paulchenchen/image-processing/stitching/processed/part3',10);

%%
%generate random cracks with different timestep
%cracklist_generator(timesteps,cracknumbers);
%returning[boundingbox{}, pixellocations{}] are {timesteps x cracknum}

[b4,p4] = cracklist_generator(10,50);


%%
%normalizecracks(boundingbox{}, pixellocations{})
%normalize the plocation base on the latest crack(exp5)

%[Box,plocation] = normalizecracks([b1 b2 b3],[p1 p2 p3]);
[Box,plocation] = normalizecracks(b4,p4);


%%
% randomcrackplacing(pixel locations in array cell{timesteps x crack num},
%            Width, Height , numbers of cracks to place, files saved name)
% Call function without the savename if don't wish to save directly.
% can return an cell array containing areas of cracks if assigned to a variable
% The following generates and saves images of 5000x5000 pixels with 5 cracks

x = randomcrackplacing(p4, 5000, 5000, 30, 'randomcrackgen');
%x = randomcrackplacing(p4, 5000, 5000, 30) %not to save the images