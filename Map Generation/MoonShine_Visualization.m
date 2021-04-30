% /*
%  * Copyright (c) 2008, Maxim Likhachev
%  * All rights reserved.
%  * 
%  * Redistribution and use in source and binary forms, with or without
%  * modification, are permitted provided that the following conditions are met:
%  * 
%  *     * Redistributions of source code must retain the above copyright
%  *       notice, this list of conditions and the following disclaimer.
%  *     * Redistributions in binary form must reproduce the above copyright
%  *       notice, this list of conditions and the following disclaimer in the
%  *       documentation and/or other materials provided with the distribution.
%  *     * Neither the name of the Carnegie Mellon University nor the names of its
%  *       contributors may be used to endorse or promote products derived from
%  *       this software without specific prior written permission.
%  * 
%  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%  * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%  * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%  * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%  * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%  * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%  * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%  * POSSIBILITY OF SUCH DAMAGE.
%  */
function[] = plot_3Dpath(solfilename, mapfilename, ~)
%
%Plots a 3D path overlaid on top of the map. 
%Resolution should be in meters 
%
%written by Maxim Likhachev
%---------------------------------------------------
%

%close all;

x = load(solfilename);

%now read in map
fmap = fopen(mapfilename, 'r');
xsize = -1;
ysize = -1;
while(feof(fmap) ~= 1)
    s = fscanf(fmap, '%s', 1);
    if (strcmp('environment:',s) == 1)
        break;
    elseif (strcmp('discretization(cells):', s) == 1)
        xsize = fscanf(fmap, '%d', 1);
        ysize = fscanf(fmap, '%d', 1);
    end;
end;
%read the environment itself
fprintf(1, 'reading in map of size %d by %d\n', xsize, ysize);

figure(3);

h = text(x(1,1), x(1,2), 'START');
set(h,'LineWidth',5);
h = text(x(size(x,1),1), x(size(x,1),2), 'GOAL');
set(h,'LineWidth',5);

map2 = load('map_MS.txt');
contourf(map2);

hold on;

h = text(x(1,1), x(1,2), 'START');
set(h,'LineWidth',5);
h = text(x(size(x,1),1), x(size(x,1),2), 'GOAL');
set(h,'LineWidth',5);

h = plot(x(:,1),x(:,2), 'r');
set(h,'LineWidth',3);

