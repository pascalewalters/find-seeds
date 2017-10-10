function im_seed = findSeeds3(im_crop)
% Process the image to find the four seeds
% 
% Params:
%   im_crop: cropped image that contains the four seeds with adjusted contrast
% Returns:
%   binary image of the four seeds 

im_sharpen = imsharpen(im_crop);

% Create a binary gradient mask using Sobel operator
[~, threshold] = edge(im_sharpen, 'sobel');
fudgeFactor = 2.1;
BWs = edge(im_sharpen, 'sobel', threshold * fudgeFactor);

% Dilate the image using linear structuring elements to remove gaps in the
% gradient mask
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);

% Clean up the image by clearing all objects that are connected to the
% border of the image
BWnobord = imclearborder(BWsdil, 4);

% Smoothen the object by eroding it twice with a diamond structuring
% element
seD = strel('diamond', 1);
BWseedImage = imerode(BWnobord, seD);
BWseedImage = imerode(BWseedImage, seD);

im_seed = BWseedImage;

end



