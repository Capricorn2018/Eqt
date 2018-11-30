function rtn_table = price2rtn(price_table)

    price_array = table2array(price_table(:,2:end));
    
    rtn_array = nan(size(price_array));
    rtn_array(2:end,:) = price_array(2:end,:)./price_array(1:end-1,:) - 1.;
    
    rtn_table = [price_table(:,1),array2table(rtn_array)];
    rtn_table.Properties.VariableNames = price_table.Properties.VariableNames;

end

