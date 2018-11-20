function  [rebalance_dates, style_snapshot] = get_snapshots(num, direction, style_table)

    trading_dates = table2array(style_table(:,1));
    [rebalance_dates, idx] = find_month_dates(num, trading_dates, direction);
    
    style_snapshot = style_table(idx,2:end);

end

