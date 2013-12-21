%David Fouhey, Xinlei Chen

%Code to get a reasonable filter bank

function [filterBank] = createFilterBank(options)
    if nargin == 0
        options = [];
    end
    filterBank = {};
    %3 scales
    for scale=1:1:3
        scaleMultiply = sqrt(2)^scale;
        %Some arbitrary scales
        gaussianSigmas = [1, 2, 4];
        if isfield(options,'gaussianSigmas')
            gaussianSigmas = options.gaussianSigmas;
        end
        
        logSigmas = [1, 2, 4, 8];
        if isfield(options,'logSigmas')
            logSigmas = options.logSigmas;
        end
        
        dGaussianSigmas = [2, 4];
        if isfield(options,'dGaussianSigmas')
            dGaussianSigmas = options.dGaussianSigmas;
        end
        
        gaborAngle = [0, pi/6, pi/3, pi/2, pi*2/3, pi*5/6];
        if isfield(options,'gaborAngle')
            gaborAngle = options.gaborAngle;
        end
        
        gaborWavelength = sqrt([2, 4]);
        if isfield(options,'gaborWavelength')
            gaborWavelength = options.gaborWavelength;
        end
        
        gaborKx = sqrt(1/2);
        gaborKy = sqrt(1/2);
        
        %Gaussians
        for s=gaussianSigmas
            filterBank = [filterBank, getGaussianFilter(s*scaleMultiply)];
        end
        %LoG
        for s=logSigmas
            filterBank = [filterBank, getLOGFilter(s*scaleMultiply)];
        end
        %d/dx, d/dy Gaussians
        for s=dGaussianSigmas
            filterBank = [filterBank, filterDerivativeX(getGaussianFilter(s*scaleMultiply))];
            filterBank = [filterBank, filterDerivativeY(getGaussianFilter(s*scaleMultiply))];
        end
        
    end
    for i=gaborAngle
        for j=gaborWavelength
            [evenFilter,oddFilter] = gabor( j, i, gaborKx, gaborKy );
            filterBank = [filterBank, evenFilter, oddFilter];
        end
    end
end

function h = getGaussianFilter(sigma)
    h = fspecial('gaussian',ceil(sigma*3*2+1),sigma);
end

function h = getLOGFilter(sigma)
    h = fspecial('log',ceil(sigma*3*2+1),sigma);
end

function hD = filterDerivativeX(h)
    ddx = [-1, 0, 1];
    hD = imfilter(h, ddx); 
end

function hD = filterDerivativeY(h)
    ddy = [-1, 0, 1]';
    hD = imfilter(h, ddy);
end
