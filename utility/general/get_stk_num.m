function  m = get_stk_num(n)

    % �ӹ�Ʊ������ȡǰ6λ������Ϊ����

    m = cell(length(n),1);
    for i  = 1 : length(n)
       x = n{i};
       m{i} = x(1:6);
    end
end