function [mainFea,moreFea,boxes,rawFea] = extractFeaReturn( imageName, boxSet, options )
% Extract Features for a single Image
% Dictionaries are needed for computing the single image
%   by Ender, xinleic@cs.cmu.edu
%   Nov 2nd, 2012, Modified Dec 2nd, 2012, Mar 16th, 2012

if nargin < 3
    options = [];
end

predirM = '/home/xinleic/lustre/Expers/Relationship/Dictionaries/';
if isfield(options,'cacheFolder')
    predirM = [options.cacheFolder,'MetaFea/'];
end

clusterSFX = 'Clusters.mat';
if isfield(options,'clusterSFX')
    clusterSFX = options.clusterSFX;
end

featureSetH = {'hog','color','sift','ssim','texton'};
if isfield(options,'featureSetH')
    featureSetH = options.featureSetH;
end

featureSetNH = {'gist'};
if isfield(options,'featureSetNH')
    featureSetNH = options.featureSetNH;
end

bSaveData = 0;
if isfield(options,'bSaveData')
    bSaveData = options.bSaveData;
end

bLoadData = 0;
if isfield(options,'bLoadData')
    bLoadData = options.bLoadData;
end

maxSize = 1024;
if isfield(options,'maxSizeFea')
    maxSize = options.maxSizeFea;
end

% HOG
blocksize = 8;
if isfield(options,'blocksize')
    blocksize = options.blocksize;
end

% SSIM
parms.size=5;
if isfield(options,'sizeSSIM')
    parms.size = options.sizeSSIM;
end
radius=(parms.size-1)/2;

parms.coRelWindowRadius=40;
if isfield(options,'coRelWindowRadius')
    parms.coRelWindowRadius = options.coRelWindowRadius;
end
marg=radius+parms.coRelWindowRadius;

parms.numRadiiIntervals=4;
if isfield(options,'numRadiiIntervals')
    parms.numRadiiIntervals = options.numRadiiIntervals;
end

parms.numThetaIntervals=20;
if isfield(options,'numThetaIntervals')
    parms.numThetaIntervals = options.numThetaIntervals;
end

parms.varNoise=25*3*36;
if isfield(options,'varNoise')
    parms.varNoise = options.varNoise;
end

parms.autoVarRadius=1;
if isfield(options,'autoVarRadius')
    parms.autoVarRadius = options.autoVarRadius;
end

parms.saliencyThresh=0;
if isfield(options,'saliencyThresh')
    parms.saliencyThresh = options.saliencyThresh;
end

maxImSizeSSIM = 720;
if isfield(options,'maxImSizeSSIM')
    maxImSizeSSIM = options.maxImSizeSSIM;
end

minImSizeSSIM = 120;
if isfield(options,'minImSize')
    minImSizeSSIM = options.minImSizeSSIM;
end

% Texton
maxImSizeTexton = 320;
if isfield(options,'maxImSizeTexton')
    maxImSizeTexton = options.maxImSizeTexton;
end

% GIST
gistParamName = [predirM,options.gistParamName];

if fileExists(gistParamName)
    load(gistParamName,'gistParam');
else
    gistParam.orientationsPerScale = [8 8 8 8];
    if isfield(options,'orientationsPerScale')
        gistParam.orientationsPerScale = options.orientationsPerScale;
    end
    
    gistParam.numberBlocks = 4;
    if isfield(options,'numberBlocks')
        gistParam.numberBlocks = options.numberBlocks;
    end
    
    gistParam.fc_prefilt = 4;
    if isfield(options,'fc_prefilt')
        gistParam.fc_prefilt = options.fc_prefilt;
    end
    
    gistParam.boundaryExtension = 32;
    if isfield(options,'boundaryExtension')
        gistParam.boundaryExtension = options.boundaryExtension;
    end
    
    gistParam.imageSize = 256;
    if isfield(options,'imageSize')
        gistParam.imageSize = options.imageSizeGIST;
    end
    
    gistParam.G = createGabor(gistParam.orientationsPerScale, gistParam.imageSize + 2 * gistParam.boundaryExtension);
    save(gistParamName,'gistParam');
end

im = imread(imageName);
im = squeeze(im);
sIm = size(im);
sIm = sIm(1:2);
if max(sIm) > maxSize
    disp('Image is too large!')
    Scale = max(sIm) / maxSize;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
end
clear sIm

if length(size(im)) == 2
    im = repmat(im,[1,1,3]);
end
sizeI = size(im);
disp(sizeI);

nBox = length(boxSet);
nFea = length(featureSetH) + length(featureSetNH);

MainFeatureCell =  cell(nFea,1);
if nBox > 0
    MoreFeatureCell =  cell(nFea,nBox);
end

if any(strcmpi('texton',featureSetH))
    filterBank = createFilterBank(options);
    disp(['Number of filter Banks:', int2str(numel(filterBank))]);
end

%% Computing histgrams for the features
for f = 1:length(featureSetH)
    featureName = featureSetH{f};
    % Load Clusters
    clusterName = [predirM,featureName,clusterSFX];
    load(clusterName,'centers');
    dictionarySize = size(centers,1);
    disp([featureName,': ',int2str(dictionarySize)]);
    
    dataName = strrep(strrep(imageName,'/images/',['/',featureName,'/data/']),'.jpg','.mat');
    try % Loading the data if it exists
        if bLoadData
            load(dataName);
            if strcmpi(featureName,'color')
                descriptor = featColor;
            end
            if strcmpi(featureName,'color')
                descriptor = reshape(descriptor,numel(descriptor)/3,3);
            end
        else
            error('This is a fake error! Computing features directly...');
        end
    catch ME
        disp(ME.message);
        disp('Data does not exist, computing data!');
        
        switch featureName
            case 'hog'
                [descriptor,nFeature] = SingleHog(im,blocksize);
                if bSaveData
                    save(dataName,'descriptor','nFeature');
                end
            case 'color'
                [descriptor,nFeature] = SingleColor(im);
                if bSaveData
                    save(dataName,'descriptor','nFeature');
                end
            case 'sift'
                [descriptor,location,nFeature] = SingleSift(im);
                if bSaveData
                    save(dataName,'descriptor','location','nFeature');
                end
            case 'ssim'
                [descriptor,nFeature,drawCoords,salientCoords,uniformCoords] ...
                    = SingleSSIM(im,sizeI,parms,marg,maxImSizeSSIM,minImSizeSSIM);
                if bSaveData
                    vars = {descriptor,nFeature,drawCoords, ...
                        salientCoords,uniformCoords};
                    varNs = {'descriptor','nFeature','drawCoords', ...
                        'salientCoords','uniformCoords'};
                    saveFS(dataName,vars,varNs);
                    clear vars varNs
                end
            case 'texton'
                [descriptor,nFeature,sizeTexton] = SingleTexton(im,filterBank,sizeI,maxImSizeTexton);
                if bSaveData
                    vars = {descriptor,nFeature};
                    varNs = {'descriptor','nFeature'};
                    saveFS(dataName,vars,varNs);
                    clear vars varNs
                end
        end
    end
    
    % Compute histgrams
    indexFeature = getNearest(descriptor, centers);
    final = hist(indexFeature(:),1:dictionarySize);
    MainFeatureCell{f} = final / (sum(final) + eps);
    
    if nBox > 0
        for b = 1:nBox
            Box = boxSet{b};
            BBox = zeros(1,4);
            BBox([1,3]) = max(round(Box([1,3]) * sizeI(2)),1);
            BBox([2,4]) = max(round(Box([2,4]) * sizeI(1)),1);
            switch featureName
                case 'hog'
%                     clear descriptor
                    [descriptor,~] = BoxHog(im,BBox,blocksize);
                    indexF = getNearest(descriptor, centers);
                    final = hist(indexF(:),1:dictionarySize);
                    MoreFeatureCell{f,b} = final / (sum(final) + eps);
                    clear indexF
                case 'color'
                    indexF = reshape(indexFeature,sizeI(1),sizeI(2));
                    indexF = indexF(BBox(2):BBox(4),BBox(1):BBox(3));
                    final = hist(indexF(:),1:dictionarySize);
                    MoreFeatureCell{f,b} = final / (sum(final) + eps);
                    clear indexF
                case 'sift'
                    inbox = location(:,1) >= BBox(1) & location(:,1) <= BBox(3) ...
                        & location(:,2) >= BBox(2) & location(:,2) <= BBox(4);
                    indexF = indexFeature(inbox);
                    final = hist(indexF(:),1:dictionarySize);
                    if sum(final) > 0
                        MoreFeatureCell{f,b} = final / (sum(final) + eps);
                    else
                        MoreFeatureCell{f,b} = final;
                    end
                    clear inbox indexF
                case 'ssim'
                    descriptor = BoxSSIM(im,parms,marg,BBox,maxImSizeSSIM,minImSizeSSIM);
                    indexF = getNearest(descriptor, centers);
                    final = hist(indexF(:),1:dictionarySize);
                    MoreFeatureCell{f,b} = final / (sum(final) + eps);
                    clear indexF
                case 'texton'
                    indexF = reshape(indexFeature,sizeTexton(1),sizeTexton(2));
                    BBox([1,3]) = max(round(Box([1,3]) * sizeTexton(2)),1);
                    BBox([2,4]) = max(round(Box([2,4]) * sizeTexton(1)),1);
                    indexF = indexF(BBox(2):BBox(4),BBox(1):BBox(3));
                    final = hist(indexF(:),1:dictionarySize);
                    MoreFeatureCell{f,b} = final / (sum(final) + eps);
                    clear indexF
            end
        end
    end
    
    clear descriptor
    
end

lH = length(featureSetH);
%% Computing raw data for features
for f = 1:length(featureSetNH)
    featureName = featureSetNH{f};
    dataName = strrep(strrep(imageName,'/images/',['/',featureName,'/']),'.jpg','.mat');
    try
        if bLoadData
            load(dataName);
        else
            error('This is a fake error! Computing features directly...');
        end
    catch ME
        disp(ME.message)
        disp('Data does not exist, computing data!');
        switch featureName
            case 'gist'
                descriptor = SingleGist(im, gistParam);
                if bSaveData
                    save(dataName,'descriptor','-v7.3');
                end
        end
    end
    MainFeatureCell{f + lH} = double(descriptor);
    
    % disp(size(im));
    if nBox > 0
        for b = 1:nBox
            disp(b);
            Box = boxSet{b};
            BBox = zeros(1,4);
            BBox([1,3]) = max(round(Box([1,3]) * sizeI(2)),1);
            BBox([2,4]) = max(round(Box([2,4]) * sizeI(1)),1);
            tim = im(BBox(2):BBox(4),BBox(1):BBox(3),:);
            descriptor =  SingleGist(tim, gistParam);
            MoreFeatureCell{f + lH,b} = double(descriptor);
        end
    end
end

%% Sort and save data
mainFea = sparse(cat(2,MainFeatureCell{:}));
nFea = length(mainFea);
disp(['Feature Length: ',int2str(nFea)]);

if nBox > 0
    moreFea = sparse(nBox,nFea);
    count = 1;
    rawFea = [];
    for f = 1:lH
        featureName = featureSetH{f};
        tmp = cat(1,MoreFeatureCell{f,:});
        l = size(tmp,2);
%         disp(l);
        moreFea(:,count:count+l-1) = tmp;
        count = count + l;
        mtmp = MainFeatureCell{f};
        tmp = [mtmp;tmp];
        eval(['rawFea.',featureName,'=tmp;']);
        clear tmp mtmp
    end
    %     lNH = length(featureSetNH);
    for f = 1:length(featureSetNH)
        featureName = featureSetNH{f};
        tmp = cat(1,MoreFeatureCell{f + lH,:});
        l = size(tmp,2);
        moreFea(:,count:count+l-1) = tmp;
        count = count + l;
        mtmp = MainFeatureCell{f + lH};
        tmp = [mtmp;tmp];
        eval(['rawFea.',featureName,'=tmp;'] );
        clear tmp mtmp
    end
    boxes = cat(1,boxSet{:});
else
    rawFea = [];
    for f = 1:lH
        featureName = featureSetH{f};
        mtmp = MainFeatureCell{f};
        eval(['rawFea.',featureName,'=mtmp;']);
        clear mtmp
    end
    for f = 1:length(featureSetNH)
        featureName = featureSetNH{f};
        mtmp = MainFeatureCell{f + lH};
        eval(['rawFea.',featureName,'=mtmp;']);
        clear mtmp
    end
    boxes = cat(1,boxSet{:});
end


end
