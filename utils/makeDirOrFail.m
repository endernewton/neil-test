function bool = makeDirOrFail(dirName)
%from santosh
[~, ~, smessid] = mkdir(dirName);
bool = ~strcmp(smessid,'MATLAB:MKDIR:DirectoryExists');
end