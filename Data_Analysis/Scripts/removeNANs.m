clear all; close all; clc;

loadpath = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data','training_v3','training_data.mat');
load(loadpath)
for i = 1:length(subject)
    head_rotation{i}(isnan(head_rotation{i})) = 0;
end

save(loadpath,'billboard_cat','block','dwell_times','EEG','head_rotation','pupil','stimulus_type','subject','target_category')
disp('Saved')