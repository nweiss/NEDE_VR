function [newPath, present180s] = resolve180s_v2(oldPath, tspOutput)

    newPath = oldPath;
    present180s = true;
    i = 1;
    while true
        goingUpCurr = newPath(i+1,2) - newPath(i,2) > 0;
        goingUpNext = newPath(i+2,2) - newPath(i+1,2) > 0;
        goingHorzCurr = newPath(i+1,1) ~= newPath(i,1);
        goingHorzNext = newPath(i+2,1) ~= newPath(i+1,1);
        
        if ~(goingHorzCurr || goingHorzNext) && (goingUpCurr ~= goingUpNext)
            present180s = true;
            
            % Define currDestination and nextDestination, the locations of 
            % the next two billboards marked as high interes
            currDestination = newPath(i+1,:);
            IndOfCurrDestinationInTSP = find(tspOutput(:,1) == currDestination(1) & tspOutput(:,2) == currDestination(2));
            nextDestination = tspOutput(IndOfCurrDestinationInTSP+1,:);
            if isempty(nextDestination)
                break;
            end
            
            % If the current destination and next destination are in
            % different columns in the grid scene
            if currDestination(1) ~= nextDestination(1)
                if goingUpCurr
                    newTurnY = newPath(i+1,2)+10;
                else
                    newTurnY = newPath(i+1,2)-10;
                end
                newPath(i+2,2) = newTurnY;
                newPath(i+3,2) = newTurnY;
                newPath = [newPath(1:i+3,:); nextDestination; newPath(i+4:end,:)];
                disp(['Resolving 180 at ind ' num2str(i) ' with destinations in separate columns'])
            end
            
            % If the current destination and next destination are in the
            % same column in the grid scene
            if currDestination(1) == nextDestination(1)
                if goingUpCurr
                    newTurnY1 = newPath(i+1,2)+10;
                    newTurnY2 = newPath(i+1,2)-10;
                else
                    newTurnY1 = newPath(i+1,2)-10;
                    newTurnY2 = newPath(i+1,2)+10;
                end
                if currDestination(1) < 115
                    newTurnX = currDestination(1)+15;
                else
                    newTurnX = currDestination(1)-15;
                end
                
                pointsToInsert = zeros(4,2);
                pointsToInsert(1,:) = [currDestination(1), newTurnY1];
                pointsToInsert(2,:) = [newTurnX, newTurnY1];
                pointsToInsert(3,:) = [newTurnX, newTurnY2];
                pointsToInsert(4,:) = [nextDestination(1), newTurnY2];
                newPath = [newPath(1:i+1,:); pointsToInsert; newPath(i+2:end,:)];                
                disp(['Resolving 180 at ind ' num2str(i) ' with destinations in the same column'])
            end
        end
        
    if i == length(newPath)-3
        present180s = false;
        % Remove any duplicates
        dupRows = [];
        for i = 1:length(newPath)-1
            if newPath(i,1)==newPath(i+1,1) && newPath(i,2)==newPath(i+1,2)
                dupRows = [dupRows; i+1];
            end
        end
        newPath(dupRows,:) = [];
        break
    end
    i = i+1;
end