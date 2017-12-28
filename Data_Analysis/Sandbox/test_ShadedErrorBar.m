clear all; clc; close all;

function_path = fullfile('..','Functions');
addpath(function_path);

x = (1:100);
y = sin(x);
z = cos(x);

figure
shadedErrorBar(x,y,z,'-b')