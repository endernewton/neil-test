function descriptor = SingleGist(im,gistParam)

im = single(mean(im,3));
im = imresizecrop(im, gistParam.imageSize, 'bilinear');
im = im-min(im(:));
im = 255*im/max(im(:));
output = prefilt(im, gistParam.fc_prefilt);
descriptor = gistGabor(output, gistParam)';

end

function g = gistGabor(img, param)

img = single(img);

w = param.numberBlocks;
G = param.G;
be = param.boundaryExtension;

if ndims(img)==2
    c = 1;
    N = 1;
elseif ndims(img)==3
    [~,~,c] = size(img);
    N = c;
elseif ndims(img)==4
    [nrows ncols c N] = size(img);
    img = reshape(img, [nrows ncols c*N]);
    N = c*N;
end

[ny nx Nfilters] = size(G);
W = w*w;
g = zeros([W*Nfilters N]);

% pad image
img = padarray(img, [be be], 'symmetric');

img = single(fft2(img));
k=0;
for n = 1:Nfilters
    ig = abs(ifft2(img.*repmat(G(:,:,n), [1 1 N])));
    ig = ig(be+1:ny-be, be+1:nx-be, :);
    
    v = downN(ig, w);
    g(k+1:k+W,:) = reshape(v, [W N]);
    k = k + W;
    drawnow
end

if c == 3
    % If the input was a color image, then reshape 'g' so that one column
    % is one images output:
    g = reshape(g, [size(g,1)*3 size(g,2)/3]);
end
end

function output = prefilt(img, fc)

if nargin == 1
    fc = 4; % 4 cycles/image
end

w = 5;
s1 = fc/sqrt(log(2));

% Pad images to reduce boundary artifacts
img = log(img+1);
img = padarray(img, [w w], 'symmetric');
[sn, sm, c, N] = size(img);
n = max([sn sm]);
n = n + mod(n,2);
img = padarray(img, [n-sn n-sm], 'symmetric','post');

% Filter
[fx, fy] = meshgrid(-n/2:n/2-1);
gf = fftshift(exp(-(fx.^2+fy.^2)/(s1^2)));
gf = repmat(gf, [1 1 c N]);

% Whitening
output = img - real(ifft2(fft2(img).*gf));
clear img

% Local contrast normalization
localstd = repmat(sqrt(abs(ifft2(fft2(mean(output,3).^2).*gf(:,:,1,:)))), [1 1 c 1]);
output = output./(.2+localstd);

% Crop output to have same size than the input
output = output(w+1:sn-w, w+1:sm-w,:,:);

end

function y=downN(x, N)

nx = fix(linspace(0,size(x,1),N+1));
ny = fix(linspace(0,size(x,2),N+1));
y  = zeros(N, N, size(x,3));
for xx=1:N
  for yy=1:N
    v=mean(mean(x(nx(xx)+1:nx(xx+1), ny(yy)+1:ny(yy+1),:),1),2);
    y(xx,yy,:)=v(:);
  end
end
end