function [billboard_cat, block, dwell_times, EEG, head_rotation, pupil, stimulus_type, subject, target_category] = array2cell(billboard_cat, block, dwell_times, EEG, head_rotation, pupil, stimulus_type, subject, target_category)

% This function takes data from NEDE VR Experiment and converts it so that
% there is a cell array for each subject.

billboard_cat_tmp = billboard_cat;
block_tmp = block;
dwell_times_tmp = dwell_times;
EEG_tmp = EEG;
head_rotation_tmp = head_rotation;
pupil_tmp = pupil;
stimulus_type_tmp = stimulus_type;
subject_tmp = subject;
target_category_tmp = target_category;
clear 'billboard_cat' 'block' 'dwell_times' 'EEG' 'head_rotation' 'pupil' 'stimulus_type' 'subject' 'target_category'

billboard_cat = cell(8,1);
block = cell(8,1);
dwell_times = cell(8,1);
EEG = cell(8,1);
head_rotation = cell(8,1);
pupil = cell(8,1);
stimulus_type = cell(8,1);
subject = cell(8,1);
target_category = cell(8,1);

for i = 1:8
    billboard_cat{i} = billboard_cat_tmp(subject_tmp == i);
    block{i} = block_tmp(subject_tmp == i);
    dwell_times{i} = dwell_times_tmp(subject_tmp == i);
    EEG{i} = EEG_tmp(:,:,subject_tmp == i);
    head_rotation{i} = head_rotation_tmp(subject_tmp == i,:);
    pupil{i} = pupil_tmp(subject_tmp == i,:);
    stimulus_type{i} = stimulus_type_tmp(subject_tmp == i);
    subject{i} = subject_tmp(subject_tmp == i);
    target_category{i} = target_category_tmp(subject_tmp == i);
end