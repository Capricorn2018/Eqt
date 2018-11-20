function [ic, ic_ir] = style_ic(rebalance_dates, style_table, rtn_table)

    rebalance_str = cellstr(num2str(rebalance_dates));
    
    style_table.Properties.RowNames = cellstr(num2str(rtn_table.DATEN));
    
    style = table2array(style_table(rebalance_str,2:end));
    
    nav = rtn2nav(rtn_table);
    
    nav_table = array2table(nav,'RowNames',style_table.Properties.RowNames);
    
    nav_reb = nav_table(rebalance_str,:);
    nav_reb = table2array(nav_reb);
    rtn_reb = nav_reb(2:end,:)./nav_reb(1:end-1,:) - 1;
    
    ic = zeros(size(rtn_reb,1)-1,1);
    
    for i = 1:length(ic)
        ic(i) = kendall_tau(style(i,:),rtn_reb(i,:));
    end
    
    ic_ir = mean(ic)/std(ic);
    
end

function nav = rtn2nav(rtn_table)

    rtn = rtn_table(:,2:end);
    rtn = table2array(rtn);
    
    rtn_delnan = rtn;
    rtn_delnan(isnan(rtn)) = 0;
    rtn_delnan = rtn_delnan + 1;
    
    nav = cumprod(rtn_delnan,1);
    
    nav(isnan(rtn)) = NaN;

end

function cor = kendall_tau(style, r)

    not_nan = (~isnan(style)) & (~isnan(r));
    
    style_num = style(not_nan);
    r_num = r(not_nan);

    cor = corr(style_num',r_num','type','Kendall');

end