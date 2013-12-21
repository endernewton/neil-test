function [descriptor,nFeature,sizeTexton] = SingleTexton(im,filterBank,sizeI,maxImSize)

sIm = sizeI(1:2);
if max(sIm) > maxImSize
    disp('Image is too large!')
    Scale = max(sIm) / maxImSize;
    sIm(1:2) = round(sIm(1:2) / Scale);
    im = imresize(im, sIm(1:2));
end
sizeTexton = sIm;

descriptor = single(extractFilterResponses(im, filterBank));
nFeature = size(descriptor,1);

end