clear;
load('tspOutput.mat');

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

% Stitch together the old path and the new path
fullPath = vertcat(oldPath(1:stitchPathsInd-1,1:2), fullPath);

% Interpolate waypoints in between the turns
fullPath = interpWaypoints(fullPath);