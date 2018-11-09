function    [x,y,d] = get_rpt_table_by_ttm(table_name, word_name, q_adj,input_data_path,stks)

    N = length(stks);   
    file_name  = [input_data_path,'\DB\wind\',table_name,'.',word_name,'.h5'];
    c = h5read(file_name,['/',word_name])';
    d = datenum_h5(h5read(file_name,'/report_period'));
    s = h5read(file_name,'/stk_code');
    
    [x,y] = deal(NaN(length(d),N));
    
    [~,ia,ib]  = intersect(stks,deblank_stk(s));
    x(:,ia) = c(:,ib);
    
    if q_adj
       y = [NaN(1,size(x,2));x(2:end,:) - x(1:end-1,:)];
%        m3  = find(month(d)==3);
%        m6912 = find(month(d)~=3); 
%        m6912(m6912==1) = [];
%        y(m3,:) = x(m3,:);
%        y(m6912,:) = x(m6912,:) - x(m6912-1,:);
    end
    
end