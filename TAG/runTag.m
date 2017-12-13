function [pathUpdated] = runTag(classifier_outputs,oldPath, numBillboardsSeen,initialPath)
    
    % Inputs:
    %   - initialPath: a flag indicating if the car is still following the
    %     initial (grid) path
    % 
    % Outputs:
    %   - pathUpdated is a boolean indicating whether or not there was
    %     confidence in enough billboards to update the car path

    %% Settings
    % nSensitivity is a scalar indicating how many times you want to perform
    % "self-tuning" (throwing out one predicted target that doesn't match and
    % adding another that does). [Default: 0].
    nSensitivity = 0.9;
    
    % Thresh is the threshold for the TAG output [0-1] that we use to
    % define a high probability target for the TSP
    thresh = 0.05;
    
    %% TAG
    objLocs = dlmread('../../NEDE_Game/objectLocs.txt',',');

    graph_1 = load('graph_3_tiny.mat');
    result_eye = {};
  
    image_types = {'car_side', 'grand_piano', 'laptop','schooner'};

    % Construct objectList which contains the name of each of the .jpg
    % files
    objectList = cell(1,length(objLocs));
    billboardIdList = zeros(1,length(objLocs));
    for i = 1:length(objLocs)
        image_type = objLocs(i,3) + 1;
        pict_num = objLocs(i,4) + 1;
        billboardIdList(i) = objLocs(i,5);
        full_string = strcat(image_types{image_type},'-',sprintf('%04d', pict_num)); % get the number into the right string format
        objectList{i} = full_string;
    end
    
    % Find which billboards are classified as targets
    target_indices = classifier_outputs(:,2) == 1;
    distractor_indices = classifier_outputs(:,2) == 0;
    iTargets = classifier_outputs(target_indices,1);
    iDistractors = classifier_outputs(distractor_indices,2) == 0;
    confidence_scores = classifier_outputs(:,3);

    % Find the billboards that have been seen already (plus the next two
    % that will be seen) so that the TSP doesn't circle back to them.
    seenBillboards = classifier_outputs(:,1);
    billboardPathLocs = convertBillboardtoPathLocation(objLocs(:,1:2));
    billboardPathLocs = [billboardPathLocs,objLocs(:,5)];
    lastTwoBillboardInd = seenBillboards(end-1:end);
    lastTwoBillboardLoc = billboardPathLocs(lastTwoBillboardInd+1,1:2);
    
    carGoingHor = false;
    if lastTwoBillboardLoc(2)-lastTwoBillboardLoc(1) > 0
        carGoingUp = true;
    elseif lastTwoBillboardLoc(2)-lastTwoBillboardLoc(1) < 0
        carGoingUp = false;
    elseif lastTwoBillboardLoc(2)-lastTwoBillboardLoc(1) == 0
        carGoingHor = true;
    end
    % If the car is going up and not near a turn
    if (carGoingUp && lastTwoBillboardLoc(2,2) < 120)
        nextTwoBillboardY = [lastTwoBillboardLoc(2,2)+20; lastTwoBillboardLoc(2,2)+40];
        nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1);]
    end
    % If the car is going down and not near a turn
    if (~carGoingUp && lastTwoBillboardLoc(2,2) > 40)
        nextTwoBillboardY = [lastTwoBillboardLoc(2,2)-20; lastTwoBillboardLoc(2,2)-40];
        nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1);]
    end
    % If the car is going up and just passed y=120
    
    % If the car is going up and just passed y=140
    
    % If the car is going down and just passed y=40
    
    % If the car is going down and just passed y=20
    nextTwoBillboardLoc = [nextTwoBillboardX, nextTwoBillboardY];
    oneAheadBillboardInd = billboardPathLocs(billboardPathLocs(:,1)==nextTwoBillboardLoc(1,1) && billboardPathLocs(:,2)==nextTwoBillboardLoc(1,2),3);
    twoAheadBillboardInd = billboardPathLocs(billboardPathLocs(:,1)==nextTwoBillboardLoc(2,1) && billboardPathLocs(:,2)==nextTwoBillboardLoc(2,2),3);
    nextTwoBillboardInd = [oneAheadBillboardInd; twoAheadBillboardInd];
    seenBillboards = [seenBillboards; nextTwoBillboardInd];
    
    % Run TAG to use CV to identify target billboards that haven't yet been
    % visited and to weed out false positives from the billboards that have
    % been visited
    [outputOrder,outputScore,isSelfTunedTarget] = RerankObjectsWithTag(objectList,iTargets,nSensitivity,graph_1.graph);

    % create ordered scores, the interest scores in order of billboardID
    orderedScores = zeros(1,length(outputOrder));
    for i = 1:length(outputOrder)
        orderedScores(i) = outputScore(outputOrder == i);
    end
    
    % Write the interest scores to the interest scores file
    dlmwrite('../../NEDE_Game/interestScores.txt',orderedScores','newline', 'pc', 'precision', '%1.5f');
    disp('Interest scores updated.')

    %% TSP
%     counter = 1;
%     unseenOutputOrder = [];
%     % make sure you don't go to the same billboard
%     for i=1:length(highProbTargets)
%        if ismember(highProbTargets(i),iTargets)
%            %orderedScores(highProbTargets(i)) = confidence_scores(highProbTargets(i)+1);
%        elseif ismember(highProbTargets(i), iDistractors)
%            %orderedScores(i) = confidence_scores(highProbTargets(i)+1);
%        else 
%            unseenOutputOrder(counter) = highProbTargets(i);
%            counter = counter + 1;
%        end
%     end

    pathUpdated = false; % Flag to indicate if a new path was written

    % Find the high probability targets
    highProbTargets = outputOrder(outputScore > thresh);
    unseenHighProbTargs = highProbTargets(~ismember(highProbTargets,seenBillboards));

    % Only run TSP once per block (ie if the car is still on the
    % initialPath). Only run it when there are at least 3 unseen high
    % probability targets. 
    if initialPath && length(unseenHighProbTargs) > 3  
        pathUpdated = true;
        display = 0;
        usegridconstraints = true;
        billboardLocations = objLocs(unseenHighProbTargs,1:2);
        [startingLocation, stitchPathsInd] = getStartingLocation(classifier_outputs(end,1),objLocs,oldPath,numBillboardsSeen); 
        pathLocations = [startingLocation; convertBillboardtoPathLocation(billboardLocations)];
        tspOutput = solveTSP(pathLocations, display, usegridconstraints);

        % If the startingLoc is a position of interest, it will appear
        % twice. If that is true, remove the repeat.
        if tspOutput(1,:) == tspOutput(2,:)
            tspOutput(2,:) = [];
        end

        disp('tspOutput: ')
        disp(tspOutput)

        % Insert waypoints at turn corners
        fullPath = [];
        for i = 1:length(tspOutput)-1
            fullPath = [fullPath; tspOutput(i,:)];
            if tspOutput(i,1) ~= tspOutput(i+1,1)
                if fullPath(end) - fullPath(end-1) > 0 %going up
                    turningY = tspOutput(i,2) + 10;
                elseif fullPath(end) - fullPath(end-1) < 0 %going down
                    turningY = tspOutput(i,2) - 10;
                else
                    error('car not going up or down');
                end
                fullPath = [fullPath; [tspOutput(i,1) turningY]; [tspOutput(i+1,1) turningY]];
            end
        end
        fullPath = [fullPath; tspOutput(i+1,:)];
        tmpFullPath1 = fullPath; % for debugging
        disp('Fullpath after turns inserted: ')
        disp(fullPath)

        % Stitch together the old path and the new path
        fullPath = vertcat(oldPath(1:stitchPathsInd-1,1:2), fullPath);
        stitchPathPoint = oldPath(stitchPathsInd,1:2);
        tmpFullPath2 = fullPath; % for debugging
        %disp(['stitchPathsInd: ' num2str(stitchPathsInd)])
        disp('Fullpath after stitched with old path: ')
        disp(fullPath)

        % Check for 180 degree turns, correct them
%         present180s = true;
%         while present180s
%             %[fullPath, present180s] = resolve180s(fullPath, tspOutput, stitchPathPoint, stitchPathsInd); 
%             [fullPath, present180s] = resolve180s_v2(fullPath, tspOutput);
%         end
        [fullPath, present180s] = resolve180s_v2(fullPath, tspOutput);
        tmpFullPath3 = fullPath; % for debugging
        disp('Fullpath after resolve180s: ')
        disp(fullPath)        
        
        % Interpolate waypoints in between the turns
        fullPath = interpWaypoints(fullPath);
        tmpFullPath4 = fullPath; % for debugging
        disp('Fullpath after interpolation: ')
        disp(fullPath)

        % Remove oldpath
        % fullPath = fullPath(stitchPathsInd:end,:);    

        dlmwrite('../../NEDE_Game/NedeConfig/newCarPath.txt', horzcat(fullPath,zeros(length(fullPath),1)),'delimiter', ',','newline','pc');
        disp('New carpath defined')
        %disp(['stitchPathsInd: ' num2str(stitchPathsInd)])
    end
    disp(' ')
end
