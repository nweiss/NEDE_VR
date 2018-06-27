files = dir('../../../Dropbox/NEDE_Dropbox/Data/raw_mat/subject_20/*.mat');
filepath = '../../../Dropbox/NEDE_Dropbox/Data/raw_data_with_head_rotation/subj20.mat';
full_eeg = [];
event_counter = 0;
for file = files'
    load(strcat(file.folder,'/',file.name));
    size(eeg.time_series)

    trials_per_block = 20;
    start_times_eye = [];
    start_times_unity = [];

    oculus_fov = 106.188; % Field of view of oculus in degrees (Unity lists it)
    oculus_pixels_x = 1915; % Pixels in oculus in the horizontal direction, found empirically
    allowedDiscrepency = 6*oculus_pixels_x/oculus_fov; % Number of degrees to expand the bounding box of billboards for fixation


        Billboard.isOnscreen = zeros(size(unity.time_stamps));
    %     Billboard.id_eye_frames = zeros(1, floor(block_duration * freq_eye));
        Billboard.id_unity_frames = -1*ones(size(unity.time_stamps)); % -1 marks the absence of a billboard since 0 is a valid id
        Billboard.id = []; % Records the ids as they are fixated upon
        Billboard.stimulus_type = [];
        Billboard.imageNo = zeros(1, trials_per_block);
        Billboard.category = zeros(1, trials_per_block);

        counter_unity = 1;

        unity_data = unity.time_series;

    while counter_unity < size(unity.time_stamps,2)
        Billboard.id_unity_frames(counter_unity) = unity_data(7, counter_unity);
        if unity_data(3, counter_unity) ~= 0
            left_border = unity_data(1, counter_unity) - allowedDiscrepency;
            right_border = unity_data(1, counter_unity) + unity_data(3, counter_unity) + allowedDiscrepency;

            [~,eye_ind] = min(abs(eye.time_stamps -unity.time_stamps(counter_unity)));

            if eye.time_series(2, eye_ind) > left_border && eye.time_series(2, eye_ind) < right_border
                isFixated = 1;
                if ~any(Billboard.id == unity_data(7, counter_unity))
                    Billboard.id = [Billboard.id unity_data(7, counter_unity)];
                    Billboard.stimulus_type = [Billboard.stimulus_type unity_data(5, counter_unity)];
                    start_times_eye = [start_times_eye eye.time_stamps(eye_ind)];
                    start_times_unity = [start_times_unity unity.time_stamps(counter_unity)];
                end
            end
        end
        counter_unity = counter_unity + 1;
    end
    
    for i=1:length(Billboard.stimulus_type)

       [~,eeg_ind] = min(abs(eeg.time_stamps - start_times_unity(i)));
       eeg.time_series(1,eeg_ind) = Billboard.stimulus_type(i);
       event_counter = event_counter + 1;
    end
    
    % head_rotation
    
    % Calculate head rotation
    for i=1:length(unity.time_stamps)
        oculus_rotation = unity.time_series(9,i);
        car_rotation = unity.time_series(12,i);
        head_rotation(i) = processHeadRotation(oculus_rotation,car_rotation);
        
    end
    
    
    
    for i=1:length(unity.time_stamps)-2
       
        [~,eeg_ind_start] = min(abs(eeg.time_stamps - unity.time_stamps(i)));
        [~,eeg_ind_end] = min(abs(eeg.time_stamps - unity.time_stamps(i+1)));
        eeg.time_series(66,eeg_ind_start:eeg_ind_end-1) = head_rotation(i);
        
    end
    
    
    full_eeg = [full_eeg eeg.time_series];
    
end

% % full_eeg = downsample(full_eeg',8)';
% if 'ABM' == EEG_type
%     full_eeg = full_eeg(1:21,:);
% end
save(filepath,'full_eeg')
