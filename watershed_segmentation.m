

%    MARKER CONTROLLED WATERSHED SEGMENTATION

rgb = imread('apples.jpg');
figure
imshow(rgb)
I = rgb2gray(rgb);   %converting rgb image to grayscale
figure
imshow(I)

%% First we compute the gradient magnitude. The gradient(gradient is a directional change in the intensity or 
...color in an image) is high at the borders of the objects and low inside the objects. 

gmag = imgradient(I);
imshow(gmag,[])
title('Gradient Magnitude')
%%
hy = fspecial('sobel');
% creates a two-dimensional filter h of the specified type. fspecial returns h as a correlation kernel, 
% which is the appropriate form to use with imfilter. type is a string having one of these values.
hx = hy';
Iy = imfilter(double(I),hy,'replicate');  % image with replicate boundaries
Ix = imfilter(double(I),hx,'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure
imshow(gradmag,[]),title('Gradient Magnitude(gradmag)')

%% Computing the gradient magnitude...
...The gradient is high at the borders of the objects and low (mostly) inside the objects.
L= watershed(gradmag);  % L is a labelled matrix image
Lrgb = label2rgb(L);
figure,imshow(Lrgb),title('Watershed transform of gradient magnitude(Lrgb)');

%% Mark the Foreground Objects
%A variety of procedures could be applied here to find the foreground markers, 
%which must be connected blobs of pixels inside each of the foreground objects. 
%In this example we'll use morphological techniques called "opening-by-reconstruction" and "closing-by-reconstruction" 
%to "clean" up the image. These operations will create flat maxima 
%inside each object that can be located using imregionalmax.
%Opening is an erosion followed by a dilation, while opening-by-reconstruction is an erosion followed by a morphological reconstruction. Let's compare the two. First, compute the opening using imopen

se = strel('disk',20);
Io = imopen(I,se);
figure
imshow(Io),title('Opening(Io)')

%% computing the opening-by-reconstruction using imerode and imreconstruct.

Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
figure
imshow(Iobr),title('Opening-by-reconstruction (Iobr)');

%% Following the opening with a closing can remove the dark spots and stem marks. Compare a regular morphological closing with a closing-by-reconstruction. 
%First try imclose:
Ioc = imclose(Io,se);
figure
imshow(Ioc) , title('Opening-closing(Ioc)')

%% Now using imdilate followed by imreconstruct. Notice we must complement the image inputs and output of imreconstruct
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
figure
imshow(Iobrcbr), title('Opening- Closing by reconstruction(Iobrcbr)')

%% As you can see by comparing Iobrcbr with Ioc, reconstruction-based opening and closing are more effective than standard opening and closing at removing small blemishes without affecting the overall shapes of the objects. 
%Calculating the regional maxima of Iobrcbr to obtain good foreground markers.
fgm = imregionalmax(Iobrcbr);
figure
imshow(fgm),title('Regional Maxima of Opening-Closing b reconstruction(fgm)')

%% To help interpret the result, superimposing the foreground marker image on the original image.
I2 = I;
I2(fgm) = 255;
figure
imshow(I2),title('Regional maxima superimposed on original image(I2)')
%%
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);
%%
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
figure
imshow(I3)
title('Modified regional maxima superimposed on original image (fgm4)')
%%
bw = imbinarize(Iobrcbr);
imshow(bw)
title('Thresholded Opening-Closing by Reconstruction')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure
imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);

L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure
imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure
imshow(Lrgb)
title('Colored watershed label matrix (Lrgb)')

figure
imshow(I)
hold on
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title('Lrgb superimposed transparently on original image')

