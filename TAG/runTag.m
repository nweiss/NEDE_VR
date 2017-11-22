function [pathUpdated] = runTag(classifier_outputs,oldPath)
    
    % pathUpdated is a boolean indicating whether or not there was
    % confidence in enough billboards to update the car path
    
    disp('Old path shape:')
    disp(size(oldPath))

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
    objLocs = dlmread('../../NEDE_Game/objectLocs.txt',',');

    % we should change this order and probably read these in from a file
    image_types = {'car_side', 'grand_piano', 'laptop','schooner'};

    objectList = cell(1,length(objLocs));
    billboardIdList = zeros(1,length(objLocs));

    for i = 1:length(objLocs)
        image_type = objLocs(i,3) + 1;
        pict_num = objLocs(i,4) + 1;
        billboardIdList(i) = objLocs(i,5);
        full_string = strcat(image_types{image_type},'-',sprintf('%04d', pict_num)); % get the number into the right string format
        objectList{i} = full_string;
    end
    target_indices = classifier_outputs(:,2) == 1;
    distractor_indices = classifier_outputs(:,2) == 0;
    confidence_scores = classifier_outputs(:,3);
    iTargets = classifier_outputs(target_indices,1);
    % get the order the billboards should be visited i
    [outputOrder,outputScore,isSelfTunedTarget] = RerankObjectsWithTag(objectList,iTargets,nSensitivity,graph_1.graph);

    % sort outputScore so it goes from billboard 0 - highest num
    orderedScores = zeros(1,length(outputOrder));

    for i = 1:length(outputOrder)
        orderedScores(i) = outputScore(outputOrder == i);
    end
    % get the order of the rest of the b

    highProbTargets = outputOrder(outputScore > 0.1);

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
    
    % eliminate any scientific notation (ie 3.41e-5)
    dlmwrite('../../NEDE_Game/interestScores.txt',orderedScores','newline', 'pc', 'precision', '%1.5f');
    disp('Interest scores updated')

    pathUpdated = false;
    % Only run the TSP when there are several interesting objects in the
    % environment and were not almost done with our path
    if length(highProbTargets) > 1 && size(oldPath,1) > 2
        pathUpdated = true;
        display = 0;
        usegridconstraints = true;
        billboardLocations = objLocs(unseenOutputOrder,1:2);
        
        startingLocation = getStartingLocation(classifier_outputs(end,1),objLocs,oldPath); 
    
        pathLocations = [startingLocation; convertBillboardtoPathLocation(billboardLocations)];
   
    
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
        
        % Interpolate waypoints in between the turns
        fullPath = interpWaypoints(fullPath);
        dlmwrite('../../NEDE_Game/NedeConfig/newCarPath.txt', horzcat(fullPath,zeros(length(fullPath),1)),'delimiter', ',','newline','pc');
        disp('NEW CARPATH DEFINED')
    end
end


