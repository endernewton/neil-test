function [descriptor,nFeature,drawCoords,salientCoords,uniformCoords] = SingleSSIM(im,sizeI,parms,marg,maxImSize,minImSize)

sIm = sizeI(1:2);
if max(sIm) > maxImSize
    disp('Image is too large!')
    Scale = max(sIm) / maxImSize;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
elseif min(sIm) < minImSize
    disp('Image is too small!')
    Scale = min(sIm) / minImSize;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
end
clear sIm

parms.nChannels=sizeI(3);

[allXCoords,allYCoords]=meshgrid(marg+1:5:sizeI(2)-marg,marg+1:5:sizeI(1)-marg);
allXCoords=allXCoords(:)';
allYCoords=allYCoords(:)';
[descriptor,drawCoords,salientCoords,uniformCoords]=ssimDescriptor(double(im) ,parms ,allXCoords ,allYCoords);
% clear allXCoords allYCoords
descriptor = descriptor';
drawCoords = drawCoords';
salientCoords = salientCoords';
uniformCoords = uniformCoords';
nFeature = size(descriptor,1);

end
