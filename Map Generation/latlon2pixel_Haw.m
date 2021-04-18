function [i,j] = latlon2pixel_Haw(lat,lon)
  % south polar stereographic projection
  
  N=15200; % side length of matrix
  k0=1./0.040; % for 240 mpp use 1./0.240
  R=1737.4;

  phi = abs(lat*pi/180);
  lambda = lon*pi/180; 

  if mod(N,2)==1
    i0 = (N+1)/2;
    j0 = (N+1)/2;
  else
    i0 = N/2;
    j0 = N/2;
  end
  
  rho = 2*R*k0*(1-tan(phi/2)) / (1+tan(phi/2));
  
  i = rho*sin(lambda) + i0;
  j1 = j0 - rho*cos(lambda);
  j = N - j1;

  return

  %% landing site coordinates
  % Haworth lat long: -86.7943, -21.1864 (or 338.8136)
  % Haworth pixels for 40 mpp i, j: 6.7215e+03, 5.3335e+03
  
  %% resulting pixels