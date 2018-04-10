EEG = pop_importdata('dataformat','matlab','nbchan',0,'data','C:\\Users\\Valued Customer\\NEDE_VR\\Data_Analysis\\Scripts\\subj15.mat','srate',256,'pnts',385,'xmin',-0.5,'chanlocs','C:\\Users\\Valued Customer\\NEDE_VR\\Data_Analysis\\Scripts\\biosemi64.sph');
EEG.setname='subj15';
EEG = eeg_checkset( EEG );