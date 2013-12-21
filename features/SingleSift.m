function [descriptor,location,nFeature] = SingleSift(im)

[location,descriptor] = vl_sift(im2single(rgb2gray(im)),'FirstOctave',-1);
location = location';
descriptor = single(descriptor');
s = sqrt(sum(descriptor.^2,2));
descriptor = descriptor ./ repmat(s,1,size(descriptor,2));
nFeature = size(descriptor,1);

end