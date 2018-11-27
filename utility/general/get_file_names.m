function c = get_file_names(k)

    % 取得文件夹路径k中的所有文件名
    
    b = dir(k);  
    c = cell(length(b)-2,1); % dir的结果中前两个无意义, 后面是文件名
    
    for i = 3 : length(b)
        c{i-2,1} = b(i).name;
    end
       
end