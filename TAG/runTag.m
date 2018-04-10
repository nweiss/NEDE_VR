function [pathUpdated] = runTag(classifier_outputs,oldPath, numBillboardsSeen,initialPath,trueLabels,thresh)
    
    % Inputs:
    %   - initialPath: a flag indicating if the car is still following the
    %     initial (grid) path
    %   - trueLabels: the true labels of the billboards in order of
    %   presentation (1=targ,2=dist).
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
    
    %% DEBUG RUNTAG
    file1 = fullfile('..','..','TAG','classifier_outputs.mat');
    save(file1,'classifier_outputs');
    file2 = fullfile('..','..','TAG','oldPath.mat');
    save(file2,'oldPath');
    file3 = fullfile('..','..','TAG','numBillboardsSeen.mat');
    save(file3,'numBillboardsSeen');
    file4 = fullfile('..','..','TAG','initialPath.mat');
    save(file4,'initialPath');
    file5 = fullfile('..','..','TAG','trueLabels.mat');
    save(file5,'trueLabels');
    
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
    iDistractors = classifier_outputs(distractor_indices,1);
    confidence_scores = classifier_outputs(:,3);
    
    % Run TAG to use CV to identify target billboards that haven't yet been
    % visited and to weed out false positives from the billboards that have
    % been visited
    [outputOrder,outputScore,isSelfTunedTarget] = RerankObjectsWithTag(objectList,iTargets,nSensitivity,graph_1.graph);

    % create ordered scores, the interest scores in order of billboardID
    orderedTagScores = zeros(1,length(outputOrder));
    for i = 1:length(outputOrder)
        orderedTagScores(i) = outputScore(outputOrder == i);
    end
    
    % Create an ordered vector of classifier outputs for billboards that have already been passed.
    orderedClassifierOutputs = zeros(length(orderedTagScores),1);
    trueLabels = convertLabels(trueLabels(1:length(orderedClassifierOutputs)));
    orderedTrueLabels = -1*ones(length(orderedClassifierOutputs),1);
    for i = 1:size(classifier_outputs,1)
        orderedClassifierOutputs(classifier_outputs(i,1)+1) = classifier_outputs(i,3);
        orderedTrueLabels(classifier_outputs(i,1)+1) = trueLabels(i);
    end
    
    % Write the interest scores to the interest scores file
    interestScoreTable = [orderedTagScores',orderedClassifierOutputs,orderedTrueLabels];
    dlmwrite('../../NEDE_Game/interestScores.txt',interestScoreTable,'newline', 'pc', 'precision', '%1.5f');
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

    % Figure out which billboards have already been seen and the next two
    % billboards that will be seen before the TSP path takes over.
    if size(classifier_outputs,1) > 5
        % Find the next the next two billboards that will be seen before the
        % new car path takes over and add them to seenBillboards so that TSP
        % doesn't circle back to them.
        seenBillboards = classifier_outputs(:,1);
        billboardPathLocs = convertBillboardtoPathLocation(objLocs(:,1:2));
        billboardPathLocs = [billboardPathLocs,objLocs(:,5)];
        lastTwoBillboardInd = seenBillboards(end-1:end);
        lastTwoBillboardLoc = billboardPathLocs(lastTwoBillboardInd+1,1:2);

        carGoingHor = false;
        carGoingUp = false;
        if lastTwoBillboardLoc(2,2)-lastTwoBillboardLoc(1,2) > 0
            carGoingUp = true;
        elseif lastTwoBillboardLoc(2,2)-lastTwoBillboardLoc(1,2) < 0
            carGoingUp = false;
        elseif lastTwoBillboardLoc(2,2)-lastTwoBillboardLoc(1,2) == 0
            carGoingHor = true;
        end
        % If the car is going up and not near a turn
        if (carGoingUp && lastTwoBillboardLoc(2,2) < 120)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1)];
            nextTwoBillboardY = [lastTwoBillboardLoc(2,2)+20; lastTwoBillboardLoc(2,2)+40];
        end
        % If the car is going down and not near a turn
        if (~carGoingUp && lastTwoBillboardLoc(2,2) > 40)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1);];
            nextTwoBillboardY = [lastTwoBillboardLoc(2,2)-20; lastTwoBillboardLoc(2,2)-40];
        end
        % If the car is going up and just passed y=120
        if (carGoingUp && lastTwoBillboardLoc(2,2) == 120)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1)+15];
            nextTwoBillboardY = [140; 140];
        end
        % If the car is going up and just passed y=140
        if (carGoingUp && lastTwoBillboardLoc(2,2) == 140)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1)+15; lastTwoBillboardLoc(2,1)+15];
            nextTwoBillboardY = [140; 120];
        end
        % If the car is going down and just passed y=40
        if (~carGoingUp && lastTwoBillboardLoc(2,2) == 40)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1); lastTwoBillboardLoc(2,1)+15];
            nextTwoBillboardY = [20; 20];
        end    
        % If the car is going down and just passed y=20
        if (~carGoingUp && lastTwoBillboardLoc(2,2) == 20)
            nextTwoBillboardX = [lastTwoBillboardLoc(2,1)+15; lastTwoBillboardLoc(2,1)+15];
            nextTwoBillboardY = [20; 40];
        end 

        nextTwoBillboardLoc = [nextTwoBillboardX, nextTwoBillboardY];
        oneAheadBillboardInd = billboardPathLocs(billboardPathLocs(:,1)==nextTwoBillboardLoc(1,1) & billboardPathLocs(:,2)==nextTwoBillboardLoc(1,2),3);
        twoAheadBillboardInd = billboardPathLocs(billboardPathLocs(:,1)==nextTwoBillboardLoc(2,1) & billboardPathLocs(:,2)==nextTwoBillboardLoc(2,2),3);
        nextTwoBillboardInd = [oneAheadBillboardInd; twoAheadBillboardInd];
        %disp('seenBillboards:')
        %disp(seenBillboards)
        seenBillboards = [seenBillboards; nextTwoBillboardInd];
        %disp('seenBillboards plus the next two: ')
        % disp(seenBillboards)
    
        % Find the high probability targets
        highProbTargets = outputOrder(outputScore > thresh);
        unseenHighProbTargs = highProbTargets(~ismember(highProbTargets,seenBillboards));
    end

    % Only run TSP once per block (ie if the car is still on the
    % initialPath). Only run it when there are at least three 
    % unseenHighProbTargs. And only run it when we've seen at least three 
    % billboards already. 
    if initialPath && (size(classifier_outputs,1)) > 3 && exist('unseenHighProbTargs')
        if (length(unseenHighProbTargs) >= 3)
            
            % Print out the predicted category of interest
            disp(['There are ', num2str(length(unseenHighProbTargs)),' predicted targets from the following categories: '])
            for i = 1:length(unseenHighProbTargs)
                disp(objectList{unseenHighProbTargs(i)}) 
            end
            
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
            
            %% DEBUG RESOLVE180s
            file1 = fullfile('..','..','TSP','fullPath.mat');
            save(file1,'fullPath');
            file2 = fullfile('..','..','TSP','tspOutput.mat');
            save(file2,'tspOutput');
            file3 = fullfile('..','..','TSP','stitchPathPoint.mat');
            save(file3,'stitchPathPoint');
            

            % Check for 180 degree turns, correct them
            present180s = true;
            while present180s
                [fullPath, present180s] = resolve180s(fullPath, tspOutput, stitchPathPoint); 
            end
            %[fullPath, present180s] = resolve180s_v2(fullPath, tspOutput);
            tmpFullPath3 = fullPath; % for debugging
            disp('Fullpath after resolve180s: ')
            disp(fullPath)        

            % Interpolate waypoints in between the turns
            fullPath = interpWaypoints(fullPath,1);
            tmpFullPath4 = fullPath; % for debugging
            disp('Fullpath after interpolation: ')
            disp(fullPath)

            % Run through path and check for errors
            repeatInd = [];
            for i = 1:size(fullPath,1)-2
                % if there is a repeat
                if fullPath(i,1) == fullPath(i+1,1) && fullPath(i,2) == fullPath(i+1,2)
                    repeatInd = [repeatInd; i];
                end
                % if there is an illeagal turn
                if ~(fullPath(i,1) == fullPath(i+1,1) || fullPath(i,2) == fullPath(i+1,2))
                    error(['there is an illegal turn in fullPath at ind ', num2str(i)])
                end
                % if there is a 180
                goingUpCurr = fullPath(i+1,2) - fullPath(i,2) > 0;
                goingUpNext = fullPath(i+2,2) - fullPath(i+1,2) > 0;
                goingHorzCurr = fullPath(i+1,1) ~= fullPath(i,1);
                goingHorzNext = fullPath(i+2,1) ~= fullPath(i+1,1);
                if ~(goingHorzCurr || goingHorzNext) && (goingUpCurr ~= goingUpNext)
                    error(['there is an illegal 180 degree turn in fullPath at in', num2str(i)])
                end 
            end
            fullPath(repeatInd,:) = [];

            dlmwrite('../../NEDE_Game/NedeConfig/newCarPath.txt', horzcat(fullPath,zeros(length(fullPath),1)),'delimiter', ',','newline','pc');
            disp('New carpath defined')
            %disp(['stitchPathsInd: ' num2str(stitchPathsInd)])
        end
    end
    disp(' ')
end
