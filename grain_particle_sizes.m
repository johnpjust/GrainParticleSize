quantileVal = 0.90;
rect = [62.5100   20.5100  596.9800  438.9800];
I = imread('C:\Users\just\Desktop\NG3_GQ_Corn_11MC_59lbs_50F_2017-11-16_11-0-33_Sensor-1_Frame-36_Ts-1510851850.1548.png');
% I = imread('NG3_GQ_Corn_32MC_53lbs_99F_2017-7-18_10-31-45_Sensor-1_Frame-32_Ts-1500374550.1573.png');
Irs = imcrop(I, rect);
light_scalar = 80/double(quantile(Irs(:),quantileVal));
%%% background = imread('C:\Users\justjo\Desktop\background.png');
Irs_res = uint8(double(Irs)*light_scalar);
%%% subtract off background vignetting
% [BW,~] = createMask2(Irs_res);

background = imgaussfilt(double(Irs_res),60); %60
J = double(Irs_res)-double(background);J = uint8(Irs_res - min(J(:)));
background = imgaussfilt(double(J),30); %60
J2 = double(Irs_res)-double(background);J2 = uint8(Irs_res - min(J2(:)));
background = imgaussfilt(double(J2),5); %60
I2 = double(Irs_res)-double(background);I2 = uint8(I2 - min(I2(:)));

%% watershed matlab example #1:  Segmenting Steel Grains
% https://www.mathworks.com/company/newsletters/articles/the-watershed-transform-strategies-for-image-segmentation.html

%% watershed MATlab example #2
gmag = imgradient(I);
imshow(gmag,[])
title('Gradient Magnitude')

L = watershed(gmag);
Lrgb = label2rgb(L);
imshow(Lrgb)
title('Watershed Transform of Gradient Magnitude')

%%
% A variety of procedures could be applied here to find the foreground markers, 
% which must be connected blobs of pixels inside each of the foreground objects. 
% In this example you'll use morphological techniques called "opening-by-reconstruction" 
% and "closing-by-reconstruction" to "clean" up the image. These operations 
% will create flat maxima inside each object that can be located using imregionalmax.
% 
% Opening is an erosion followed by a dilation, while opening-by-reconstruction 
% is an erosion followed by a morphological reconstruction. Let's compare the two. 
% First, compute the opening using imopen.

se = strel('disk',20);
Io = imopen(I,se);
imshow(Io)
title('Opening')
%%
%Next compute the opening-by-reconstruction using imerode and imreconstruct.
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
imshow(Iobr)
title('Opening-by-Reconstruction')

% Following the opening with a closing can remove the dark spots and stem marks. 
% Compare a regular morphological closing with a closing-by-reconstruction. First try imclose:
Ioc = imclose(Io,se);
imshow(Ioc)
title('Opening-Closing')
%%
% Now use imdilate followed by imreconstruct. Notice you must complement the image inputs and output of imreconstruct.
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imshow(Iobrcbr)
title('Opening-Closing by Reconstruction')
%%
% As you can see by comparing Iobrcbr with Ioc, reconstruction-based opening 
% and closing are more effective than standard opening and closing at removing 
% small blemishes without affecting the overall shapes of the objects. Calculate
% the regional maxima of Iobrcbr to obtain good foreground markers.
fgm = imregionalmax(Iobrcbr);
imshow(fgm)
title('Regional Maxima of Opening-Closing by Reconstruction')
%%
% To help interpret the result, superimpose the foreground marker image on the original image.
I2 = labeloverlay(I,fgm);
imshow(I2)
title('Regional Maxima Superimposed on Original Image')
%%
% Notice that some of the mostly-occluded and shadowed objects are not marked, 
% which means that these objects will not be segmented properly in the end result. 
% Also, the foreground markers in some objects go right up to the objects' edge. 
% That means you should clean the edges of the marker blobs and then shrink them a bit. 
% You can do this by a closing followed by an erosion.
%%
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);
%%
% This procedure tends to leave some stray isolated pixels that must be removed. 
% You can do this using bwareaopen, which removes all blobs that have fewer than 
% a certain number of pixels.

fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
imshow(I3)
title('Modified Regional Maxima Superimposed on Original Image')
