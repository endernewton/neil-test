function bboxes = testerNEIL( models, imagenames, options )
% by Ender, xinleic@cs.cmu.edu

% Input:
% - models: model sets provided by NEIL, they are models for the objects
% - imagenames: image names (paths to the images) specified by user
% - options: important parameters
%   - options.thresOffset: the threshold of being identified as a correct
%   detection
%   - options.testInterval: intervals between two layers of images in the
%   pyramid

% Output:
% - bboxes: bounding boxes of objects found by each of the models in each
% of the images

% Usage:
%   >> load airplane.mat % load the model of an airplane
%   >> imagenames = importdata('/path/to/imagelist.txt');
%   >> bboxes = testerNEIL( model, imagenames );
%   >> save bboxes.mat bboxes

start = tic;

if nargin < 3
    options = [];
end

thresOffset = -0.5;
if isfield(options,'thresOffset')
    thresOffset = options.thresOffset;
end

testInterval = 10;
if isfield(options,'testIntervalScene')
    testInterval = options.testIntervalScene;
end

disp(['Interval for the pyramid set to: ', int2str(testInterval)]);
models{1}.interval = testInterval;
lmo = length(models);
lim = length(imagenames);

bboxes = cell(lmo,lim);

for l=1:lim
    
    im = color(imread(imagenames{l}));
    
    % do the detection
    threshes = cellfun(@(x)x.thresh,models);
    bboxes(:,l) = imgdetectBLOCK(im, models, max(threshes + thresOffset,-2), 'CHOG', options);
    
    % reduce using nms
    for i=1:lmo
        if ~isempty(bboxes{i,l})
            bboxes{i,l} = myNms(bboxes{i,l}(:,[1:4,6]), 0.5);
        end
    end
    
end

fprintf('Testing took %.4f seconds\n', toc(start));

end

