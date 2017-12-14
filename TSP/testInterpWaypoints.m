clear; clc;

%load('oldCarPath.mat')
oldCarPath = [0,0; 0,110; 30,110; 30,80; 30,30; 45,30; 45,50; 30,50; 30,80; 30,110; 90,110];

newCarPath = interpWaypoints(oldCarPath);
disp('done')