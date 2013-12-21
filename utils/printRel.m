function printRel( relationships, filename )
%PRINTREL by Ender, xinleic@cs.cmu.edu
%   April 8th, 2013

f = fopen(filename,'w');

l = length(relationships);

fprintf(f,'%s\t%s\t%s\n','Class_1','Class_2','Type');

for i=1:l
    fprintf(f,'%s\t%s\t%s\n',relationships(i).cls1,relationships(i).cls2,relationships(i).type);
end

fclose(f);

end

