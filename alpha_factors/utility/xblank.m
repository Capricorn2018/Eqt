function v = xblank(x)
% 去掉字符串后的空格

    v = cell(length(x),1);

    for i=1:length(x)
        
        v{i} = deblank(x{i});
        
    end

end
