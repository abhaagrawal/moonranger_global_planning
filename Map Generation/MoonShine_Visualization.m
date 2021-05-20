% Ron Baheti
% 04.29.2021

function[] = MoonShine_Visualization(solfilename, mapfilename, ~)

% Read in map and solution
x = load(solfilename); %solfilename is a solution file created in the build folder once MS is run
map = load(mapfilename); %mapfilename is the map text file created using the map generator code

% Plot map
figure(1);

contourf(map);
hold on;

% Plot path on map

h = text(x(1,1), x(1,2), 'START');
set(h,'LineWidth',5);
h = text(x(size(x,1),1), x(size(x,1),2), 'GOAL');
set(h,'LineWidth',5);

h = plot(x(:,1),x(:,2), 'r');
set(h,'LineWidth',3);
