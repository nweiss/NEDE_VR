function startingLocation = getStartingLocation(billboardID,objLocs,oldPath)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %billboardID: billboard ID from Unity that you most recently passed. Int from 0-total number of
    %billboards
    %objLocs: Matrix that is (Num of billboards x 5). columns are: x, y,
    %image category, image number, billboard id

    %oldPath: matrix (num of waypoints x 3). columns are x, y, number we
    %don't yet understand
    
    % Returns: statingLocation: First point on the new path
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % look up billboard location from billboard ID
    
    billboardLoc = objLocs(objLocs(:,5) == billboardID,1:2);
    
    % get path location next to billboard
    pathLoc = convertBillboardtoPathLocation(billboardLoc);
    
    %look up index of pathLoc in old path
    pathIndex = find(oldPath(:,1) == pathLoc(1) & oldPath(:,2) == pathLoc(2));
    
    % look at future path locations to find 2 billboards ahead
    billboardsAhead = 0;
    while billboardsAhead ~= 2
       pathIndex = pathIndex + 1;
       if (mod(oldPath(pathIndex,2),20)==0) && (oldPath(pathIndex,2)~=160) && (oldPath(pathIndex,2)~=0)
           billboardsAhead = billboardsAhead + 1;
       end
    end
    
    startingLocation = oldPath(pathIndex,1:2);
    
end