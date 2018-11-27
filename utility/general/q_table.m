function [output_table,att] = q_table( conn,q)

    % 执行SQL命令并存入table
    
    curs =  fetch(exec(conn,q));   
    att = curs.attr(end).typeName;   % VARCHAR2 NUMBER
    % 取列名
    x = strsplit(curs.columnnames,{',',''''});
    y = x(2:end-1);
    % 取不重合列名的位置
    [~,z] = ismember(unique(y),y);
    if ~strcmp(curs.Data, 'No Data')
        % 存入table
        output_table  = cell2table( curs.Data(:,z),'VariableNames',y(:,z));
    else
        output_table = [];
    end
    
end

