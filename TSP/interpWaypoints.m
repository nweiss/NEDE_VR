function newCarPath = interpWaypoints(oldCarPath)

    % oldCarPath is a set of waypoints for the carpath that only has the
    % corners of turns.
    % newCarPath takes oldCarPath and interpolates it to find the waypoints
    % at all relevant points in between corners

    nWayPoints = size(oldCarPath,1);
    nColumns = size(oldCarPath,2);
    waypointXPos = 0:15:105;
    waypointYPos = 20:20:140;
    newCarPath = oldCarPath;
    pointsToInsert = [];

    % Iterate through every waypoint in the oldCarPath
    newPathInd = 1;
    for i = 1:nWayPoints-1
        carGoingUp = false;
        carGoingDown = false;
        carGoingRight = false;
        carGoingLeft = false;

        % Determine direction of car
        if oldCarPath(i+1,2) - oldCarPath(i,2) > 0
            carGoingUp = true;
            lowerPoint = oldCarPath(i,2);
            upperPoint = oldCarPath(i+1,2);    
        elseif oldCarPath(i+1,2) - oldCarPath(i,2) < 0
            carGoingDown = true;
            lowerPoint = oldCarPath(i+1,2);
            upperPoint = oldCarPath(i,2); 
        elseif oldCarPath(i+1,1) - oldCarPath(i,1) > 0
            carGoingRight = true;
            leftPoint = oldCarPath(i,1);
            rightPoint = oldCarPath(i+1,1);
        elseif oldCarPath(i+1,1) - oldCarPath(i,1) < 0
            carGoingLeft = true;
            leftPoint = oldCarPath(i+1,1);
            rightPoint = oldCarPath(i,1);
        end

        % If car is going up or down
        if carGoingUp || carGoingDown
            waypointsSkipped = waypointYPos(waypointYPos > lowerPoint & waypointYPos < upperPoint);
            nPointsSkipped = length(waypointsSkipped);
            pointsToInsert = ones(nPointsSkipped, nColumns);
            pointsToInsert(:,1) = oldCarPath(i,1) * ones(nPointsSkipped,1);
            if carGoingUp
                pointsToInsert(:,2) = waypointsSkipped;
            elseif carGoingDown
                pointsToInsert(:,2) = fliplr(waypointsSkipped);
            end
        end

        % If car is going left or right
        if carGoingLeft || carGoingRight
            waypointsSkipped = waypointXPos(waypointXPos > leftPoint & waypointXPos < rightPoint);
            nPointsSkipped = length(waypointsSkipped);
            pointsToInsert = ones(nPointsSkipped, nColumns);
            pointsToInsert(:,2) = oldCarPath(i,2) * ones(nPointsSkipped,1);
            if carGoingRight
                pointsToInsert(:,1) = waypointsSkipped;
            elseif carGoingLeft
                pointsToInsert(:,1) = fliplr(waypointsSkipped);
            end
        end

        % Insert new interpolated points into the newCarPath
        if ~isempty(pointsToInsert)
            prevPoints = newCarPath(1:newPathInd,:);
            nextPoints = newCarPath(newPathInd+1:end,:);
            newCarPath = [prevPoints; pointsToInsert; nextPoints];
            newPathInd = newPathInd + size(pointsToInsert,1);
        end
        newPathInd = newPathInd + 1;
        
        % Add one waypoint to the end of the path so that you can actually
        % see the last tsp point
        if i == nWayPoints-1
            % If car going right and there is room to continue straight
            if carGoingRight == true && newCarPath(newPathInd,1) < 105
                newPoint = [newCarPath(newPathInd,1)+15, newCarPath(newPathInd,2)];
            % If car going right and there is no room to continue straight
            elseif carGoingRight == true && newCarPath(newPathInd,1) == 105
                if newCarPath(newPathInd,2) < 60 % car in lower section of grid
                    newPoint = [105, newCarPath(newPathInd,2) + 20];
                else
                    newPoint = [105, newCarPath(newPathInd,2) - 20];
                end
            % If car going left and there is room to continue straight   
            elseif carGoingLeft == true && newCarPath(newPathInd,1) > 0
                newPoint = [newCarPath(newPathInd,1)-15, newCarPath(newPathInd,2)];
            % If car going left and there is no room to continue straight
            elseif carGoingLeft == true && newCarPath(newPathInd,1) == 0
                if newCarPath(newPathInd,2) < 60 % car in lower section of grid
                    newPoint = [0, newCarPath(newPathInd,2) + 20];
                else
                    newPoint = [0, newCarPath(newPathInd,2) - 20];
                end
            elseif carGoingUp == true
                newPoint = [newCarPath(newPathInd,1), newCarPath(newPathInd,2)+20];
            elseif carGoingDown == true
                newPoint = [newCarPath(newPathInd,1), newCarPath(newPathInd,2)-20];
            end
            newCarPath = [newCarPath; newPoint];
        end
    end
end