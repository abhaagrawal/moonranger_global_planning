% Rounak Baheti
% 03.29.21

%% General Variables

slopeLimit1 = 10; % Angle in degrees
lightingLimit1 = 0.7; % Cut-off Fraction

% Landing Site Coordinates

x_len = 15; % Number of pixels in x-direction from the landing site. Give additional clearance
y_len = 15; % Number of pixels in y-direction from the landing site. Give additional clearance

ax2 = [-150,150,-150,150];
HawSite1Lat = -86.7943;
HawSite1Lon = -21.1864;
[HawSitePX,HawSitePY] = latlon2pixel_Haw(HawSite1Lat,HawSite1Lon);

ViableMap = [floor(HawSitePX-x_len),ceil(HawSitePX+x_len),floor(HawSitePY-y_len),ceil(HawSitePY+y_len)];
ViableMapLen = [ceil(HawSitePX+x_len) - floor(HawSitePX-x_len),ceil(HawSitePY+y_len)-floor(HawSitePY-y_len)];
%% Datasets

disp('loading file variables...')

load('SP_40m_net_sun_and_sun-plus-dte_2022-12-05_to_2022-12-21_3limb');
res = 40; % 40 mpp

disp('...done')

%% Load datasets
disp('loading datasets...')
elevation = imread('ldem_80S_40m.jp2');
[pixelX1, pixelY1] = size(elevation);
xRange1 = [1:pixelX1];
xScaled1 = xRange1*0.01;
x = xScaled1 - mean(xScaled1);
y = x;
% to include the 0.5 scale factor
% to change the variable type
elevation = single(elevation);
elevation = elevation*.5;
elevation = flipud(elevation); 
% min and max elevations in meters
minimum1 = min(elevation, [], 'all');
maximum1 = max(elevation, [], 'all');

% calculate gradient
    % 10 because posting is 10 m
    [gx, gy] = gradient(elevation, 40);
    % use something.^ to apply exponentiation to the whole matrix
    slope = rad2deg(atan(sqrt(gx.^2 + gy.^2)));
    
xx=0.04*[1:size(bholdmi,1)]; % creates a polar stereographic vector axis for this array
    % QUESTION - where is the 0.04 coming from?
    % >> the posting size in km (40 m)

xx = xx-mean(xx); % it’s symmetric about the pole
yy=xx; %same on y axis

fractionLit = bholdi.*delday./dur; % this is just sun (WHAT YOU WANT)
fractionLit2 = bholdmi.*delday./dur; % this is sun and comm
disp('...done')

%% Constructing viable maps
disp('combining lighting and slopes...')

% score lighting
% adjust limit, adjust limitType
disp('beginning lighting and slope')
% all lighting maps
lightingLimitType = 'upper';
lightingMap1 = getBestParam(fractionLit, lightingLimit1, lightingLimitType);

% score slopes
slopeLimitType = 'lower';
slopeMap1 = getBestParam(slope, slopeLimit1, slopeLimitType);
disp('done')
disp('beginning combined maps')
% combine fn keeps all 0's as 0 but retains all viable values within limit
combined_S15_L70 = combine(lightingMap1, slopeMap1);

disp('...done')

%% Creating map file

viableMapWithBorder = combined_S15_L70;
for i = 2:1:length(combined_S15_L70(:,1))-2
    for j = 2:1:length(combined_S15_L70(1,:))-2
        if ((combined_S15_L70(i,j)==0) && ((combined_S15_L70(i+1,j)==1||combined_S15_L70(i,j+1)==1||combined_S15_L70(i,j-1)==1||combined_S15_L70(i-1,j)==1||combined_S15_L70(i-1,j-1)==1||combined_S15_L70(i-1,j+1)==1||combined_S15_L70(i+1,j-1)==1||combined_S15_L70(i+1,j+1)==1)))
            viableMapWithBorder(i,j) = 1;
        end
    end
end
%% Without borders - create image

figure(1)
imagesc(combined_S15_L70(ViableMap(3):ViableMap(4),ViableMap(1):ViableMap(2)));
%axis(ViableMap)
colorbar;

%% With borders - create image

figure(2)
imagesc(viableMapWithBorder);
axis(ViableMap)
colorbar;

%% With borders - create file

figure(3)
imagesc(viableMapWithBorder(ViableMap(3): ViableMap(4),ViableMap(1): ViableMap(2)));
%dlmwrite('ViableMap.txt', viableMapWithBorder(ViableMap(3): ViableMap(4),ViableMap(1): ViableMap(2)));

%% Functions
disp('generating functions...')
% get best parameter matrix (lighting or slope)
% mat = type matrix, original map of data
% limit = number, must understand the max and mins of your matrix, enter a
% lower or upper limit considering that matrix
% limitType = 'upper' or 'lower' for the limit you gave
function [bestParamMat] = getBestParam(mat, limit, limitType)
    % filter out no-go areas
    bestParamMat = mat;
    if limitType == 'upper'
        bestParamMat(mat >= limit) = 0; 
        bestParamMat(mat < limit) = 1;
    elseif limitType == 'lower'
        bestParamMat(mat > limit) = 1;
        bestParamMat(mat <= limit ) = 0;
    else
        disp('please change limitType to <upper> or <lower> as a str')
    end
end

% combine matrices
function [combinedMat] = combine(mat1, mat2)
   combinedMat = mat1 .* mat2;
end

% get slope from elevation
function [slope] = getSlope(elevationMat)
    disp('creating slope from elevation . . .')
    % 40 because posting is 40 m
    [gx, gy] = gradient(elevationMat, 40);
    % use something.^ to apply exponentiation to the whole matrix
    slope = rad2deg(atan(sqrt(gx.^2 + gy.^2)));
    disp('done')
end
