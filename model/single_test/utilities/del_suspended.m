function style_table_del = del_suspended(style_table,stk_status_table,is_suspended_table)

    style_array = table2array(style_table(:,2:end));
    
    stk_status = table2array(stk_status_table(:,2:end));
    is_suspended = table2array(is_suspended_table(:,2:end));

    is_suspended(isnan(stk_status)) = NaN;
    is_suspended(is_suspended==1) = NaN;
    is_suspended(isnan(is_suspended)) =1;
        
    [~,ia_row,ib_row] = intersect(style_table.DATEN,is_suspended_table.DATEN,'stable');
    [~,ia_col,ib_col] = intersect(style_table.Properties.VariableNames(2:end),is_suspended_table.Properties.VariableNames(2:end),'stable');
    
    if(length(ia_col)<width(style_table)-1)
        disp('error in del_suspended: stk_codes in style_table not found��');
        return;
    end
    
    is_suspended = is_suspended(ib_row,ib_col);
    style_array = style_array(ia_row,ia_col);
    
    style_array(is_suspended==1) = NaN;
    
    style_table_del = array2table([style_table.DATEN(ia_row),style_array],'VariableNames',['DATEN',style_table.Properties.VariableNames(ia_col+1)]);

end

