function [ls_rtn,ls_nav,    interval_ret,hit_ratio,ls_ir,max_dd] = ls_stats(rebalance_dates,nav_grp)

    %N_grp = width(nav_grp) - 1;
    rebalance_str = cellstr(num2str(rebalance_dates));
    
    nav1 = table2array(nav_grp(:,2));
    rtn1 = nav1(2:end) ./ nav1(1:end-1) - 1;
    
    navN = table2array(nav_grp(:,width(nav_grp)));
    rtnN = navN(2:end) ./ navN(1:end-1) - 1;
    
    daily_rtn = (1 - rtn1 + rtnN);
    
    ls = cumprod(daily_rtn);
    ls = [array2table(nav_grp.DATEN), array2table(ls)];
    ls.Properties.RowNames = cellstr(num2str(nav_grp.DATEN));
    ls.Properties.VariableNames = {'DATEN', 'nav'};
    
    ls_nav = ls(rebalance_str);
    ls_rtn = ls_nav(2:end) ./ ls_nav(1:end-1) - 1;
    
    interval_ret = mean(ls_rtn);
    hit_ratio = length(ls_rtn(ls_rtn>0))/length(ls_rtn);
    
    ls_ir = mean(daily_rtn)/std(daily_rtn)/sqrt(250);
    
    [~, max_dd] = get_DD_table(ls.DATEN,ls.nav);

end

