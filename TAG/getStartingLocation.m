function [startingLocation, pathIndex] = getStartingLocation(billboardID,objLocs,oldPath, numBillboardsSeen)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %billboardID: billboard ID from Unity that you most recently passed. Int from 0-total number of
    %billboards
    %objLocs: Matrix that is (Num of billboards x 5). columns are: x, y,
    %image category, image number, billboard id

    %oldPath: matrix (num of waypoints x 3). columns are x, y, number we
    %don't yet understand
    
    % Returns: statingLocation: First point on the new path
    %  - pathIndex: the index of the startingLocation on the oldPath
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % for every index in old path get the number of billboards seen
    
    billboardsSeen = zeros(length(oldPath),1);
    billboardsSeenCounter = 0;
    for i=1:length(oldPath)
       if mod(oldPath(i,2),20) == 0 && oldPath(i,2)~=160 && oldPath(i,2)~=0
            billboardsSeenCounter = billboardsSeenCounter + 1;
       end
       billboardsSeen(i) = billboardsSeenCounter;
    end
    
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
       if (mod(oldPath(pathIndex,2),20)==0) & (oldPath(pathIndex,2)~=160) & (oldPath(pathIndex,2)~=0) & billboardsSeen(pathIndex) > numBillboardsSeen 
           billboardsAhead = billboardsAhead + 1;
       end
    end
    
    % make sure that the path index chosen is the path index that we
    % already haven't been to and is the next occurence of that location in
    % the path
    
    for j=1:length(pathIndex)
       if billboardsSeen(pathIndex(j)) > numBillboardsSeen
          realPathIndex = pathIndex(j);
          break;
       end
    end
    
    startingLocation = oldPath(realPathIndex,1:2);
    
end