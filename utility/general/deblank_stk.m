function k = deblank_stk(c)

    % ���ڸ�stk_codes��Ʊ����ȥ����ո�

    k  = cell(length(c),1);
    for i  = 1 : length(c)
        k{i,1} = deblank(c{i,1});
    end
    
end