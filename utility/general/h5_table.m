% loadһ��h5�ļ�����table, ��stk_code������, ����date���ڵ�һ��
function output_table = h5_table(h5_path, h5_file, tag_name)

    output = h5read([h5_path,'\',h5_file],['/',tag_name])';
    stk_codes = h5read([h5_path,'\',h5_file],'/stk_code');
    dates = h5read([h5_path,'\',h5_file],'/date');
    
    x = [];
    for k = 1 : length(stk_codes)
        z = cell2mat(stk_codes(k));
        x = [x,cellstr(z([8:9,1:6]))]; %#ok<AGROW>
    end    
    
    if(size(output,2)==length(dates))
        output = output';
    end
    output_table = array2table([datenum_h5(dates),output],'VariableNames',['DATEN',x]);
    
    
end

