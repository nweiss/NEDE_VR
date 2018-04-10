EEG = pop_importdata('dataformat','matlab','nbchan',0,'data','C:\\Users\\Valued Customer\\NEDE_VR\\Data_Analysis\\Scripts\\subj18.mat','srate',256,'pnts',385,'xmin',-0.5,'chanlocs','C:\\Users\\Valued Customer\\NEDE_VR\\Data_Analysis\\Scripts\\biosemi64.sph');
EEG.setname='subj18';
figure; pop_spectopo(EEG, 1, [-300  800], 'EEG' , 'percent', 60, 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','off');
EEG = pop_interp(EEG, [20  33], 'spherical');
EEG = pop_eegthresh(EEG,1,[1:64] ,-150,150,-0.5,1,0,0);
EEG = pop_rejepoch( EEG, [39 208 220 256 263 267 270 284 286 302 308 315 357 360 369 374 379 444 467 469 480 556 572 595 596 599 612 614 619 620 645 663 676 677 707 728 729 757] ,0);
EEG = pop_runica(EEG, 'pca',32,'interupt','on');
EEG = eeg_checkset( EEG );
figure; pop_spectopo(EEG, 0, [-300  800], 'EEG' , 'freq', [10], 'plotchan', 0, 'percent', 20, 'icacomps', [1:32], 'nicamaps', 5, 'freqrange',[2 25],'electrodes','off');
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'pca',32,'interupt','on');
pop_prop( EEG, 0, 1, NaN, {'freqrange' [2 50] });
EEG = pop_subcomp( EEG, [2  3], 0);
EEG.setname='subj18';
EEG = eeg_checkset( EEG );


load('subj18_stim.mat','stimulus_type');
remove_ind = [39 208 220 256 263 267 270 284 286 302 308 315 357 360 369 374 379 444 467 469 480 556 572 595 596 599 612 614 619 620 645 663 676 677 707 728 729 757];
stimulus_type(remove_ind) = [];

EEG_temp = EEG.data;

EEG_target = EEG_temp(stimulus_type == 1);
EEG_distractor = EEG_temp(stimulus_type == 2);