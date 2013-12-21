function y = meanTop(x,pers,sig)
l = round(length(x)*pers);
if l >= sig
    y = mean(x(1:l));
else
    y = single(-inf);
end
end