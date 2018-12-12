function x = gen_colnames(stk_codes)
% 从h5文件中读取的stk_codes转为可以用为table列名的cell

    x = [];
    for k = 1 : length(stk_codes)
        z = cell2mat(stk_codes(k));
        x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
    end

end

