function v = xblank(x)
% ȥ���ַ�����Ŀո�

    v = cell(length(x),1);

    for i=1:length(x)
        
        v{i} = deblank(x{i});
        
    end

end
