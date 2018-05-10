%   =======================================================================================
%   Copyright (C) 2013  Erlend Hodneland
%   Email: erlend.hodneland@biomed.uib.no 
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%   =======================================================================================

clear all
close all

% load the data
load ../data/surfstain_and_nucleus_3D.mat
plane = 5;
imsegm = imsegm(:,:,plane);imnucl = imnucl(:,:,plane);

% Smoothing
prm.smooothim.method = 'dirced';

% No ridge filtering
prm.filterridges = 0;

% threshold for nucleus markers
prm.getminima.nucleus.segmct.thrs.th = 0.70;

% edge enhancing diffusion with a suitable threshold
prm.getminima.nucleus.segmct.smoothim.method = 'eed';
prm.getminima.nucleus.segmct.smoothim.eed.kappa = 0.05;

% method for markers
prm.getminima.method = 'nucleus';

% Subtract the nucleus channel from the surface staining to reduce the
% cross talk effect. 
imsegm1 = imsegm;
filt = fspecial('gaussian',3,2);
imsegm = imfilter(imsegm1,filt) - imfilter(imnucl,filt);

[cellbw,wat,imsegmout,minima,minimacell,info] = ...
    cellsegm.segmsurf(imsegm,10,100,'imnucleus',imnucl,'prm',prm);

cellsegm.show(imsegm,1);title('Surface stain');axis off;
cellsegm.show(imnucl,2);title('Nucleus stain');axis off;
cellsegm.show(minima,3);title('Markers');axis off;
cellsegm.show(wat,4);title('Watershed image');axis off;
cellsegm.show(cellbw,5);title('Cell segmentation');axis off;
