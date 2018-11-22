% 因子的filename都是bp_xxxx_xxxx.h5这种格式, 取最前面的就是因子名bp
function tag = file2tag(filename)

    str_cells = strsplit(filename,'_');
    tag = cell2mat(str_cells(1));

end

