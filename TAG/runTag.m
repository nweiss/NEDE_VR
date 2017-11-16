function runTag(classifier_outputs)
    
    nSensitivity = 0.9;
    graph_1 = load('graph_3_tiny.mat');
    result_eye = {};
    
%     while isempty(result_eye) 
%         result_classifier = lsl_resolve_byprop(lib,'name','Python'); 
%         disp('Waiting for: Classifier stream');
%     end
%     inlet_classifier = lsl_inlet(result_classifier{1});
%     disp('Opened inlet: Classifier -> Matlab');

    % need to time this properly
    result = dlmread('../NEDE_Game/objectLocs.txt',',');

    % we should change this order and probably read these in from a file
    image_types = {'car_side', 'grand_piano', 'laptop','schooner'};

    objectList = cell(1,length(result));
    billboardIdList = zeros(1,length(result));

    for i = 1:length(result)
        image_type = result(i,3) + 1;
        pict_num = result(i,4) + 1;
        billboardIdList(i) = result(i,5);
        full_string = strcat(image_types{image_type},'-',sprintf('%04d', pict_num)); %% get the number into the right string format
        objectList{i} = full_string;
    end
    target_indices = classifier_outputs(:,2) == 1;
    distractor_indices = classifier_outputs(:,2) == 0;
    confidence_scores = classifier_outputs(:,3);
    iTargets = classifier_outputs(target_indices,1);
    % get the order the billboards should be visited in
    [outputOrder,outputScore,isSelfTunedTarget] = RerankObjectsWithTag(objectList,iTargets,nSensitivity,graph_1.graph);

    % sort outputScore so it goes from billboard 0 - highest num
    orderedScores = zeros(1,length(outputOrder));

    for i = 1:length(outputOrder)
        orderedScores(i) = outputScore(outputOrder == i);
    end
    % get the order of the rest of the b

    highProbTargets = outputOrder(outputScore > 0.05);

    counter = 1;
    unseenOutputOrder = [];
    % make sure you don't go to the same billboard
    for i=1:length(highProbTargets)
       if ismember(highProbTargets(i),target_indices)
           orderedScores(i) = confidence_scores(highProbTargets(i)+1);
       elseif ismember(highProbTargets(i), distractor_indices)
           orderedScores(i) = confidence_scores(highProbTargets(i)+1);
       else 
           unseenOutputOrder(counter) = highProbTargets(i);
           counter = counter + 1;
       end
    end

    dlmwrite('../NEDE_Game/interestScores.txt',orderedScores')

    display = 0;
    usegridconstraints = true;
    billboardLocations = result(unseenOutputOrder,1:2);

    pathLocations = convertBillboardtoPathLocation(billboardLocations);
    tspOutput = solveTSP(pathLocations, display, usegridconstraints);
    fullPath = [];
    for i = 1:length(tspOutput)-1
        fullPath = [fullPath; tspOutput(i,:)];
        if tspOutput(i,1) ~= tspOutput(i+1,1)
            turningY = tspOutput(i,2) + (30 - mod(tspOutput(i,2),30));
            fullPath = [fullPath; [tspOutput(i,1) turningY]; [tspOutput(i+1,1) turningY]];
        end
    end
    fullPath = [fullPath; tspOutput(i+1,:)];
    dlmwrite('../NEDE_Game/NedeConfig/newCarPath.txt', horzcat(fullPath,zeros(length(fullPath),1)),'delimiter', ',','newline', 'pc');
end
