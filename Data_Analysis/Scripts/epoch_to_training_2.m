

% nBLOCKS = [42,39,40,37,40,40,40,40,26,30];
% SUBJECT = [8,10,11,15,16,17,18,19,99,100];
% 
nBLOCKS = [42];
SUBJECT = [15];


data = cell(1,max(SUBJECT));
for i = 1:length(SUBJECT)
    data{SUBJECT(i)} = struct();
    data{SUBJECT(i)}.EEG = [];
    data{SUBJECT(i)}.head_rotation = [];
    data{SUBJECT(i)}.pupil = [];
    data{SUBJECT(i)}.dwell_times = [];
    data{SUBJECT(i)}.stimulus_type = [];
    
    
    for BLOCK = 1:nBLOCKS(i)
        % Load Data
        load_path = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data','epoched_v8',['subject_',num2str(SUBJECT(i))],...
            ['s',num2str(SUBJECT(i)),'_b',num2str(BLOCK),'_epoched.mat']);
        load(load_path);
        
        data{SUBJECT(i)}.EEG = cat(3,data{SUBJECT(i)}.EEG,EEG);
        data{SUBJECT(i)}.head_rotation = cat(1,data{SUBJECT(i)}.head_rotation,head_rotation);
        data{SUBJECT(i)}.pupil = cat(1,data{SUBJECT(i)}.pupil,pupil);
        dwell = cat(2,data{SUBJECT(i)}.dwell_times,dwell_times);
        dwell(isnan(dwell))= 0;
        data{SUBJECT(i)}.dwell_times = dwell;
        data{SUBJECT(i)}.stimulus_type = cat(2,data{SUBJECT(i)}.stimulus_type,stimulus_type);
        
    end
end

save_path = fullfile('..','..','..','Dropbox','NEDE_Dropbox','Data','training_v8','training_data_15closed.mat')
