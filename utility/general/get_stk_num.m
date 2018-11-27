function  m = get_stk_num(n)

    % 从股票代码中取前6位数字作为索引

    m = cell(length(n),1);
    for i  = 1 : length(n)
       x = n{i};
       m{i} = x(1:6);
    end
end