function[] = MoonShine_Visualization(solfilename, mapfilename, ~)

%read in map and solution
x = load(solfilename);
map = load(mapfilename);

%Plot path on map

figure(1);

contourf(map);
hold on;

h = text(x(1,1), x(1,2), 'START');
set(h,'LineWidth',5);
h = text(x(size(x,1),1), x(size(x,1),2), 'GOAL');
set(h,'LineWidth',5);

h = plot(x(:,1),x(:,2), 'r');
set(h,'LineWidth',3);
