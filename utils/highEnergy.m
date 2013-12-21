function bbox = highEnergy(img,bb)

im = img(ceil(bb(2)):floor(bb(4)),ceil(bb(1)):floor(bb(3)),:);
[h,w,d] = size(im);

filt = fspecial('laplacian',0.2);
if d == 3
    res_r = filter2(filt,im(:,:,1),'valid');
    res_g = filter2(filt,im(:,:,2),'valid');
    res_b = filter2(filt,im(:,:,3),'valid');
    res = (res_r + res_g + res_b)/3;
else
    res = filter2(filt,im,'valid');
end

res = abs(res);
res = imresize(res,[100 100],'bicubic');
res = abs(res);
res = res./sum(sum(res));
mm = max(max(res));
res2 = zeros(size(res));
res2(res >= mm/10) = res(res >= mm/10);
res = res2;
clear res2
% for i = 1:100
%     for j = 1:100
%         if res(i,j) < mm/10;
%             res(i,j) = 0;
%         end
%     end
% end

filt = fspecial('gaussian',[5 5], 0.8);
res = filter2(filt,res,'same');
res = res./sum(sum(res));
% res = stdfilt(res);
% res = res./sum(sum(res));

sum_x = 0; sum_y = 0;
for i = 1:100
    px(i) = sum(res(i,:));
    py(i) = sum(res(:,i));
    sum_x = sum_x + px(i)^2;
    sum_y = sum_y + py(i)^2;
end

[~,idx_x] = sort(px,'descend');
[~,idx_y] = sort(py,'descend');

center_x = idx_x(50);
center_y = idx_y(50);

x1 = 0; x2 = 0;
while true
    s = 0;
    for i = center_x - x1 : center_x + x2
        s = s+ px(i)^2;
    end
    if s >= 0.999*sum_x
        x_lim1 = center_x - x1;
        x_lim2 = center_x + x2;
        break;
    end
    if center_x - x1 - 1 < 1
        x2 = x2 + 1;
    elseif center_x + x2 + 1 > 100
        x1 = x1 + 1;
    elseif px(center_x - x1 - 1) > px(center_x + x2 + 1)
        x1 = x1 + 1;
    else
        x2 = x2 + 1;
    end
end

x1 = 0; x2 = 0;
while true
    s = 0;
    for i = center_y - x1 : center_y + x2
        s = s+ py(i)^2;
    end
    if s >= 0.999*sum_y
        y_lim1 = center_y - x1;
        y_lim2 = center_y + x2;
        break;
    end
    
    if center_y - x1 - 1 < 1
        x2 = x2 + 1;
    elseif center_y + x2 + 1 > 100
        x1 = x1 + 1;
    elseif py(center_y - x1 - 1) > py(center_y + x2 + 1)
        x1 = x1 + 1;
    else
        x2 = x2 + 1;
    end
    
end

while true
    s = 0;
    for i = x_lim1+1:x_lim2
        s = s+ px(i)^2;
    end
    if s >= 0.999*sum_x
        x_lim1 = x_lim1 + 1;
    else
        break;
    end
end

while true
    s = 0;
    for i = x_lim1:x_lim2-1
        s = s+ px(i)^2;
    end
    if s >= 0.999*sum_x
        x_lim2 = x_lim2 - 1;
    else
        break;
    end
end

while true
    s = 0;
    for i = y_lim1+1:y_lim2
        s = s+ py(i)^2;
    end
    if s >= 0.999*sum_y
        y_lim1 = y_lim1 + 1;
    else
        break;
    end
end

while true
    s = 0;
    for i = y_lim1:y_lim2-1
        s = s+ py(i)^2;
    end
    if s >= 0.999*sum_y
        y_lim2 = y_lim2 - 1;
    else
        break;
    end
end


x_lim1 = (x_lim1*h/100) + bb(2);
x_lim2 = (x_lim2*h/100) + bb(2);
y_lim1 = (y_lim1*w/100) + bb(1);
y_lim2 = (y_lim2*w/100) + bb(1);

if length(bb) == 5
    bbox = [y_lim1 x_lim1 y_lim2 x_lim2 bb(5)];
else
    bbox = [y_lim1 x_lim1 y_lim2 x_lim2];
end

return;

end