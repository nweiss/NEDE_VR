clear all; close all; clc;
load('tmp.mat');

headRotation = processHeadRotation(unity.time_series(9,:), unity.time_series(12,:));

% Find the velocity and acceleration of the head rotation
HR_vel = [0, diff(headRotation,1,2)];
HR_acc = [0, 0, diff(headRotation,2,2)];

% smooth the HR data
HR_vel = smooth(HR_vel(i,:)',10)';
HR_acc = smooth(HR_acc(i,:)',20)';

% Scale the Pos, Vel, and Acc
stdPos = std(reshape(HR_pos,1,[]),'omitnan');
stdVel = std(reshape(HR_vel,1,[]),'omitnan');
stdAcc = std(reshape(HR_acc,1,[]),'omitnan');    
HR_pos = HR_pos/stdPos;
HR_vel = HR_vel/stdVel;
HR_acc = HR_acc/stdAcc;

% Concatenate the headrotation epochs onto the EEG
tmp1 = shiftdim(HR_pos',-1);
tmp2 = shiftdim(HR_vel',-1);
tmp3 = shiftdim(HR_acc',-1);
EEGandHR = cat(1,EEG_ICs,tmp1,tmp2,tmp3);

covmat = abs(cov(EEGandHR_sq));
HR_pos_ICs = covmat(nComps+1,1:nComps) > thresh;
HR_vel_ICs = covmat(nComps+2,1:nComps) > thresh;
HR_acc_ICs = covmat(nComps+3,1:nComps) > thresh;
compsFromRotation = max([HR_pos_ICs;HR_vel_ICs;HR_acc_ICs],[],1);
compsFromRotation = find(compsFromRotation);

% Display the covarience of the various components with the different
% rotation measures
figure
plot(covmat(1:nComps,nComps+1:nComps+3),'*')
legend('position','velocity','acceleration')
title('Covariance of Independant Components with Rotation')
