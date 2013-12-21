function [descriptor,nFeature] = SingleHog(im,blocksize)

descriptor = vl_hog(im2single(im), blocksize);
sizeD = size(descriptor);
descriptor = reshape(descriptor,sizeD(1) * sizeD(2), sizeD(3));
nFeature = size(descriptor,1);

end
