% This script takes epoched training data, selects an individual subject, 
% and creates a number of visualizations.
%
% NW - 12/19/2017

clear all; clc; close all;

%% SETTINGS
DATA_VERSION_NO = '6';
SUBJECT = 13;
scalpmap_ylims = [-15,15]; % ylimits for the plotting of the eeg data
scalpmap_times = [-400,0,200,300,350,400,500,600,700]; % timepoints at which the eeg data is plotted

%% PATHS
error_bar_path = fullfile('..', 'Dependancies', 'shadedErrorBar');
addpath(error_bar_path);
function_path = fullfile('..','Functions');
addpath(function_path);
dependancies_path = fullfile('..','Dependancies');
addpath(dependancies_path);

%% LOAD DATA
data_path = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data','training_v6','training_data.mat');
load(data_path);

%% Initialize Variables
% Set the indices of the relevant channels
FzInd = 38;
CzInd = 48;
PzInd = 31;

%% Select data from subject defined in settings
billboard_cat = billboard_cat{SUBJECT};
block = block{SUBJECT};
dwell_times = dwell_times{SUBJECT};
eeg = EEG{SUBJECT};
head_rotation = head_rotation{SUBJECT};
pupil = pupil{SUBJECT};
stimulus_type = convertLabels(stimulus_type{SUBJECT});

%% EEG plot
FzTargMean = mean(eeg(FzInd,:,stimulus_type == 1),3);
FzTargStd = std(eeg(FzInd,:,stimulus_type == 1),[],3);
FzTargStdError = FzTargStd ./ sqrt(sum(stimulus_type == 1));
FzDistMean = mean(eeg(FzInd,:,stimulus_type == 0),3);
FzDistStd = std(eeg(FzInd,:,stimulus_type == 0),[],3);
FzDistStdError = FzDistStd ./ sqrt(sum(stimulus_type == 0));

CzTargMean = mean(eeg(CzInd,:,stimulus_type == 1),3);
CzTargStd = std(eeg(CzInd,:,stimulus_type == 1),[],3);
CzTargStdError = CzTargStd ./ sqrt(sum(stimulus_type == 1));
CzDistMean = mean(eeg(CzInd,:,stimulus_type == 0),3);
CzDistStd = std(eeg(CzInd,:,stimulus_type == 0),[],3);
CzDistStdError = CzDistStd ./ sqrt(sum(stimulus_type == 0));

PzTargMean = mean(eeg(PzInd,:,stimulus_type == 1),3);
PzTargStd = std(eeg(PzInd,:,stimulus_type == 1),[],3);
PzTargStdError = PzTargStd ./ sqrt(sum(stimulus_type == 1));
PzDistMean = mean(eeg(PzInd,:,stimulus_type == 0),3);
PzDistStd = std(eeg(PzInd,:,stimulus_type == 0),[],3);
PzDistStdError = PzDistStd ./ sqrt(sum(stimulus_type == 0));

x_axis = linspace(-500, 1000, length(FzTargMean));
figure
subplot(3,2,1)
H1 = shadedErrorBar(x_axis,FzDistMean,FzDistStd,'-b',1);
hold on
H2 = shadedErrorBar(x_axis,FzTargMean,FzTargStd,'-r',1);
legend([H1.mainLine, H2.mainLine], 'distractors', 'targets', 'Location', 'SouthWest')
title('Electrode Fz')
xlabel('Time (ms)')
ylabel('Microvolts')

subplot(3,2,3)
H3 = shadedErrorBar(x_axis,CzDistMean,CzDistStd,'-b',1);
hold on
H4 = shadedErrorBar(x_axis,CzTargMean,CzTargStd,'-r',1);
title('Electrode Cz')
xlabel('Time (ms)')
ylabel('Microvolts')
legend([H3.mainLine, H4.mainLine], 'distractors','targets','Location', 'SouthWest')

subplot(3,2,5)
H5 = shadedErrorBar(x_axis,PzDistMean,PzDistStd,'-b',1);
hold on
H6 = shadedErrorBar(x_axis,PzTargMean,PzTargStd,'-r',1);
title('Electrode Pz')
xlabel('Time (ms)')
ylabel('Microvolts')
legend([H5.mainLine, H6.mainLine], 'distractors','targets', 'Location', 'SouthWest')

%% Pupil plot

pupilTargMean = mean(pupil(stimulus_type == 1,:),1);
pupilTargStd = std(pupil(stimulus_type == 1,:),1);
pupilTargStdError = pupilTargStd ./ sqrt(sum(stimulus_type == 1));
pupilDistMean = mean(pupil(stimulus_type == 0,:),1);
pupilDistStd = std(pupil(stimulus_type == 0,:),1);
pupilDistStdError = pupilDistStd ./ sqrt(sum(stimulus_type == 1));

x_axis = linspace(-1000,3000,length(pupilTargMean));
subplot(3,2,2)
H7 = shadedErrorBar(x_axis,pupilDistMean,pupilDistStd,'b',1);
hold on
H8 = shadedErrorBar(x_axis,pupilTargMean,pupilTargStd,'-r',1);
legend([H7.mainLine, H8.mainLine], 'distractors', 'targets', 'Location', 'SouthWest')
title('Pupil Dilation')
xlabel('Time (ms)')
ylabel('Deviation of radius from baseline (mm)')

%% dwell time plot

nTargets = sum(stimulus_type == 1);
nDistractors = sum(stimulus_type == 0);
dtTargCumhist = zeros(1,1500);
dtDistCumhist = zeros(1,1500);
for i = 1:1500 % cycle through 1500 ms
    for j = 1:length(stimulus_type)
       if stimulus_type(j) == 1
           if dwell_times(j) >= i/1000
                dtTargCumhist(i) = dtTargCumhist(i)+1;
           end
       end
       if stimulus_type(j) == 0
           if dwell_times(j) >= i/1000
                dtDistCumhist(i) = dtDistCumhist(i)+1;
           end
       end
   end
end

dtTargCumhist = dtTargCumhist./nTargets;
dtDistCumhist = dtDistCumhist./nDistractors;

x_axis = 1:1500;
subplot(3,2,6)
plot(x_axis, dtDistCumhist, 'b', x_axis, dtTargCumhist, 'r')
title('Dwell Times')
xlabel('Time (ms)')
ylabel('Fraction of Trials with Dwell Time > t')
legend('Distractors','Targets', 'Location', 'SouthWest')

%% Head Rotation

HRTargMean = mean(abs(head_rotation(stimulus_type == 1,:)),1);
HRTargStd = std(abs(head_rotation(stimulus_type == 1,:)),1);
HRTargStdError = HRTargStd ./ sqrt(sum(stimulus_type == 1));
HRDistMean = mean(abs(head_rotation(stimulus_type == 0,:)),1);
HRDistStd = std(abs(head_rotation(stimulus_type == 0,:)),1);
HRDistStdError = HRDistStd ./ sqrt(sum(stimulus_type == 0));

x_axis = linspace(-500,1500,length(HRTargMean));
subplot(3,2,4)
H9 = shadedErrorBar(x_axis,HRDistMean, HRDistStd, 'b',1);
hold on
H10 = shadedErrorBar(x_axis,HRTargMean, HRTargStd, 'r',1);
legend([H9.mainLine, H10.mainLine],'distractors','targets', 'Location', 'NorthWest')
title('Head Rotation')
ylabel('|degrees|')
xlabel('Time (ms)')

set(gcf,'Color','w');

%% Scalp Maps
% Take only the real part of the EEG
eeg = real(eeg);

EEGTarg = pop_importdata('setname','targets','data',eeg(:,:,stimulus_type==1), 'chanlocs','biosemi_64.ced','xmin',-.5,'srate',256);
EEGDist = pop_importdata('setname','distractors','data',eeg(:,:,stimulus_type==0), 'chanlocs','biosemi_64.ced','xmin',-.5,'srate',256);
ALLEEG = [EEGTarg, EEGDist];

pop_comperp(ALLEEG,1,1,2,'ylim',ylim,'title','Targets-Distractors','addavg','on','subavg','on');
pop_topoplot(EEGTarg,1,scalpmap_times,'Targets',0,0,'maplimits',scalpmap_ylims);
pop_topoplot(EEGDist,1,scalpmap_times,'Distractors',0,0,'maplimits',scalpmap_ylims);
