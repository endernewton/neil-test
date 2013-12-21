function box = randomBoxGen( thres, nGrid, overlap, options )
%randomBoxGen by Ender, xinleic@cs.cmu.edu
%   Nov 2nd, 2012

if nargin < 4
    options = [];
end

maxNum = 1000;
if isfield(options,'rBoxNum')
    maxNum = options.rBoxNum;
end

if isfield(options,'grid')
    disp('require options.aspratio!');
    aspratio = options.aspratio; % need to specify aspect ratio if using grid
    disp(aspratio);
    bGrid = 1;
else
    bGrid = 0;
end

distort = 0.9;
if isfield(options,'distort')
    distort = options.distort;
end

if ~bGrid
    distort = 0;
end

grids = 0:1/nGrid:1;

boxes = zeros(maxNum,4);
box = cell(maxNum,1);
opts.distance = 'euclidean';

for iter = 1:maxNum
    done = 0;   
    while ~done       
        span = 0;
        
        if ~bGrid
            while span < thres
                x = randperm(nGrid+1);
                x = sort(x(1:2));
                x = grids(x);
                
                y = randperm(nGrid+1);
                y = sort(y(1:2));
                y = grids(y);
                
                ar = (x(2) - x(1)) / (y(2) - y(1));
                span = (x(2) - x(1)) * (y(2) - y(1));
            end
        else
            while span < thres || dis < distort
                
                x = randperm(nGrid+1);
                x = sort(x(1:2));
                x = grids(x);
                py = (x(2) - x(1)) / aspratio;
                
                y = randperm(nGrid+1);
                y = grids(y(1));
                y = [max(y-py/2,0),min(y+py/2,1)];
                dis = min(aspratio/ar,ar/aspratio);
                
                ar = (x(2) - x(1)) / (y(2) - y(1));
                span = (x(2) - x(1)) * (y(2) - y(1));
            end
        end
        
        Box = [x(1),y(1),x(2),y(2)];
        
        dist = distanceToSet(Box',boxes',opts);
        if all(dist > overlap)
            done  = 1;
            boxes(iter,:) = Box;
            box{iter} = Box;
        end
    end
end

end

