function x = gen_colnames(stk_codes)
% ��h5�ļ��ж�ȡ��stk_codesתΪ������Ϊtable������cell

    x = [];
    for k = 1 : length(stk_codes)
        z = cell2mat(stk_codes(k));
        x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
    end

end

