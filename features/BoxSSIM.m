function descriptor = BoxSSIM(im,parms,marg,BBox,maxImSizeSSIM,minImSizeSSIM)

im = im(BBox(2):BBox(4),BBox(1):BBox(3));
sIm = size(im); sIm = sIm(1:2);
if max(sIm) > maxImSizeSSIM
    disp('Image is too large!')
    Scale = max(sIm) / maxImSizeSSIM;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
end
sIm = size(im); sIm = sIm(1:2);
if min(sIm) < minImSizeSSIM
    disp('Image is too small!')
    Scale = min(sIm) / minImSizeSSIM;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
end

parms.nChannels=size(im,3);
[allXCoords,allYCoords]=meshgrid(marg+1:5:size(im,2)-marg,marg+1:5:size(im,1)-marg);
allXCoords=allXCoords(:)';
allYCoords=allYCoords(:)';
descriptor=ssimDescriptor(double(im) ,parms ,allXCoords ,allYCoords);
descriptor = descriptor';

end