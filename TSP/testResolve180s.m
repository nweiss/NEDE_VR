clear all; clc; close all;

load('fullPath.mat');
load('tspOutput.mat');

present180s = true;
oldPath = fullPath;
while present180s
    [fullPath, present180s] = resolve180s(fullPath, tspOutput); 
end
newPath = fullPath;