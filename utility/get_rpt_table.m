function    [x,y,d] = get_rpt_table(table_name, word_name, q_adj,input_data_path,stks)

    % ȡWind���������table_name��Wind�еı���, word_name�Ǳ�����Ҫȡ��ĳ��������
    % q_adj: Ϊtrue��Ҫ�㵥��������, ����Ӫҵ����
    % stks: ��Ҫȡ����ЩƱ�Ĵ�������6λ
    
    N = length(stks);   
    file_name  = [input_data_path,'\DB\wind\ybl\',table_name,'.',word_name,'.h5'];
    c = h5read(file_name,['/',word_name])';
    d = datenum_h5(h5read(file_name,'/report_period'));
    s = h5read(file_name,'/stk_code');
    
    [x,y] = deal(NaN(length(d),N));
    
    [~,ia,ib]  = intersect(stks,deblank_stk(s));
    x(:,ia) = c(:,ib);
    
    if q_adj
        % �Ӽ����걨��ȡ����������
        m3  = find(month(d)==3); % һ���ȵ��±�
        m6912 = find(month(d)~=3); % �����ļ��ȵ��±�
        m6912(m6912==1) = []; % ����ǵ�һ����������, ����
        y(m3,:) = x(m3,:); % һ���ȵľ��ǵ���������, ����
        y(m6912,:) = x(m6912,:) - x(m6912-1,:); % �Զ����ļ��ȵ�����, ��ȥ��һ����������
    end
    
end