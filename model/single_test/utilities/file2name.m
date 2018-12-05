function name = file2name(filename)
    strs = strsplit(filename,'.');
    name = cell2mat(strs(1));
end