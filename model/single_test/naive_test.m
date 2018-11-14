function [simulated_nav,weight] = naive_test(p,a,tgt_tag,tgt_file,rebalance_idx,rtn_table)

    %T = length(p.all_trading_dates);
    N = length(p.stk_codes);
    
    % 分组个数
    N_grp = 5;
    
    % 调仓日个数
    N_reb = size(rebalance_idx,1);
    rebalance_dates = table2array(rtn_table(rebalance_idx,1));
    
    style = h5read([a.output_data_path,'\',tgt_file],['/',tgt_tag]);
    
    w = zeros(N_reb,N);
    
    for i=1:N_reb
    
        j = rebalance_idx(i);
        [~,idx] = sort(style(j,:),'descend');
        
        % 当日因子非空的股票个数
        n_stk = length(idx(~isnan(style(j,:))));
        
        if(n_stk==0) 
            continue;
        end
        
        % 择股组内股票个数
        n_sel = ceil(n_stk/N_grp);
        
        long_idx = idx(idx <= n_sel);
        short_idx = idx(idx >= n_stk - n_sel);
        
        w(i,long_idx) = w(i,long_idx) + 1./n_sel;
        w(i,short_idx) = w(i,short_idx) - 1./n_sel;
        
    end
    
    var_names = cell2mat(p.stk_codes_);
    var_names = var_names(:,1:6);
    var_names = strcat('S',var_names);
    var_names = mat2cell(var_names,ones(length(var_names),1),7);
    
    weights_table = [array2table(rebalance_dates),array2table(w)];
    weights_table.Properties.VariableNames = ['DATEN',var_names'];
    cost_table =[array2table(rebalance_dates),array2table(zeros(size(w)),'VariableNames',var_names)];
    cost_table.Properties.VariableNames = ['DATEN',var_names'];
    
    [simulated_nav,weight] = simulator(rtn_table,weights_table,cost_table);
        
end