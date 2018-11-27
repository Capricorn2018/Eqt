function    [x,y,d] = get_rpt_table(table_name, word_name, q_adj,input_data_path,stks)

    % 取Wind计算的数据table_name是Wind中的表名, word_name是表里面要取的某条数据名
    % q_adj: 为true则要算单季度数据, 比如营业收入
    % stks: 需要取的那些票的代码数据6位
    
    N = length(stks);   
    file_name  = [input_data_path,'\DB\wind\ybl\',table_name,'.',word_name,'.h5'];
    c = h5read(file_name,['/',word_name])';
    d = datenum_h5(h5read(file_name,'/report_period'));
    s = h5read(file_name,'/stk_code');
    
    [x,y] = deal(NaN(length(d),N));
    
    [~,ia,ib]  = intersect(stks,deblank_stk(s));
    x(:,ia) = c(:,ib);
    
    if q_adj
        % 从季报年报中取单季度数据
        m3  = find(month(d)==3); % 一季度的下标
        m6912 = find(month(d)~=3); % 二三四季度的下标
        m6912(m6912==1) = []; % 如果是第一个报表数据, 不动
        y(m3,:) = x(m3,:); % 一季度的就是单季度数据, 不动
        y(m6912,:) = x(m6912,:) - x(m6912-1,:); % 对二三四季度的数据, 减去上一个季报数据
    end
    
end