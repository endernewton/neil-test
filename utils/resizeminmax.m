function [img,ratio] = resizeminmax( img, minsize, maxsize )
%RESIZEMAX by Ender, xinleic@cs.cmu.edu
% If the maximum length is not between minsize and maxsize, resize it

if size(img,3) == 1
    img = repmat(img,[1,1,3]);
end

sizeI = size(img);

sizeI = sizeI(1:2);
msize = max(sizeI);
ratio = 1;

if msize < minsize
    ratio = minsize / msize;
    img = imresize(img, ratio, 'cubic');
elseif msize > maxsize
    ratio = maxsize / msize;
    img = imresize(img, ratio, 'cubic');
end

end