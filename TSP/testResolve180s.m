clear all; clc; close all;

% load('fullPath.mat');
% oldPath = fullPath;
% load('tspOutput.mat');

% present180s = true;
% oldPath = fullPath;
% while present180s
%     [fullPath, present180s] = resolve180s(fullPath, tspOutput); 
% end
% newPath = fullPath;

% Test case 1 - tspOutput in two different columns
if false
    oldPath = [0, 30; 15, 30; 15, 20; 15, 30; 45,30; 45, 20];
    tspOutput = [15, 20; 45, 20];
    [newPath, present180s] = resolve180s_v2(oldPath, tspOutput);
end

% Test case 2 - tspOutput in two different columns
if false
    oldPath = [0, 30; 15, 30; 15, 40; 15, 30; 45,30; 45, 20];
    tspOutput = [15, 40; 45, 20];
    [newPath, present180s] = resolve180s_v2(oldPath, tspOutput);
end
    
% Test case 3 - tspOutput in one column
if false
    oldPath = [0, 30; 30, 30; 30, 20; 30, 60; 30,70; 45, 70];
    tspOutput = [30, 20; 30, 60];
    [newPath, present180s] = resolve180s_v2(oldPath, tspOutput);
end

% Test case 4 - combo
if true
    oldPath = [0, 80;
    0, 100;
    30, 100;
    30,120
    30,80;
    30,100;
    60,100;
    60,80;
    60,140];
    tspOutput = [0,100;30,120;30,80;60,80;60,140];
    [newPath, present180s] = resolve180s_v2(oldPath, tspOutput);
end