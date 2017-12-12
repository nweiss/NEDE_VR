% Runs the Jangraw hybrid classifier on the VR NEDE data.
% Generates classifications from each modality seperately and then a
% combined classification as well. The four modalities are EEG, pupil
% dilation, head-rotation, and dwell time.

close all; clc; clear all;

%% Settings
DATA_VERSION_NO = '6'; % version of the stored data
nFolds = 10;
SAVE_ON = false;
SUBJECTS = [13];

%% Paths
function_path = fullfile('..','Functions');
addpath(genpath(function_path));

hdca_path = fullfile('..','HDCA');
addpath(genpath(hdca_path));

%% Load Data
LOAD_PATH = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data',['training_v',DATA_VERSION_NO],'training_data.mat');
load(LOAD_PATH);

%% Initialize Variables
nTrials = zeros(length(stimulus_type),1);

%% Misc
% For data version 4: Update the format of the data so each subject has its own cell array
if strcmp(DATA_VERSION_NO, '4')
    [billboard_cat,block,dwell_times,EEG,head_rotation,pupil,stimulus_type,subject,target_category] = array2cell(billboard_cat,block,dwell_times,EEG,head_rotation,pupil,stimulus_type,subject,target_category);
end
    
%% Main
nSubjects = length(SUBJECTS);
shuffleMap = cell(nSubjects,1);
for subject = SUBJECTS
    %Use the absolute value of head rotation
    head_rotation{subject} = abs(head_rotation{subject});

    % Update the stimulus type so that (0=distractor, 1=target)
    stimulus_type{subject} = convertLabels(stimulus_type{subject});

    %Shuffle the trials prior to partitioning them into training/testing sets
    nTrials(subject) = length(stimulus_type{subject});
    rng(subject);
    shuffleMap{subject} = randperm(nTrials(subject));
        
    billboard_cat{subject} = billboard_cat{subject}(shuffleMap{subject});
    block{subject} = block{subject}(shuffleMap{subject});
    dwell_times{subject} = dwell_times{subject}(shuffleMap{subject});
    EEG{subject} = EEG{subject}(:,:,shuffleMap{subject});
    head_rotation{subject} = head_rotation{subject}(shuffleMap{subject},:);
    pupil{subject} = pupil{subject}(shuffleMap{subject},:);
    stimulus_type{subject} = stimulus_type{subject}(shuffleMap{subject});
    target_category{subject} = target_category{subject}(shuffleMap{subject});
    
end

%% HDCA classifier
cvmode = [num2str(nFolds),'fold'];
level2data = [];
fwdModelData = [];

dwell_level1 = cell(nSubjects,1);
EEG_level1 = cell(nSubjects,1);
pupil_level1 = cell(nSubjects,1);
headrotation_level1 = cell(nSubjects,1);

v_dwell = cell(nSubjects,1);
v_EEG = cell(nSubjects,1);
v_pupil = cell(nSubjects,1);
v_headrotation = cell(nSubjects,1);
v_comb = cell(nSubjects,1);

Az.dwell = nan(nSubjects,1);
Az.dwell_v2 = nan(nSubjects,1);
Az.EEG = nan(nSubjects,1);
Az.pupil = nan(nSubjects,1);
Az.headrotation = nan(nSubjects,1);
Az.comb = nan(nSubjects,1);

ROC_x_dt1 = cell(nSubjects,1);
ROC_y_dt1 = cell(nSubjects,1);
ROC_x_pup = cell(nSubjects,1);
ROC_y_pup = cell(nSubjects,1);
ROC_x_hr = cell(nSubjects,1);
ROC_y_hr = cell(nSubjects,1);
ROC_x_eeg = cell(nSubjects,1);
ROC_y_eeg = cell(nSubjects,1);
ROC_x_comb = cell(nSubjects,1);
ROC_y_comb = cell(nSubjects,1);

level1_comb = cell(nSubjects,1);
y_comb = cell(nSubjects,1);

for subject = SUBJECTS
    nTrials = length(dwell_times{subject});
    cv = setCrossValidationStruct(cvmode,nTrials);
    
    % Dwell Time
    trainingwindowlength = 1;
    trainingwindowoffset = [1];
    dwell_times{subject} = permute(dwell_times{subject}, [3,1,2]);
    [y_dt,~,~,~,dwell_level1{subject},ROC_x_dt1{subject},ROC_y_dt1{subject},~,Az.dwell(subject)] = RunHybridHdcaClassifier2(dwell_times{subject},stimulus_type{subject},trainingwindowlength,trainingwindowoffset,cvmode);
    [X_dt2,Y_dt2,T_dt2,Az.dwell_v2(subject)] = perfcurve(squeeze(stimulus_type{subject}), squeeze(squeeze(dwell_times{subject})), 0);
    
    % Pupil
    trainingwindowlength = .5*60; % half a second at 60 herz
    trainingwindowoffset = (1*60:trainingwindowlength:4*60-trainingwindowlength);
    pupil{subject} = permute(pupil{subject}, [3,2,1]);
    [y_pup,w,v_pupil{subject},fwdModel,pupil_level1{subject},ROC_x_pup{subject},ROC_y_pup{subject},T_pup,Az.pupil(subject)] = RunHybridHdcaClassifier2(pupil{subject},stimulus_type{subject},trainingwindowlength,trainingwindowoffset,cvmode);
    
    % Head Rotation
    trainingwindowlength = floor(.25*75); % quarter second at 75 herz
    trainingwindowoffset = (floor(.5*75):trainingwindowlength:2*75-trainingwindowlength);
    head_rotation{subject} = permute(head_rotation{subject}, [3,2,1]);
    [y_hr,w,v_headrotation{subject},fwdModel,headrotation_level1{subject},ROC_x_hr{subject},ROC_y_hr{subject},T_hr,Az.headrotation(subject)] = RunHybridHdcaClassifier2(head_rotation{subject},stimulus_type{subject},trainingwindowlength,trainingwindowoffset,cvmode);
    
    % EEG
    trainingwindowlength = 25;
    trainingwindowoffset = (153:25:385-25);
    [y_eeg,w,v_EEG{subject},fwdModel,EEG_level1{subject},ROC_x_eeg{subject},ROC_y_eeg{subject},T_eeg,Az.EEG(subject)] = RunHybridHdcaClassifier2(EEG{subject},stimulus_type{subject},trainingwindowlength,trainingwindowoffset,cvmode);
    
    % Combined Model
    trainingwindowlength = 1;
    trainingwindowoffset = 1;
    level1_comb{subject} = cat(2, EEG_level1{subject}, pupil_level1{subject}, headrotation_level1{subject});
    [y_comb{subject},w,v_comb{subject},fwdModel,EEG_level1{subject},ROC_x_comb{subject},ROC_y_comb{subject},T_comb,Az.comb(subject)] = RunHybridHdcaClassifier2(dwell_times{subject},stimulus_type{subject},trainingwindowlength,trainingwindowoffset,cvmode, level1_comb{subject});

end

figure
plot((1:max(SUBJECTS)-1),Az.dwell,'-*')
hold on
plot((1:max(SUBJECTS)-1),Az.EEG,'-*')
hold on
plot((1:max(SUBJECTS)-1),Az.headrotation,'-*')
hold on
plot((1:max(SUBJECTS)-1),Az.pupil,'-*')
hold on
plot((1:max(SUBJECTS)-1),Az.comb,'-*')
legend('dwell','EEG','headrotation','pupil','combined')
xlabel('subject')
ylabel('AUC')
title('Various Models')
ylim([0,1])
grid on

figure
plot((1:max(SUBJECTS)-1),Az.dwell_v2,'-*')
hold on
plot(1:max(SUBJECTS)-1,Az.dwell,'-*')
xlabel('subject')
ylabel('AUC')
legend('dwell from HDCA', 'raw dwell')
title('dwell processing comparisons')
ylim([0,1])
grid on

% plot ROC curves
figure
subplot(2,3,1)
plot(ROC_x_dt1{DISPLAY_SUBJ},ROC_y_dt1{DISPLAY_SUBJ})
title('dwell time')
subplot(2,3,2)
plot(ROC_x_pup{DISPLAY_SUBJ},ROC_y_pup{DISPLAY_SUBJ})
title('pupil')
subplot(2,3,3)
plot(ROC_x_hr{DISPLAY_SUBJ},ROC_y_hr{DISPLAY_SUBJ})
title('head rotation')
subplot(2,3,4)
plot(ROC_x_eeg{DISPLAY_SUBJ},ROC_y_eeg{DISPLAY_SUBJ})
title('EEG')
subplot(2,3,5)
plot(ROC_x_comb{DISPLAY_SUBJ},ROC_y_comb{DISPLAY_SUBJ})
title('combined')

% calculate precision of predicted targets
precision = zeros(max(SUBJECTS),1);
for i = SUBJECTS
    nTrials = numel(y_comb{i});
    nPredTarg = floor(nTrials/4);
    [tmp,ind_pred_targ] = sort(y_comb{i}, 'descend');
    truth_of_pred_targ = stimulus_type{i}(ind_pred_targ(1:nPredTarg));
    precision(i) = sum(truth_of_pred_targ==1)/nPredTarg;
end
precision(3) = [];
figure
plot(precision)
hold on
plot([1,7],[.25,.25], '--k')
legend('precision','chance')
title('precision')
xlabel('subject')
ylabel('precision')
ylim([0,1])

disp('done')