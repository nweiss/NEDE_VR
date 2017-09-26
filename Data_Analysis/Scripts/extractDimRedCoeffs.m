% This script takes the raw data and creates continuous_v6
clear all; clc; close all;

%% Settings
SUBJECT = 11;
nBLOCKS = 40;
SAVE_ON = true;

%% Constants
freq_eeg = 2048;
EEG = struct;
EEG.compiled = [];

%% Initialize Variables

%% Set Paths
dependancy_path = fullfile('..','Dependancies');
addpath(dependancy_path);

%% Create Filters
% High Pass Filter for EEG
Fstop = .5;         % Stopband Frequency
Fpass = 3;           % Passband Frequency
Astop = 60;          % Stopband Attenuation (dB)
Apass = 1;           % Passband Ripple (dB)
match = 'passband';  % Band to match exactly
h_hp  = fdesign.highpass(Fstop, Fpass, Astop, Apass, 2048);
Hd_hp = design(h_hp, 'cheby2', 'MatchExactly', match);
%fvtool(Hd_hp)

% Low Pass Filter for EEG
Fpass = 50;          % Passband Frequency
Fstop = 55;          % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 60;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly
h_lp  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, freq_eeg);
Hd_lp = design(h_lp, 'cheby2', 'MatchExactly', match);
%fvtool(Hd_lp)

%% Run Processing Pipeline
for BLOCK = 1:nBLOCKS
    % Load Data
    load_path = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data',...
        'raw_mat',['subject_',num2str(SUBJECT)],...
        ['s',num2str(SUBJECT),'_b',num2str(BLOCK),'_raw.mat']);
    load(load_path);
    
    % Filter
    EEG.hp = filter(Hd_hp, eeg.time_series(2:65,:)')';
    EEG.filtered = filter(Hd_lp, EEG.hp')';
    
    % Downsample
    EEG.downsampled = downsample(EEG.filtered',8)';
    
    % Concatenate into a single continuous set of EEG
    EEG.compiled = [EEG.compiled, EEG.downsampled];
end
disp('Finished compiling EEG data')

% Find PCA_coeff and clean with PCA
[pca_coeff,pca_score,latent] = pca(EEG.compiled','NumComponents',20);
EEG.pcacleaned = pca_coeff * pca_score';

% Find ICAweights and ICAsphere
tmp1 = EEG.pcacleaned;
tmp2 = fullfile('..','Dependancies','biosemi_64.ced');
EEGlab = pop_importdata('data','tmp1','srate',256,'chanlocs',tmp2);
EEGlab = pop_runica(EEGlab,'icatype','runica');
% Find the component activations. Code borrowed from:
% https://sccn.ucsd.edu/pipermail/eeglablist/2013/006954.html
EEGlab.icaact = (EEGlab.icaweights*EEGlab.icasphere)*EEGlab.data(EEGlab.icachansind,:);

if SAVE_ON
    icaweights = EEGlab.icaweights;
    icasphere = EEGlab.icasphere;
    save_path = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data',...
        'dim_red_params','s11_dimredparams.mat');
    save(save_path,'pca_coeff','icaweights','icasphere');
    
end

disp('Done')