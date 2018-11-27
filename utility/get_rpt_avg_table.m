function    [x,y,d] = get_rpt_avg_table(table_name, word_name, q_adj,input_data_path,stks)

    % 取Wind计算的数据table_name是Wind中的表名, word_name是表里面要取的某条数据名
    % q_adj: 为true则要算两期平均的指标, 例如增长？
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
       y(1,:) = x(1,:);
       y(2:end,:) = (x(2:end,:) + x(1:end-1,:))/2; % 取两期平均
    end
    
    
end