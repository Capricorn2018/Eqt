function c = get_file_names(k)

    % ȡ���ļ���·��k�е������ļ���
    
    b = dir(k);  
    c = cell(length(b)-2,1); % dir�Ľ����ǰ����������, �������ļ���
    
    for i = 3 : length(b)
        c{i-2,1} = b(i).name;
    end
       
end