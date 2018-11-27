function k = deblank_stk(c)

    % 用于给stk_codes股票代码去后面空格

    k  = cell(length(c),1);
    for i  = 1 : length(c)
        k{i,1} = deblank(c{i,1});
    end
    
end