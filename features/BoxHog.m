function [descriptor,nFeature] = BoxHog(im,BBox,blocksize)

im = im(BBox(2):BBox(4),BBox(1):BBox(3));
[descriptor,nFeature] = SingleHog(im,blocksize);

end