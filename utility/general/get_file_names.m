function c = get_file_names(k)

    b = dir(k);  
    c = cell(length(b)-2,1);
    
    for i = 3 : length(b)
        c{i-2,1} = b(i).name;
    end
       
end