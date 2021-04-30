% Lydia Schweitzer
% 02.07.2021

% Ron Baheti
% 04.21.2021


%% 0) general variables

lat = -86.7943;
lon = -21.1864;

disp('generating variables...')
color1 = bone;
color2 = parula;
color3 = gray;
color4 = hot;

slopeLimit1 = 10;

lightingLimit1 = 0.7;
disp('...done')

%% 1) load file variables
disp('loading file variables...')

load('SP_40m_net_sun_and_sun-plus-dte_2022-12-05_to_2022-12-21_3limb');
res = 40; % 40 mpp

disp('...done')

%% 2) load datasets
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

%% 3) construct viable maps
disp('combining lighting and slopes...')

% score lighting
% adjust limit, adjust limitType
disp('beginning lighting and slope')
% all lighting maps
lightingLimitType = 'lower';
lightingMap1 = getBestParam(fractionLit, lightingLimit1, lightingLimitType);

% score slopes
slopeLimitType = 'upper';
slopeMap1 = getBestParam(slope, slopeLimit1, slopeLimitType);
disp('done')

disp('beginning combined maps')
%%
zoomR = 600/res;
[hawPixelX, hawPixelY] = latlon2pixel_Haw(lat,lon);
hawC = [hawPixelX, hawPixelY];
hawaxis = [hawPixelX - zoomR, hawPixelX + zoomR, hawPixelY - zoomR, hawPixelY + zoomR];
combined_S15_L70 = combine(lightingMap1, slopeMap1);
figure(10)
imagesc(combined_S15_L70)
axis(hawaxis)
disp('...done')

%% 4) Creating distortion boundary
combine_with_border = combined_S15_L70;
for i = 2:15200-1
    for j = 2:15200-1
        if (combined_S15_L70(i,j)==1 && (combined_S15_L70(i+1,j)==0 || combined_S15_L70(i-1,j)==0 || combined_S15_L70(i,j+1)==0 || combined_S15_L70(i,j-1)==0 || combined_S15_L70(i+1,j+1)==0 || combined_S15_L70(i-1,j+1)==0 || combined_S15_L70(i+1,j-1)==0 || combined_S15_L70(i-1,j-1)==0 ))
            combine_with_border(i,j)=0;
        end
    end
end

%% 5) Saving Maps as .txt files

smallmap = combined_S15_L70(floor(hawPixelY - zoomR): ceil(hawPixelY + zoomR),floor(hawPixelX - zoomR): ceil(hawPixelX + zoomR));

map = smallmap;
map(smallmap==0)=1;
map(smallmap==1)=0;

writematrix(smallmap,'map_MS.txt','Delimiter',' ')
writematrix(map,'map_SBPL.txt','Delimiter',' ')

%% 6) functions
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
            % Above the limit is a no-go
            bestParamMat(mat >= limit) = 0;
            % Below the limit is a go
            bestParamMat(mat < limit) = 1;%(bestParamMat/-matMax) + 1;
        elseif limitType == 'lower'
            % Below the limit is a no-go
            bestParamMat(mat <= limit) = 0;
            % Below the limit is a go
            bestParamMat(mat > limit) = 1;%bestParamMat/matMax;
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

return
