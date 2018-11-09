function [output_table,att] = q_table( conn,q)

    curs =  fetch(exec(conn,q));   
    att = curs.attr(end).typeName;   % VARCHAR2 NUMBER
    x = strsplit(curs.columnnames,{',',''''});
    y = x(2:end-1);
    [~,z] = ismember(unique(y),y);
    if ~strcmp(curs.Data, 'No Data')
        output_table  = cell2table( curs.Data(:,z),'VariableNames',y(:,z));
    else
        output_table = [];
    end
    
end

