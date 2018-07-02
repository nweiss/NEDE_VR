SUBJECTS = [15];
BLOCKS = [37];

for i = SUBJECTS
    for j = 1:BLOCKS
        LOAD_PATH = fullfile('..','..','..','Dropbox','NEDE_Dropbox',...
            'Data', ['raw_mat'], ['subject_', num2str(i)],...
            ['s', num2str(i), '_b', num2str(j), '_raw.mat']);
        
        load(LOAD_PATH);
        a = 18;
        
    end
end