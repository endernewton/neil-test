function [descriptor,nFeature] = SingleColor(im)

[L, a, b] = rgb2lab(im);
L = single(L);
a = single(a);
b = single(b);
descriptor = cat(2, L(:), a(:), b(:))/100;
clear L a b
nFeature = size(descriptor,1);

end
