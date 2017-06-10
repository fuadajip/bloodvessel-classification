%% CLEAR
clear;
close all;

%% READ AN ORIGINAL IMAGE
img = imread('dataset/rgb/02_test.tif');
figure,imshow(img),title('Original img');

%% GREEN CHANNEL EXTRACTION
greenc = img(:,:,2);                            % Extract GreenChannel
figure,imshow(greenc),title('Green Channel Img');
ginc = imcomplement (greenc);                   % Complement the GreenChannel
adahist = adapthisteq(ginc);                    % Adaptive Histogram Equalization
adahist = imadjust(adahist,[0.3 0.9],[]);

 %% REMOVING OPTIC DISK
se = strel('ball',8,8);                         % Strel ball with 8x8
gopen = imopen(adahist,se);                     % Morphological Open
goptic = adahist - gopen;                       % Substract to remove OD
figure,imshow(goptic),title('Eliminating Optic Disc');

%% Median Filter
medfilt = medfilt2(goptic);  
medfilt = imsharpen(medfilt,'Radius',25,'Amount',2);
background = imopen(medfilt,strel('disk',15));  % imopen function
I2 = medfilt - background;                      % Remove Background
I3 = imadjust(I2);                              % Image Adjustment
levelMedFilt = graythresh(I3);                  % Gray Threshold
bwMedFilt = im2bw(I3,levelMedFilt);             % Binarization
bwMedFilt = bwareaopen(bwMedFilt, 100);          % Morphological Open
figure,imshow(bwMedFilt),title('Median Filter Vessel Segmentation');
 %% Gaussian Filter
gaussfilt = imgaussfilt(goptic);   
gaussfilt = imsharpen(gaussfilt,'Radius',25,'Amount',2);
background1 = imopen(gaussfilt,strel('disk',15));% imopen function
I4 = medfilt - background1;                      % Remove Background
I5 = imadjust(I4);                               % Image Adjustment
levelGaussFilt = graythresh(I5);                 % Gray Threshold
bwGauss = im2bw(I5,levelGaussFilt);              % Binarization
bwGauss = bwareaopen(bwGauss, 100);               % Morphological Open
figure,imshow(bwGauss),title('Median Filter Vessel Segmentation');

%% Skeletonizing
vesselMaskMedFilt = bwmorph(bwMedFilt,'skel',Inf);          % Skeletonize the Vessels Mask
vesselMaskMedFilt = bwmorph(vesselMaskMedFilt,'spur',5);    % Remove spur from image
figure,imshow(vesselMaskMedFilt),title('Median Filter Skeleton');
vesselMaskGauss = bwmorph(bwGauss,'skel',Inf);              % Skeletonize the Vessels Mask   
vesselMaskGauss = bwmorph(vesselMaskGauss,'spur',5);        % Remove spur from image
figure,imshow(vesselMaskGauss),title('Gaussian Filter Skeleton');

%% Bifurcation Points
bifurcationPointsMedFilt = bwmorph(vesselMaskMedFilt,'branch',1);
bifurcationPointsMedFilt = imdilate(bifurcationPointsMedFilt,strel('disk',1));
figure,imshow(bifurcationPointsMedFilt),title('Median Bifucration Points');
bifucrationPointsGauss = bwmorph(vesselMaskGauss,'branch',1);
bifucrationPointsGauss = imdilate(bifucrationPointsGauss,strel('disk',1));
figure,imshow(bifurcationPointsMedFilt),title('Gaussian Bifucration Points');

%% Combination Bifurcation Points with Vessel Skeleton
turtuosityMedFilt = vesselMaskMedFilt & ~bifurcationPointsMedFilt;
figure,imshow(turtuosityMedFilt),title('Median Turtuosity');
turtuosityGauss = vesselMaskGauss & ~bifucrationPointsGauss;
figure,imshow(turtuosityGauss),title('Gauss Turtuosity');

%% Med Filt Mapped Skeleton to Green Channel
figure,imshow(greenc),title('Green Channel Img')
vesselOverlayMedFilt = showMaskAsOverlay(0.8, vesselMaskMedFilt,'r');
figure,imshow(vesselOverlayMedFilt),title('Mapped Blood Vessel');

%% Gauss Mapped Skeleton to Green Channel
figure,imshow(greenc),title('Green Channel Img')
vesselOverlayGauss = showMaskAsOverlay(0.8, vesselMaskGauss,'b');
figure,imshow(vesselOverlayGauss),title('Mapped Blood Vessel');