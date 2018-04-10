

event = cell(1,length(stimulus_type));

for i= 1:length(stimulus_type)
    
    if stimulus_type(i) == 1
        event{i} = 'target';
    else
        event{i} = 'distractor';
    end
end
