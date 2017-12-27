function [newPath, present180s, tspOutput] = resolve180s(fullPath, tspOutput, stitchPathPoint)

    % only add stitch path point if it isn't already on tspOutput
    if ~any(stitchPathPoint(1) == tspOutput(:,1) & stitchPathPoint(2) == tspOutput(:,2))
        tspOutput = [stitchPathPoint; tspOutput];
    end
    present180s = false;
    newPath = fullPath;
    
    % Check to see if every point in tspOutput has been passed. If it has,
    % cut off the path immediately after they are all passed. Also, change
    % the order of tspOutput to match the order in which the billboards are
    % passed.
    tspOutputPassed = zeros(length(tspOutput),1);
    tspOutputPassedOrder = zeros(length(tspOutput),1);
    tspCounter = 1;
    for i = 1:length(fullPath)-2
        disp(i)
        indOfTSPOutputPassed = find(all(tspOutput == fullPath(i,:),2));
        if ~isempty(indOfTSPOutputPassed)
            tspOutputPassed(indOfTSPOutputPassed) = 1;
            tspOutputPassedOrder(tspCounter) = indOfTSPOutputPassed;
            tspCounter = tspCounter + 1;
            disp(['fullpath ind: ' num2str(i)])
            disp(['tspOutput ind: ' num2str(indOfTSPOutputPassed)])
            if all(tspOutputPassed)
                newPath = fullPath(1:i,:);
                tspOutput = tspOutput(tspOutputPassedOrder,:);
                disp('Passed all billboards in tspOutput')
                break
            end
        end
    end
    
    % Check for 180 degree turns, correct them
    for i = 1:length(fullPath)-2        
        
        % Delete any duplicates
        if all(fullPath(i+1,:) == fullPath(i,:))
            present180s = true;
            fullPath(i+1,:) = [];
            newPath = fullPath;
            break
        end
   
        goingUpCurr = fullPath(i+1,2) - fullPath(i,2) > 0;
        goingUpNext = fullPath(i+2,2) - fullPath(i+1,2) > 0;
        goingDownCurr = fullPath(i+1,2) - fullPath(i,2) < 0;
        goingDownNext = fullPath(i+2,2) - fullPath(i+1,2) < 0;
        goingLeftCurr = fullPath(i+1,1) - fullPath(i,1) < 0;
        goingLeftNext = fullPath(i+2,1) - fullPath(i+1,1) < 0;
        goingRightCurr = fullPath(i+1,1) - fullPath(i,1) > 0;
        goingRightNext = fullPath(i+2,1) - fullPath(i+1,1) > 0;

        % if there is a 180 degree turn
        if (goingLeftCurr == 1 && goingRightNext == 1) || (goingRightCurr == 1 && goingLeftNext == 1) || (goingUpCurr == 1 && goingDownNext == 1) || (goingDownCurr == 1 && goingUpNext == 1)
            present180s = true;
            % Find the next billboard location
            IndOfCurrLocOnTSPPath = find(all(tspOutput == fullPath(i+1,:),2));
            if isempty(IndOfCurrLocOnTSPPath)
                fullPath(i+1,:) = [];
                newPath = fullPath;
                break
            end
            currBillboardPathLoc = tspOutput(IndOfCurrLocOnTSPPath,:);
            nextBillboardPathLoc = tspOutput(IndOfCurrLocOnTSPPath+1,:);
            IndOfCurrBillboardOnFullPath = find(all(fullPath == currBillboardPathLoc,2));
            IndOfNextBillboardOnFullPath = find(all(fullPath == nextBillboardPathLoc,2));

            % If the next billboard is in the same column of the grid
            % level as the current billboard

            % If the next billboard is in a different column of the
            % grid level than the current billboard
            if currBillboardPathLoc(1) ~= nextBillboardPathLoc(1)
                % If the car is going up
                if goingUpCurr == true
                    newPathAddition(1,1:2) = [fullPath(i+1,1) fullPath(i+1,2)+10]; % don't turn around
                    newPathAddition(2,1:2) = [nextBillboardPathLoc(1) fullPath(i+1,2)+10]; %turn on alley and got to the proper street
                    newPathAddition = [newPathAddition; nextBillboardPathLoc]; % add the next billboard to the end which will be a straight shot
                    newCarPath = interpWaypoints(newPathAddition,0); % interpolate 
                end
                % If the car is going down
                if goingUpCurr == false
                    newPathAddition(1,1:2) = [fullPath(i+1,1) fullPath(i+1,2)-10]; % don't turn around
                    newPathAddition(2,1:2) = [nextBillboardPathLoc(1) fullPath(i+1,2)-10]; %turn on alley and got to the proper street
                    newPathAddition = [newPathAddition; nextBillboardPathLoc]; % add the next billboard to the end which will be a straight shot
                    newCarPath = interpWaypoints(newPathAddition,0); % interpolate 
                    
                end
                
                %update full path to remove 180

            end
            % same column as the current billboard (true 180 needed)
            if currBillboardPathLoc(1) == nextBillboardPathLoc(1)
                if fullPath(i+1,1) < 105
                    newColumn = fullPath(i+1,1) + 15;
                else
                    newColumn = fullPath(i+1,1) - 15;
                end
                % If the car is going up
                if goingUpCurr == true
                    newPathAddition(1,1:2) = [fullPath(i+1,1) fullPath(i+1,2)+10]; % don't turn around
                    newPathAddition(2,1:2) = [newColumn fullPath(i+1,2)+10]; 
                    newPathAddition(3,1:2) = [newColumn fullPath(i+1,2)]; 
                    newPathAddition(4,1:2) = [newColumn fullPath(i+1,2)-10]; 
                    newPathAddition(5,1:2) = [fullPath(i+1,1) fullPath(i+1,2)-10]; 
                    newCarPath = [newPathAddition; nextBillboardPathLoc];
                end
                % If the car is going down
                if goingDownCurr == true
                    newPathAddition(1,1:2) = [fullPath(i+1,1) fullPath(i+1,2)-10]; % don't turn around
                    newPathAddition(2,1:2) = [newColumn fullPath(i+1,2)-10]; % right turn! Left would work too.
                    newPathAddition(3,1:2) = [newColumn fullPath(i+1,2)]; % right turn again! Left would work too.
                    newPathAddition(4,1:2) = [newColumn fullPath(i+1,2)+10]; % right turn! Left would work too.
                    newPathAddition(5,1:2) = [fullPath(i+1,1) fullPath(i+1,2)+10]; % right turn! Left would work too.
                    newCarPath = [newPathAddition; nextBillboardPathLoc];
                end
           end
        newPath = [fullPath(1:IndOfCurrBillboardOnFullPath-1,:); newCarPath; fullPath(IndOfNextBillboardOnFullPath+1:end,:)];
        newPath = interpWaypoints(newPath,0);
        break
        end 
    end
end
    
