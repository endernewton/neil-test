function [filterResponses] = extractFilterResponses(I, filterBank)
%David Fouhey
%CV Fall 2012 - 
%Inputs: 
%   I:                  a 3-channel RGB image with width W and height H
%   filterBank:         a cell array of N filters
%Outputs:
%   filterResponses:    a W*H x N*3 matrix of filter responses

    %Convert to Lab
    doubleI = double(I);
    [L,a,b] = rgb2lab(doubleI(:,:,1), doubleI(:,:,2), doubleI(:,:,3));
    pixelCount = size(doubleI,1)*size(doubleI,2);
    filterResponses = zeros(pixelCount, length(filterBank)*3);
    %for each filter and channel, apply the filter, and vectorize
    for filterI=0:length(filterBank)-1
        filter = filterBank{filterI+1};
        filterResponses(:,filterI*3+1) = reshape(imfilter(L, filter), pixelCount, 1);
        filterResponses(:,filterI*3+2) = reshape(imfilter(a, filter), pixelCount, 1);
        filterResponses(:,filterI*3+3) = reshape(imfilter(b, filter), pixelCount, 1);
    end
end
