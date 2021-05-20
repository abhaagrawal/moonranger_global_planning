%% NOTE: This code is outdated

% Lydia Schweitzer
% 02.07.2021

%% 0) general variables
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

%% 2) load landing site axis variables
disp('loading site variables...')
ax2 = [-150,150,-150,150];
hawSite1Big = [-35.291909278653776,-34.896672416655660,90.430352566217750,90.825589428215850];
disp('...done')

%% 3) load datasets
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

%% 6.1 view lighting
disp('viewing all global maps...')
% LIGHTING:
    figure(11); 
    imagesc(fractionLit); % map of fraction of time in the Dec 7 – 18, 2022 timeframe that both sun & comm are available.
    axis equal;
    colorbar;
    colormap(jet);
    xlabel('X (px)');ylabel('Y (px)');
    title('Sun & Comm availability fraction');
    set(gca,'ydir','normal')
    %axis(ax2);   
%% 6.3 view elevation
% 3) ELEVATION MAP ********************************************************
    figure(12); % this is elevation
    colormap(color3);
    %clims = [10 60];
    % number of kilometers per degree -> this map (JP2)
    imagesc(elevation); % image rendering command
    set(gca, 'ydir', 'normal');
    axis equal;
    colorbar
    xlabel('X (px)');ylabel('Y (px)');
    title('LRO LOLA Elevation Data (m)');
    %axis(ax2);

%% 6.4 view slope
% 4) SLOPE MAP ************************************************************    
    figure(13); % this is slope
    colormap jet
    imagesc(slope);
    set(gca, 'ydir', 'normal'); % generally do this for all images
    colorbar
    xlabel('X (px)');ylabel('Y (px)');
    title('LRO LOLA Slope Data (deg)');
    %axis(ax3);
    caxis([0 20])
    axis equal;
    %axis(ax2);

disp('...done')

%% 5) construct viable maps
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
% combine fn keeps all 0's as 0 but retains all viable values within limit
combined_S15_L70 = combine(lightingMap1, slopeMap1);

disp('...done')
    
%% view viable slope & lighting maps
disp('viewing global viable slope maps...')
% SLOPES
disp('beginning slopes...')
% slope 15
    figure(14);
    imagesc(slopeMap1);
    axis equal;
    colorbar;
    colormap(color1);
    xlabel('X (px)');ylabel('Y (px)');
    title('Slopes <= 10 degrees');
    set(gca,'ydir','normal')
% LIGHTING
% lighting 70
    figure(15);
    imagesc(lightingMap1);
    axis equal;
    colorbar;
    colormap(color1);
    xlabel('X (km)');ylabel('Y (km)');
    title('Lighting >= 70%');
    set(gca,'ydir','normal')
    
disp('...done')

%% view combined maps
disp('viewing combined maps...')
% combined S15 L70
    figure(16);
    imagesc(combined_S15_L70);
    axis equal;
    colorbar;
    colormap(color1);
    xlabel('X (px)');ylabel('Y (px)');
    title('Overall Viable (S15, L70)');
    set(gca,'ydir','normal')
    
%% export to txt file
%dlmwrite('combined40mpp.txt', combined_S15_L70);

%% plot landing ellipse
% pixel coordinates in [x, y]
[hawPixelX, hawPixelY] = latlon2pixel_Haw(-86.7943, -21.1864);
hawC = [hawPixelX, hawPixelY];
% ellipse radius in pixels 
% rad is 50 m 
rad = 50;
hawR = rad/res;

    figure(11); viscircles(hawC, hawR);
    figure(12); viscircles(hawC, hawR);
    figure(13); viscircles(hawC, hawR);
    figure(14); viscircles(hawC, hawR);
    figure(15); viscircles(hawC, hawR);
    figure(16); viscircles(hawC, hawR);

%% plot rover traverse ellipse 
% rover traverse limit
travRadM = 500;
travRad = travRadM/res;

    figure(11); viscircles(hawC, travRad);
    figure(12); viscircles(hawC, travRad);
    figure(13); viscircles(hawC, travRad);
    figure(14); viscircles(hawC, travRad);
    figure(15); viscircles(hawC, travRad);
    figure(16); viscircles(hawC, travRad);

%% zoom to local
disp('zooming to local...')
    % first determine dimensions
    % 1000x1000m
    % get half --> 500 m
    zoomR = 500/res; % distance from center
    hawZoom1000 = [hawPixelX - zoomR, hawPixelX + zoomR, hawPixelY - zoomR, hawPixelY + zoomR];
    
    figure(11); axis(hawZoom1000);
    figure(12); axis(hawZoom1000);
    figure(13); axis(hawZoom1000);
    figure(14); axis(hawZoom1000);
    figure(15); axis(hawZoom1000);
    figure(16); axis(hawZoom1000);
disp('...done')

%% zoom back to global
disp('zooming out to global...')
    figure(11); axis(ax2);
    figure(12); axis(ax2);
    figure(13); axis(ax2);
    figure(14); axis(ax2);
    figure(16); axis(ax2);
disp('...done')

%% Creating Inflated Borders

viableMap = combine(slopeMap1,lightingMap1);
viableMapWithBorder = viableMap;
%viableMapWithBorder = combined_S15_L70;
for i = 2:1:length(viableMap(:,1))-2
    for j = 2:1:length(viableMap(1,:))-2
        if ((viableMap(i,j)==1) && (viableMap(i+1,j)==0||viableMap(i,j+1)==0||viableMap(i,j-1)==0||viableMap(i-1,j)==0||viableMap(i-1,j-1)==0||viableMap(i-1,j+1)==0||viableMap(i+1,j-1)==0||viableMap(i+1,j+1)==0))
            viableMapWithBorder(i,j) = 0;
        end
    end
end

figure(20)
imagesc(viableMap);
axis equal;
colorbar;
colormap(color4);
xlabel('X (px)');ylabel('Y (px)');
title('Viable Map');
set(gca,'ydir','normal')

figure(21)
%imagesc(viableMapWithBorder(floor(hawPixelX) - 15: floor(hawPixelX) + 15, ceil(hawPixelY) - 15: ceil(hawPixelY) + 15));
imagesc(viableMapWithBorder);
axis equal;
colorbar;
colormap(color4);
xlabel('X (px)');ylabel('Y (px)');
title('Viable Map With Borders');
set(gca,'ydir','normal')
%%
figure(23)
imagesc(viableMapWithBorder(floor(hawPixelY) - 15: floor(hawPixelY) + 15, floor(hawPixelX) - 15: floor(hawPixelX) + 15));
%imagesc(viableMapWithBorder);
axis equal;
%axis(hawZoom1000)
viscircles(hawC, hawR)
viscircles(hawC, travRad)
colorbar;
colormap(color4);
xlabel('X (px)');ylabel('Y (px)');
title('Viable Map With Borders');
set(gca,'ydir','normal')

%% 3.5) Saving SBPL Enfiornment Map

combined_S15_L70 = viableMapWithBorder;
combined_S15_L70(viableMapWithBorder == 0) = 1;
combined_S15_L70(viableMapWithBorder == 1) = 0;
%dlmwrite('envmap.txt', combined_S15_L70);

%%
imagesc(combined_S15_L70);
axis equal;
axis(hawZoom1000)
viscircles(hawC, hawR)
viscircles(hawC, travRad)
colorbar;
colormap(color4);
xlabel('X (px)');ylabel('Y (px)');
title('Viable Map With Borders');
set(gca,'ydir','normal')

%% 4) functions
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
        % filters out all values above upper limit
        bestParamMat(mat > limit) = 0; 
        % re-scale all mat values between 0 and 1
        matMax = max(bestParamMat, [], 'all');
        bestParamMat(mat <= limit) = 1;%(bestParamMat/-matMax) + 1;
    elseif limitType == 'lower'
        % filters out all values below lower limit
        bestParamMat(mat >= limit) = 1;
        % re-scale all mat values between 0 and 1
        matMax = max(bestParamMat, [], 'all');
        bestParamMat(mat < limit ) = 0;% bestParamMat/matMax;
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


