% ���ӵ�filename����bp_xxxx_xxxx.h5���ָ�ʽ, ȡ��ǰ��ľ���������bp
function tag = file2tag(filename)

    str_cells = strsplit(filename,'_');
    tag = cell2mat(str_cells(1));

end

