function  t = get_tag(file_name)

    % 取h5文件中除date和stk_code外所有的数据名

    f = h5info(file_name);
    for i  = 1:length(f.Datasets)
        x = deblank(f.Datasets(i).Name);
        if (~strcmp(x,'date'))&&(~strcmp(x,'stk_code')) % date和stk_code除外
            t = x; 
            return;
        end
    end
   
end



